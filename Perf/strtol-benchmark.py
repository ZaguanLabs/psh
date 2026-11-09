#!/usr/bin/env python3
"""Measure short decimal conversion and fallback controls through the public API."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    root = Path(__file__).resolve().parent.parent
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--headers-build', type=Path, required=True)
    p.add_argument('--headers-source', type=Path, required=True)
    p.add_argument('--cpu', type=int)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    folder = a.output.resolve().with_suffix(''); folder.mkdir(exist_ok=True)
    source = root / 'Perf/strtol-benchmark-module.c'; module = folder / 'psh_strtol_bench.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
        '-I' + str(a.headers_build.resolve() / 'Src'), '-I' + str(a.headers_source.resolve() / 'Src'), str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    if a.cpu is not None:
        os.sched_setaffinity(0, {a.cpu})
    shells = [x.resolve(strict=True) for x in [a.baseline, a.candidate]]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    fingerprints = {str(p): sha(p) for p in [*shells, module, source]}
    rows = []
    for name in ['short', 'nine', 'ten', 'eighteen', 'signed', 'underscores', 'base16', 'base0', 'nondigit', 'nineteen']:
        samples, states = [[], []], set()
        for sample in range(9):
            for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                r = subprocess.run([str(shells[host]), '-dfc', 'module_path=("$1"); zmodload psh_strtol_bench || exit; psh-strtol-bench "$2"', 'benchmark', str(folder), name],
                    env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}, capture_output=True, timeout=30)
                assert r.returncode == 0 and not r.stderr, (name, r.stderr)
                elapsed, state = r.stdout.split(b'\n', 1)
                samples[host].append(int(elapsed) / 1000000); states.add(state)
        assert len(states) == 1, name
        medians = [statistics.median(x) for x in samples]
        rows.append(dict(case=name, calls=1000000, samples_ms=samples, median_ms=medians, digest=states.pop().decode().strip()))
        print(name, medians, flush=True)
    assert fingerprints == {p: sha(Path(p)) for p in fingerprints}
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, compile_command=command, cpu_affinity=sorted(os.sched_getaffinity(0)), cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
