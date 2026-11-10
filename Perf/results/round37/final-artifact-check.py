from pathlib import Path
import ast
import gzip
import hashlib
import json
import re
import shutil
import subprocess

root = Path.cwd()
logs = root / '.work/logs/round37'
archive = root / 'Perf/results/round37'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
shutil.copy2(logs / 'final-artifact-check.py', archive / 'final-artifact-check.py')
shutil.copy2(logs / 'closeout.log', archive / 'closeout.log')
for path in [root / 'Perf/build.py', root / 'Perf/math-compare.py', *archive.rglob('*.py')]:
    ast.parse(path.read_text(), filename=str(path))
for path in archive.rglob('*.callgrind.gz'):
    assert b'events:' in gzip.decompress(path.read_bytes())
assert len(list(archive.glob('installed-*.callgrind.gz'))) == 8
assert len(list((archive / 'typed-record').glob('*.callgrind.gz'))) == 8
profiles = {row['name']: row for row in read(archive / 'installed-profiles.json')}
for kernel in ['coder', 'chat', 'endgame', 'json-encode']:
    before = profiles['previous-' + kernel]
    after = profiles['candidate-' + kernel]
    for key in ['worker_sha256', 'source_sha256', 'output_state_sha256']:
        assert before[key] == after[key], (kernel, key)
    assert before['status'] == after['status'] == 0
for name in ['clang-paired-state', 'paired-state-memcheck',
             'installed-state-memcheck', 'development-state-memcheck']:
    report = read(archive / (name + '.json'))
    assert report['driver_sha256'] == sha(root / 'Perf/math-compare.py')
    assert report['memcheck'] and len(report['cases']) == 2
    assert sum(row['checks'] for row in report['cases']) == 1296
    files = list(archive.glob(name + '.*.memcheck.log'))
    assert len(files) == 4 and all(not p.read_bytes().strip() for p in files)
for path in [root / 'Perf/round37.md', root / 'Perf/arithmetic-internals.md', archive / 'README.md']:
    for target in re.findall(r'\]\(([^)#]+)(?:#[^)]*)?\)', path.read_text()):
        if '://' not in target and target != 'sha256.json':
            assert (path.parent / target).exists(), (path, target)
source = read(archive / 'source-checks.json')
assert source['passed'] and len(source['fixtures']) == 5
assert all(sha(root / n) == h for n, h in source['fixtures'].items())
assert source['patch_sha256'] == sha(root / 'Perf/0037-arithmetic-state-contract.patch')
assert read(archive / 'activation.json')['passed']
assert read(archive / 'native-code-identity.json')['passed']
assert read(archive / 'package-verification.json')['passed']
assert read(archive / 'ohmyzsh.json')['passed']
assert len(read(archive / 'ohmyzsh.json')['runs']) == 24
for name in ['core', 'zdraw', 'zjson', 'zcurl', 'zmdown', 'zhtml2md', 'zoup']:
    assert read(archive / ('test-' + name + '.json'))['passed']
authored = ['Src/math.c', 'Perf/build.py', 'Perf/math-compare.py', 'Perf/README.md',
            'Perf/audit.md', 'README.psh.md', 'Releases/rc0-release-profile.md']
subprocess.run(['git', 'diff', '--check', '--', *authored], check=True)
proof = dict(passed=True, python_syntax=True, authored_links=True,
             patch_files=5, raw_profiles=16, installed_profile_states_match=True,
             paired_state_comparisons=5184, state_memcheck_invocations=16,
             ohmyzsh_sessions=24, package_suites=7)
(archive / 'artifact-check.json').write_text(json.dumps(proof, indent=2) + '\n')
index = {str(p.relative_to(archive)): sha(p) for p in sorted(archive.rglob('*'))
         if p.is_file() and p.name != 'sha256.json'}
(archive / 'sha256.json').write_text(json.dumps(index, indent=2) + '\n')
print('Archive verified:', len(index), 'files; 16 profiles; 16 focused Memcheck invocations.')
