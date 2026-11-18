import hashlib
import json
import re
import runpy
import subprocess
import sys
from pathlib import Path

# Run from the repository root with OUTPUT followed by shell paths.
output = Path(sys.argv[1])
shells = [Path(arg).resolve(strict=True) for arg in sys.argv[2:]]
if len(shells) < 2:
    raise SystemExit("usage: nesting.py OUTPUT BASE CANDIDATE [SHELL ...]")
memory = runpy.run_path('Perf/memory-checkpoints.py')['memory']
body = '''
ready() { print -r -- "$1"; read -r ack || exit 1; }
nest() {
    [[ $_ == short ]] || exit 1
    if (( $1 )); then
        nest $(( $1 - 1 )) short || exit 1
        [[ $_ == short ]] || exit 1
    else
        ready deepest
    fi
}
ready initial
nest 200 short || exit 1
[[ $_ == short ]] || exit 1
ready returned
'''
report = dict(script=body, depth=200, units='KiB', samples=5, runs=[])
for sample in range(5):
    for shell in (reversed(shells) if sample % 2 else shells):
        points = {}
        with subprocess.Popen([shell, '-dfc', body], env=dict(PATH='/usr/bin:/bin', LC_ALL='C.UTF-8'),
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as p:
            try:
                for phase in ('initial','deepest','returned'):
                    assert p.stdout.readline() == (phase+'\n').encode()
                    smaps = Path(f'/proc/{p.pid}/smaps').read_text().split('[stack]\n')[1]
                    stackrss = int(re.search(r'^Rss:\s+(\d+) kB$', smaps, re.M)[1])
                    points[phase] = dict(stack_rss=stackrss, memory=memory(p.pid))
                    p.stdin.write(b'continue\n')
                    p.stdin.flush()
                stdout, stderr = p.communicate(timeout=20)
                assert p.returncode == 0 and not stderr and not stdout
            finally:
                if p.poll() is None:
                    p.kill()
        report['runs'].append(dict(shell=str(shell), sample=sample, points=points))
report['sha256'] = {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in shells}
output.write_text(json.dumps(report, indent=2)+'\n')
