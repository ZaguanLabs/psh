#!/usr/bin/env python3
"""Alternate focused literal-separator split timings with state verification."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time


CODE = '''emulate -R zsh
zmodload zsh/datetime || exit 1
typeset sep=$1 text=$2
typeset -a parts
integer n=$3
repeat 100 { parts=("${(@s.$sep.)text}"); }
float start=$EPOCHREALTIME
repeat $n { parts=("${(@s.$sep.)text}"); }
float elapsed=$EPOCHREALTIME-start
printf '%.9f\n' $elapsed
typeset -p parts
'''


def cases():
    return [
        ('short', b':', b'alpha:beta::gamma:'),
        ('long', b':', b'x' * 1024 + b':tail:value'),
        ('missing', b':', b'no separator is present here'),
        ('space', b' ', b'one two  three '),
        ('unicode', ':'.encode(), 'café:界:next:value'.encode()),
        ('multibyte-separator', 'é'.encode(), 'alphaéébetaégamma'.encode()),
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('previous', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('--samples', type=int, default=9)
    parser.add_argument('--iterations', type=int, default=20000)
    parser.add_argument('--cpu', type=int, default=13)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3 or args.iterations < 1:
        parser.error('at least three samples and one iteration required')
    shells = [path.resolve(strict=True)
              for path in (args.previous, args.candidate)]
    sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    os.sched_setaffinity(0, {args.cpu})
    rows = []
    for label, separator, subject in cases():
        samples = [[], []]
        state = None
        for sample in range(-1, args.samples):
            for host in ((0, 1) if sample % 2 == 0 else (1, 0)):
                start = time.perf_counter_ns()
                proc = subprocess.run(
                    [str(shells[host]), '-dfc', CODE, 'probe', separator,
                     subject, str(args.iterations)],
                    env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'},
                    capture_output=True, timeout=120)
                elapsed_ms = (time.perf_counter_ns() - start) / 1e6
                if proc.returncode or proc.stderr:
                    raise RuntimeError((label, host, proc.returncode, proc.stderr))
                elapsed, observed = proc.stdout.split(b'\n', 1)
                if not observed:
                    raise RuntimeError(label + ': missing state')
                if state is None:
                    state = observed
                if observed != state:
                    raise RuntimeError(label + ': result differs')
                if sample >= 0:
                    samples[host].append(dict(elapsed_ms=elapsed_ms,
                                             reported_batch_s=float(elapsed)))
        row = dict(case=label, separator=separator.hex(), subject_sha256=hashlib.sha256(subject).hexdigest(),
                   iterations=args.iterations, samples=samples,
                   median_ms=[statistics.median(item['elapsed_ms'] for item in side)
                              for side in samples],
                   median_batch_s=[statistics.median(item['reported_batch_s'] for item in side)
                                   for side in samples],
                   state_sha256=hashlib.sha256(state).hexdigest())
        rows.append(row)
        print(label, row['median_ms'], row['median_batch_s'], flush=True)
    report = dict(previous=str(shells[0]), candidate=str(shells[1]),
                  binary_sha256=list(map(sha, shells)),
                  worker_sha256=hashlib.sha256(CODE.encode()).hexdigest(),
                  driver_sha256=sha(Path(__file__)),
                  samples=args.samples, environment={'LC_ALL': 'C.UTF-8'},
                  cpu_affinity=sorted(os.sched_getaffinity(0)),
                  scope='fresh process with warm split; elapsed and internal batch timings retained separately',
                  cases=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
