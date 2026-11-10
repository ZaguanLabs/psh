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

root = Path.cwd()
logs = root / '.work/logs/round37'
archive = root / 'Perf/results/round37'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
subprocess.run(['python3', str(logs / 'source-checks.py')], check=True)
sys.path.insert(0, str(root / 'Packaging'))
from audit import stable_snapshot
from install import manifest

build = read(root / '.work/package/latest.json')
old = read(logs / 'previous-release.json')
assert read(logs / 'activation.json')['passed']
assert Path('/usr/local/psh/current').resolve() == Path(build['prefix'])
assert sha(Path('/usr/local/bin/psh')) == build['installed_shell_sha256']
assert manifest(Path(old['prefix'])) == old['manifest']
assert stable_snapshot() == old['stable']
assert sha(Path('/etc/shells')) == old['etc_shells_sha256']
assert pwd.getpwuid(os.getuid()).pw_shell == old['login_shell']
assert read(logs / 'source-checks.json')['development_sha256'] == sha(root / 'psh')
for name in ['code-identity', 'installed-code-identity', 'validation',
             'development-runtime-isolation', 'timing-preconditions']:
    assert read(logs / (name + '.json'))['passed']
assert all(row['status'] == 0 for row in read(logs / 'timing-commands.json'))
assert all(row['status'] == 0 for row in read(logs / 'package-validation.json'))
native = read(logs / 'native-code-identity.json')
assert native['compared'] == 40 and not native['different_text']
native['passed'] = True
(logs / 'native-code-identity.json').write_text(json.dumps(native, indent=2) + '\n')
work = Path(build['work'])
for name in ['core', 'zdraw', 'zjson', 'zcurl', 'zmdown', 'zhtml2md', 'zoup']:
    assert read(work / ('test-' + name + '.json'))['passed']
assert read(work / 'validation.json')['passed']
omz = read(work / 'ohmyzsh.json')
assert omz['passed'] and len(omz['runs']) == 24
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

# Complete the historical archive after its processes have finished.
historical = logs / 'typed-record'
patterns = ['candidate-*', 'clang-candidate-*', 'state-frames*',
            'pristine-state-frames*', 'clang-state-frames*', 'matched-profiles*',
            'previous-coder*', 'previous-chat*', 'previous-endgame*', 'previous-json-encode*',
            'gcc-code-generation.json']
for pattern in patterns:
    for path in list(logs.glob(pattern)):
        if path.is_file():
            shutil.copy2(path, historical / path.name)
            path.unlink()
probes = logs / 'object-probes'
probes.mkdir(exist_ok=True)
for path in (root / '.work/round37/object-probes').glob('*.c'):
    shutil.copy2(path, probes / path.name)

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
    elif path.suffix in {'.json', '.py', '.log', '.txt', '.patch', '.c', '.asm'}:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
for name in ['validation.json', 'ohmyzsh.json', 'terminal-profile.json', 'installed-core-harness.json']:
    shutil.copy2(work / name, archive / ('package-verification.json' if name == 'validation.json' else name))
for path in work.glob('test-*.json'):
    shutil.copy2(path, archive / path.name)
for path in (work / 'logs').glob('test-*.log'):
    shutil.copy2(path, archive / path.name)
package = {key: build[key] for key in ['release', 'prefix', 'project_version', 'zsh_version',
                                      'settings', 'raw_shell_sha256', 'installed_shell_sha256',
                                      'debug_file_sha256', 'vendor_commits']}
package['native_sha256'] = {str(p.relative_to(Path(build['prefix']))): sha(p)
                            for p in Path(build['prefix']).rglob('*.so')}
(archive / 'installed-package.json').write_text(json.dumps(package, indent=2) + '\n')
for path in archive.rglob('*.py'):
    ast.parse(path.read_text(), filename=str(path))
print('Archived', sum(p.is_file() for p in archive.rglob('*')), 'files')
