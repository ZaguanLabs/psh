#!/usr/bin/env python3
"""Alternate associative materialization timings, checking complete output."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


WORKER = r'''
emulate -R zsh
zmodload zsh/datetime || exit 2
integer size=$1 iterations=$2 i
local mode=$3
typeset -A h
typeset -a a out
for ((i=0; i<size; i++)); do h[k$i]=v$i; a+=(v$i); done
float start=$EPOCHREALTIME
repeat $iterations; do
  case $mode in
    keys) out=("${(@k)h}");;
    values) out=("${(@v)h}");;
    pairs) out=("${(@kv)h}");;
    match) out=("${(@)h[(R)v*]}");;
    array-control) out=("${a[@]}");;
  esac
done
printf '%.9f\n' $((EPOCHREALTIME-start))
(( $#out )) && print -rl -- "${(@o)out}"
exit 0
'''


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.samples < 3:
        p.error('at least three samples are required')
    os.sched_setaffinity(0, {a.cpu})
    shells = [s.resolve(strict=True) for s in (a.baseline, a.candidate)]
    sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    hashes = list(map(sha, shells))
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
    report = dict(shells=list(map(str, shells)), binary_sha256=hashes,
                  worker_sha256=hashlib.sha256(WORKER.encode()).hexdigest(),
                  driver_sha256=sha(Path(__file__).resolve()), environment=env,
                  cpu_affinity=sorted(os.sched_getaffinity(0)), samples=a.samples,
                  scope='warm expansion and array assignment; setup excluded', cases=[])
    for size in (0, 16, 256, 4096, 4097):
        iterations = max(20, 150000 // max(1, size))
        for mode in ('keys', 'values', 'pairs', 'match', 'array-control'):
            expected = []
            if mode in ('keys', 'pairs'):
                expected += [f'k{i}' for i in range(size)]
            if mode != 'keys':
                expected += [f'v{i}' for i in range(size)]
            state = ''.join(s + '\n' for s in sorted(expected)).encode()
            times = [[], []]
            for sample in range(a.samples):
                for host in ((0, 1) if sample % 2 == 0 else (1, 0)):
                    r = subprocess.run([str(shells[host]), '-dfc', WORKER, 'hash-expansion',
                                        str(size), str(iterations), mode], env=env,
                                       capture_output=True, timeout=60)
                    if r.returncode or r.stderr:
                        raise RuntimeError((size, mode, host, r.returncode, r.stderr))
                    elapsed, actual = r.stdout.split(b'\n', 1)
                    if actual != state:
                        raise RuntimeError((size, mode, host, 'unexpected result'))
                    times[host].append(float(elapsed) * 1000)
            medians = [statistics.median(x) for x in times]
            report['cases'].append(dict(size=size, mode=mode, iterations=iterations,
                                        samples_ms=times, median_ms=medians,
                                        state_sha256=hashlib.sha256(state).hexdigest()))
            print(size, mode, medians, flush=True)
            a.output.parent.mkdir(parents=True, exist_ok=True)
            a.output.write_text(json.dumps(report, indent=2) + '\n')
    if hashes != list(map(sha, shells)):
        raise RuntimeError('shell changed during measurement')


if __name__ == '__main__':
    main()
