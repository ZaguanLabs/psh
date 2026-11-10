from pathlib import Path
import ast
import gzip
import hashlib
import json
import re
import shutil
import subprocess

root = Path.cwd()
archive = root / 'Perf/results/round35'
logs = root / '.work/logs/round35'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
shutil.copy2(logs / 'final-artifact-check.py', archive / 'final-artifact-check.py')
for path in [root / 'Perf/check-scope-cleanup-module.py', *archive.rglob('*.py')]:
    ast.parse(path.read_text(), filename=str(path))
assert read(archive / 'source-checks.json')['passed']
assert read(archive / 'activation.json')['passed']
assert len(read(archive / 'patch-check.json')['files']) == 41
assert all(x['status'] == 0 for x in read(archive / 'timing-commands.json'))
assert len(read(archive / 'timing-commands.json')) == 9
assert len(read(archive / 'ohmyzsh.json')['runs']) == 24
for name in ['core', 'zdraw', 'zcurl', 'zjson', 'zmdown', 'zhtml2md', 'zoup']:
    assert read(archive / ('test-' + name + '.json'))['passed']
for path in archive.rglob('*.callgrind.gz'):
    assert b'events:' in gzip.decompress(path.read_bytes())
assert len(list(archive.glob('*.callgrind.gz'))) == 8
assert len(list((archive / 'indexed-pilot').glob('*.callgrind.gz'))) == 8
# The checksum index is produced after this check.
for path in [root / 'Perf/round35.md', archive / 'README.md']:
    for target in re.findall(r'\]\(([^)#]+)(?:#[^)]*)?\)', path.read_text()):
        if '://' not in target and target != 'sha256.json':
            assert (path.parent / target).exists(), (path, target)
tracked = subprocess.check_output(['git', 'diff', '--name-only'], text=True).splitlines()
subprocess.run(['git', 'diff', '--check', '--', *tracked], check=True)
proof = dict(passed=True, archive_python_syntax=True, authored_relative_links=True,
             tracked_diff_whitespace=True, final_raw_profiles=8,
             intermediate_raw_profiles=8, incremental_patch_files=41,
             installed_timing_groups=9, ohmyzsh_sessions=24, package_suites=7)
(logs / 'final-artifact-check.json').write_text(json.dumps(proof, indent=2) + '\n')
shutil.copy2(logs / 'final-artifact-check.json', archive / 'final-artifact-check.json')
index = {str(p.relative_to(archive)): sha(p) for p in sorted(archive.rglob('*'))
         if p.is_file() and p.name != 'sha256.json'}
(archive / 'sha256.json').write_text(json.dumps(index, indent=2) + '\n')
print('Archive verified:', len(index), 'files')
