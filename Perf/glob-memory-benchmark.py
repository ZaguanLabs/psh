#!/usr/bin/env python3
"""Paired fresh-process glob timing and peak RSS, with complete result checks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import tempfile
import time


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    if args.samples < 3:
        p.error('at least three samples required')
    os.sched_setaffinity(0, {args.cpu})
    shells = [x.resolve(strict=True) for x in (args.baseline, args.candidate)]
    hashes = [sha(x) for x in shells]
    long_literal = 'x' * 1024
    cases = {
        'plain-control': 'a=(*(N))',
        'short': "a=(*(Ne^':'^))",
        'long': "a=(*(Ne^': " + long_literal + "'^))",
        'function': '_qual() { :; }; a=(*(N+_qual))',
        'sort': "a=(*(Noe^'REPLY=${#REPLY}'^))",
        'retained-function': "a=(*(Ne^'kept() { : " + long_literal + "; }; :'^)); kept",
    }
    rows = []
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
    with tempfile.TemporaryDirectory(prefix='psh-glob-memory-') as tmp:
        root = Path(tmp)
        files = root / 'files'
        files.mkdir()
        previous = 0
        for count in (100, 1000, 10000):
            for i in range(previous, count):
                (files / f'f{i:05d}').touch()
            previous = count
            expected = b''.join(f'f{i:05d}\0'.encode() for i in range(count))
            for case, operation in cases.items():
                code = 'emulate -R zsh; ' + operation + '; printf "%s\\0" "${a[@]}"'
                samples = [[], []]
                # Warm once per host, then alternate the first host each sample.
                for sample in range(-1, args.samples):
                    for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                        rss = root / 'rss'
                        cmd = ['/usr/bin/time', '-f', '%M', '-o', str(rss),
                               str(shells[host]), '-dfc', code]
                        started = time.perf_counter_ns()
                        r = subprocess.run(cmd, cwd=files, env=env, capture_output=True, timeout=120)
                        elapsed = (time.perf_counter_ns() - started) / 1e6
                        assert r.returncode == 0 and not r.stderr and r.stdout == expected, (
                            case, count, host, r.returncode, r.stderr[:500])
                        if sample >= 0:
                            samples[host].append(dict(elapsed_ms=elapsed, max_rss_kib=int(rss.read_text())))
                row = dict(case=case, files=count, code=code, samples=samples,
                           median_ms=[statistics.median(x['elapsed_ms'] for x in side) for side in samples],
                           median_rss_kib=[statistics.median(x['max_rss_kib'] for x in side) for side in samples],
                           output_sha256=hashlib.sha256(expected).hexdigest())
                rows.append(row)
                print(case, count, 'ms', row['median_ms'], 'KiB', row['median_rss_kib'], flush=True)
    assert hashes == [sha(x) for x in shells]
    report = dict(shells=[str(x) for x in shells], binary_sha256=hashes,
                  driver_sha256=sha(Path(__file__)), environment=env, cpu_affinity=sorted(os.sched_getaffinity(0)),
                  samples=args.samples, scope='fresh process including launch and full output; peak RSS from GNU time',
                  cases=rows)
    args.output.write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
