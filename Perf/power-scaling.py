#!/usr/bin/env python3
"""Measure the existing integer-power algorithm using non-overflowing bases."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shell', type=Path)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    os.sched_setaffinity(0, {a.cpu})
    shell = a.shell.resolve(strict=True)
    worker = Path(__file__).resolve().with_name('power-workload.zsh')
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = [shell, worker, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    cases = [(base, exponent) for base in [0, 1, -1]
             for exponent in [0, 1, 2, 8, 64, 1024, 65536, 1048576]]
    samples = {case: [] for case in cases}
    states = {case: set() for case in cases}
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8', 'LANG': 'C.UTF-8'}
    for sample in range(9):
        rotated = cases[sample:] + cases[:sample]
        if sample % 2:
            rotated.reverse()
        for base, exponent in rotated:
            command = [str(shell), '-df', str(worker), str(base), str(exponent), '50']
            result = subprocess.run(command, env=env, capture_output=True, timeout=120)
            if result.returncode or result.stderr:
                raise RuntimeError((base, exponent, result.returncode, result.stderr))
            elapsed, state = result.stdout.split(b'\n', 1)
            samples[base, exponent].append(float(elapsed) * 1000)
            states[base, exponent].add(hashlib.sha256(state).hexdigest())
        print('Completed power sample', sample + 1, 'of 9', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    rows = []
    for base, exponent in cases:
        assert len(states[base, exponent]) == 1
        median = statistics.median(samples[base, exponent])
        rows.append(dict(base=base, exponent=exponent, iterations=50,
                         samples_ms=samples[base, exponent], median_ms=median,
                         median_us_per_power=median * 1000 / 50,
                         state_sha256=states[base, exponent].pop()))
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, environment=env,
        cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9,
        scope='warm arithmetic batches; setup, warmup and validation excluded',
        cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
