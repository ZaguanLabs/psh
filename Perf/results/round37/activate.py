from pathlib import Path
import hashlib
import json
import os
import pwd
import subprocess
import sys

root = Path.cwd()
logs = root / '.work/logs/round37'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
sys.path.insert(0, str(root / 'Packaging'))
from audit import stable_snapshot
from install import manifest

build = read(root / '.work/package/latest.json')
old = read(logs / 'previous-release.json')
assert build['release'] == '1.0.0-rc0-7e8f4c48abf5'
assert read(logs / 'source-checks.json')['passed']
assert read(logs / 'code-identity.json')['passed']
identity = read(logs / 'installed-code-identity.json')
assert identity['passed'] and identity['entire_core_machine_code_identical']
assert identity['readonly_difference_only_release_paths']
assert read(logs / 'timing-preconditions.json')['passed']
assert all(sha(root / n) == h for n, h in read(logs / 'frozen-inputs.json').items())
commands = read(logs / 'timing-commands.json')
assert len(commands) == 4 and all(row['status'] == 0 for row in commands)
for row in commands:
    report = read(logs / (row['name'] + '.json'))
    assert report['samples'] == 9 and report['cpu_affinity'] == [13]
assert Path('/usr/local/psh/current').resolve() == Path(old['prefix'])
subprocess.run(['sudo', '-n', 'python3', 'Packaging/install.py', 'activate'], check=True)
assert Path('/usr/local/psh/current').resolve() == Path(build['prefix'])
assert sha(Path('/usr/local/bin/psh')) == build['installed_shell_sha256']
assert manifest(Path(old['prefix'])) == old['manifest']
assert stable_snapshot() == old['stable']
assert sha(Path('/etc/shells')) == old['etc_shells_sha256']
assert pwd.getpwuid(os.getuid()).pw_shell == old['login_shell']
proof = dict(passed=True, active_prefix=build['prefix'],
             installed_shell_sha256=build['installed_shell_sha256'],
             previous_release_entries_unchanged=len(old['manifest']),
             stable_zsh_startup_entries_unchanged=len(old['stable']),
             etc_shells_unchanged=True, login_shell_unchanged=True,
             accepted_optimizations=27, maintenance_change=True,
             full_core_machine_code_unchanged=True)
(logs / 'activation.json').write_text(json.dumps(proof, indent=2) + '\n')
print('Activated maintenance iteration:', build['release'])
