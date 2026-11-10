from pathlib import Path
import ast
import gzip
import hashlib
import json
import os
import pwd
import shutil
import subprocess
import sys
import tempfile

root = Path.cwd()
logs = root / '.work/logs/round36'
archive = root / 'Perf/results/round36'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
sys.path.insert(0, str(root / 'Packaging'))
from audit import stable_snapshot
from install import manifest

build = read(root / '.work/package/latest.json')
old = read(logs / 'previous-release.json')
parent = read(logs / 'parent.json')
assert build == read(logs / 'previous-package.json')
assert Path('/usr/local/psh/current').resolve() == Path(build['prefix'])
assert sha(Path('/usr/local/bin/psh')) == parent['active_sha256']
assert manifest(Path(build['prefix'])) == old['manifest']
assert stable_snapshot() == old['stable']
assert sha(Path('/etc/shells')) == old['etc_shells_sha256']
assert pwd.getpwuid(os.getuid()).pw_shell == old['login_shell']
assert not subprocess.check_output([
    'git', 'diff', parent['commit'], '--', 'Src', 'Test', 'Vendor', 'Packaging'])
assert sha(root / 'psh') == parent['development_sha256']
assert all(sha(root / n) == h for n, h in build['core_source_sha256'].items())
assert read(logs / 'restoration.json')['passed']
assert read(logs / 'restoration.json')['new_emulation_fixture_sha256'] == sha(root / 'Perf/emulation-module.c')
for folder in [logs, logs / 'queued-only']:
    assert read(folder / 'validation.json')['passed']
    assert all(row['status'] == 0 for row in read(folder / 'validation.json')['runs'])
for patch, expected in [
    (logs / 'fused-source.patch', read(logs / 'fused-source.json')['files']),
    (logs / 'queued-only/source.patch', None),
]:
    with tempfile.TemporaryDirectory() as td:
        target = Path(td)
        for name in ['Src/options.c', 'Src/hashtable.c']:
            path = target / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(subprocess.check_output(['git', 'show', parent['commit'] + ':' + name]))
        subprocess.run(['patch', '-p1', '--batch', '--input', str(patch)],
                       cwd=target, check=True, capture_output=True)
        if expected:
            assert all(sha(target / n) == h for n, h in expected.items())
observations = 0
processes = 0
for name in ['emulation-reentry', 'pristine-reentry', 'development-reentry']:
    report = read(logs / (name + '.json'))
    assert report['passed'] and report['checks'] == 233032
    assert report['fingerprints'][str(root / 'Perf/emulation-module.c')] == sha(root / 'Perf/emulation-module.c')
    assert all(row['memcheck'] and row['checks'] == 58258 for row in report['runs'])
    for path in (logs / name).glob('*.memcheck.log'):
        assert 'ERROR SUMMARY: 0 errors' in path.read_text()
    observations += report['checks']
    processes += len(report['runs'])
for name in ['pilot-timing', 'repeat-timing']:
    assert all(row['status'] == 0 for row in read(logs / (name + '.json')))
for name in ['previous', 'fused']:
    assert '63 successful test scripts, 0 failures, 2 skipped' in (logs / (name + '-upstream.log')).read_text()
for name, command in [
    ('github-precommit', ['gh', 'release', 'view', 'v1.0.0-rc0', '--repo',
                         'ZaguanLabs/psh', '--json', 'assets,isDraft,isPrerelease,tagName,url']),
    ('repository-precommit', ['gh', 'repo', 'view', 'ZaguanLabs/psh', '--json', 'isPrivate']),
]:
    (logs / (name + '.json')).write_bytes(subprocess.check_output(command))
original = read(root / '.work/releases/v1.0.0-rc0/github-receipt.json')
assert read(logs / 'github-precommit.json') == original
assert original['isDraft'] and len(original['assets']) == 7
assert read(logs / 'repository-precommit.json')['isPrivate']
proof = dict(passed=True, extended_observations=observations,
             extended_memcheck_processes=processes, source_patches_replayed=2,
             source_and_payload_restored=True, developer_binary_unchanged=True)
(logs / 'final-checks.json').write_text(json.dumps(proof, indent=2) + '\n')
archive.mkdir(exist_ok=True)
excluded = {'previous-release.json', 'previous-package.json', 'previous-release-status.json',
            'checkpoint.txt'}
for path in logs.rglob('*'):
    if not path.is_file() or path.name in excluded:
        continue
    dest = archive / path.relative_to(logs)
    if path.suffix == '.callgrind':
        dest = dest.with_suffix('.callgrind.gz')
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(gzip.compress(path.read_bytes(), mtime=0))
    elif path.suffix in {'.json', '.py', '.log', '.txt', '.patch', '.c'}:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
for path in archive.rglob('*.py'):
    ast.parse(path.read_text(), filename=str(path))
print('Archived', sum(p.is_file() for p in archive.rglob('*')), 'files')
