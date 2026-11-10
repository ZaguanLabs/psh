from pathlib import Path
import ast
import gzip
import hashlib
import json
import re
import shutil
import subprocess
import sys

root = Path.cwd()
logs = root / '.work/logs/round36'
archive = root / 'Perf/results/round36'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
shutil.copy2(logs / 'final-artifact-check.py', archive / 'final-artifact-check.py')
shutil.copy2(logs / 'closeout.log', archive / 'closeout.log')
for path in archive.rglob('*.py'):
    ast.parse(path.read_text(), filename=str(path))
for path in archive.rglob('*.callgrind.gz'):
    assert b'events:' in gzip.decompress(path.read_bytes())
assert len(list(archive.glob('*.callgrind.gz'))) == 8
assert len(list((archive / 'queued-only').glob('*.callgrind.gz'))) == 8
for path in [root / 'Perf/round36.md', archive / 'README.md']:
    for target in re.findall(r'\]\(([^)#]+)(?:#[^)]*)?\)', path.read_text()):
        if '://' not in target and target != 'sha256.json':
            assert (path.parent / target).exists(), (path, target)
tracked = subprocess.check_output(['git', 'diff', '--name-only'], text=True).splitlines()
subprocess.run(['git', 'diff', '--check', '--', *tracked], check=True)
sys.path.insert(0, str(root / 'Packaging'))
from elf import dynamic_exports
previous = set(dynamic_exports(root / '.work/round36/previous/Src/zsh'))
fused = set(dynamic_exports(root / '.work/round36/fused/Src/zsh'))
assert previous <= fused
assert len(fused - previous) == 1
proof = dict(passed=True, python_syntax=True, markdown_links=True,
             authored_diff_whitespace=True, profile_archives=16,
             existing_dynamic_exports_preserved=len(previous),
             trial_added_dynamic_exports=sorted(fused - previous),
             production_source_unchanged=True,
             observations=read(archive / 'final-checks.json')['extended_observations'])
(archive / 'artifact-check.json').write_text(json.dumps(proof, indent=2) + '\n')
index = {str(p.relative_to(archive)): sha(p) for p in sorted(archive.rglob('*'))
         if p.is_file() and p.name != 'sha256.json'}
(archive / 'sha256.json').write_text(json.dumps(index, indent=2) + '\n')
print('Archive verified:', len(index), 'files; existing exports:', len(previous))
