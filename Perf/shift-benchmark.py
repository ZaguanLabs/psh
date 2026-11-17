#!/usr/bin/env python3
"""Measure verified positional shifts in alternating fresh shells on Linux."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import tempfile

WORKER = Path(__file__).with_name('shift-workload.zsh').resolve()
CASES = [(mode, width, width) for width in (32, 4096, 16384) for mode in ('front', 'back')]
CASES += [('zero', 4096, 1024)]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('--samples', type=int, default=9)
    parser.add_argument('--cpu', type=int, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error('at least three samples are required')
    shells = [path.resolve(strict=True) for path in (args.baseline, args.candidate)]
    os.sched_setaffinity(0, {args.cpu})
    paths = [*shells, WORKER, Path(__file__).resolve()]
    hashes = {str(path): digest(path) for path in paths}
    rows = []
    with tempfile.TemporaryDirectory() as temp:
        rss = Path(temp) / 'peak'
        for mode, width, count in CASES:
            times, peaks, states = [[], []], [[], []], set()
            for sample in range(args.samples):
                for host in ((0, 1) if sample % 2 == 0 else (1, 0)):
                    command = ['/usr/bin/time', '-f', '%M', '-o', str(rss), str(shells[host]),
                               '-df', str(WORKER), mode, str(width), str(count)]
                    r = subprocess.run(command, capture_output=True, timeout=120,
                                       env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'})
                    if r.returncode or r.stderr:
                        raise RuntimeError((command, r.returncode, r.stderr))
                    elapsed, state = r.stdout.split(b'\n', 1)
                    if not state:
                        raise RuntimeError('empty final argument state')
                    states.add(hashlib.sha256(state).hexdigest())
                    times[host].append(float(elapsed) * 1000)
                    peaks[host].append(int(rss.read_text()))
            if len(states) != 1:
                raise RuntimeError(f'argument state mismatch in {mode} case')
            medians = list(map(statistics.median, times))
            rows.append(dict(mode=mode, width=width, count=count, batch_ms=times, peak_rss_kib=peaks,
                             median_ms=medians, state_sha256=states.pop()))
            print(mode, width, medians, flush=True)
    if hashes != {str(path): digest(path) for path in paths}:
        raise RuntimeError('measurement input changed')
    args.output.write_text(json.dumps(dict(hashes=hashes, shells=list(map(str, shells)), cpu=args.cpu,
                                          samples=args.samples, cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
