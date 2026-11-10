from pathlib import Path
import json
import subprocess
import time

logs = Path('.work/logs/round37')
rows = []
for name, command in [
    ('package-snapshot', ['python3', 'Packaging/verify.py', 'snapshot']),
    ('package-install', ['sudo', '-n', 'python3', 'Packaging/install.py', 'candidate']),
    ('package-tests', ['python3', 'Packaging/test.py']),
    ('stage-modules', ['python3', 'Packaging/verify.py', 'stage-modules']),
    ('refresh-modules', ['sudo', '-n', 'python3', 'Packaging/install.py', 'refresh-modules']),
    ('package-verification', ['python3', 'Packaging/verify.py', 'verify']),
]:
    started = time.monotonic()
    with (logs / (name + '.log')).open('wb') as out:
        process = subprocess.run(command, stdout=out, stderr=subprocess.STDOUT)
    rows.append(dict(name=name, command=command, status=process.returncode,
                     seconds=time.monotonic() - started))
    (logs / 'package-validation.json').write_text(json.dumps(rows, indent=2) + '\n')
    print(name, process.returncode, flush=True)
    assert process.returncode == 0, name
