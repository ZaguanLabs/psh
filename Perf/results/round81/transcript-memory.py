"""Measure live memory for the named-shift transcript fixture. Run from the repo root."""
import hashlib
import json
from pathlib import Path
import runpy
import subprocess
import sys

baseline, candidate, project, output = map(Path, sys.argv[1:5])
width = int(sys.argv[5])
worker = Path('Perf/named-shift-workload.zsh').resolve()
memory = runpy.run_path('Perf/memory-checkpoints.py')['memory']
wrapper = '''
phase() { print -r -- "$1"; read -r ack || exit 2; }
phase startup
source "$1" transcript "$3" 1 "$2" >/dev/null || exit 1
[[ $REPLY == "$expected" ]] || exit 1
phase initial
integer cycle
for (( cycle=1; cycle<=100; ++cycle )); do
    run && [[ $REPLY == "$expected" ]] || exit 1
    if (( cycle == 5 || cycle == 20 || cycle == 100 )); then phase cycle-$cycle; fi
done
print -r -- "$REPLY"
'''
shells = [baseline.resolve(), candidate.resolve()]
env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
report = dict(width=width, units='KiB', environment=env, wrapper=wrapper, runs=[])
state = None
for sample in range(5):
    for shell in (reversed(shells) if sample % 2 else shells):
        command = [str(shell), '-dfc', wrapper, 'transcript-memory', str(worker), str(project), str(width)]
        points = {}
        with subprocess.Popen(command, env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE) as proc:
            try:
                for phase in ('startup', 'initial', 'cycle-5', 'cycle-20', 'cycle-100'):
                    assert proc.stdout.readline() == (phase + '\n').encode()
                    points[phase] = memory(proc.pid)
                    proc.stdin.write(b'continue\n')
                    proc.stdin.flush()
                result, errors = proc.communicate(timeout=30)
                assert not proc.returncode and not errors and len(result) > width
                if state is None:
                    state = result
                assert state == result
            finally:
                if proc.poll() is None:
                    proc.kill()
        report['runs'].append(dict(shell=str(shell), sample=sample, points=points,
                                   state_sha256=hashlib.sha256(result).hexdigest()))
report['hashes'] = {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [*shells, worker, project / 'lib/transcript.zsh',
                              project / 'vendor/zjson/zjson.zsh', Path(__file__)]}
output.write_text(json.dumps(report, indent=2) + '\n')
