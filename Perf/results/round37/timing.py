from pathlib import Path
import json
import subprocess
import time

logs = Path('.work/logs/round37')
read = lambda p: json.loads(p.read_text())
assert read(logs / 'timing-preconditions.json')['passed']
old = read(logs / 'previous-package.json')
new = read(Path('.work/package/latest.json'))
hosts = [old['prefix'] + '/bin/psh', new['prefix'] + '/bin/psh']
rows = []
for name, driver, arguments in [
    ('customer-benchmarks', 'customer-benchmark.py', ['--labs', '/home/stig/dev/ai/zaguan/labs', '--challenge', '/home/stig/dev/challenge']),
    ('library-benchmarks', 'applications.py', ['--arrays', '--zjson', '/home/stig/dev/ai/zaguan/labs/zjson', '--z3dfx', '/home/stig/dev/challenge/z3dfx']),
    ('customer-repeat', 'customer-benchmark.py', ['--labs', '/home/stig/dev/ai/zaguan/labs', '--challenge', '/home/stig/dev/challenge']),
    ('library-repeat', 'applications.py', ['--arrays', '--zjson', '/home/stig/dev/ai/zaguan/labs/zjson', '--z3dfx', '/home/stig/dev/challenge/z3dfx']),
]:
    command = ['python3', 'Perf/' + driver, *hosts, *arguments,
               '--cpu', '13', '--output', str(logs / (name + '.json'))]
    started = time.monotonic()
    with (logs / (name + '.log')).open('wb') as out:
        process = subprocess.run(command, stdout=out, stderr=subprocess.STDOUT)
    rows.append(dict(name=name, command=command, status=process.returncode,
                     seconds=time.monotonic() - started))
    (logs / 'timing-commands.json').write_text(json.dumps(rows, indent=2) + '\n')
    print(name, process.returncode, flush=True)
    assert process.returncode == 0
