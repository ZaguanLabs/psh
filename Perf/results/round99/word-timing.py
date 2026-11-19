"""Time parameter expansion with and without adjacent literal text."""
import argparse
import hashlib
import json
import os
import statistics
import subprocess
from pathlib import Path

WORKER = r"""
emulate -R zsh
integer size=$1 rounds=$2
value=${(l:$size::x:)}
run() {
    if [[ $3 == joined ]]; then
        repeat $rounds { result="pre${value}post" }
    else
        repeat $rounds { result=$value }
    fi
}
run "$@"
float -F 9 SECONDS=0
run "$@"
float elapsed=$SECONDS
printf '%.9f\n%s' $elapsed "$result"
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('shells', type=Path, nargs=2)
    parser.add_argument('--cpu', type=int, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    builds = [p.resolve(strict=True) for p in args.shells]
    env = {'LC_ALL': 'C.UTF-8', 'PATH': '/usr/bin:/bin'}
    os.sched_setaffinity(0, {args.cpu})
    rows = []
    for size, rounds in [(0, 4000), (32, 4000), (4096, 2000), (65536, 250), (1048576, 16)]:
        for form in ('joined', 'whole'):
            data = b'x' * size
            expected = b'pre' + data + b'post' if form == 'joined' else data
            samples = [[], []]
            for rep in range(12):
                for host in ((1, 0) if rep % 2 else (0, 1)):
                    r = subprocess.run([builds[host], '-dfc', WORKER, 'worker', str(size), str(rounds), form],
                                       env=env, capture_output=True, check=True, timeout=60)
                    elapsed, actual = r.stdout.split(b'\n', 1)
                    if r.stderr or actual != expected:
                        raise ValueError((size, form, host))
                    samples[host].append(float(elapsed) * 1000)
            rows.append(dict(size=size, rounds=rounds, form=form, samples_ms=samples,
                             median_ms=list(map(statistics.median, samples))))
    hashes = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in [*builds, Path(__file__)]}
    args.output.write_text(json.dumps(dict(shells=list(map(str, builds)), inputs=hashes, cpu=args.cpu,
                                           environment=env, cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
