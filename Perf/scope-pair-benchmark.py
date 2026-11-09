#!/usr/bin/env python3
"""Compare scope cleanup with paired samples and matching prebuilt observers."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--baseline-module-dir', type=Path, required=True)
    p.add_argument('--candidate-module-dir', type=Path, required=True)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--iterations', type=int, default=4000)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.iterations < 1:
        p.error('--iterations must be positive')
    os.sched_setaffinity(0, {a.cpu})
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    modules = [(d.resolve(strict=True) / 'psh_scope_observer.so') for d in
               [a.baseline_module_dir, a.candidate_module_dir]]
    root = Path(__file__).resolve().parent
    worker = root / 'scope-workload.zsh'
    inputs = [*shells, *modules, worker, root / 'scope-observer-module.c', Path(__file__).resolve()]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    fingerprints = {str(p): sha(p) for p in inputs}
    cases = [(size, occupancy, mode)
             for size in [0, 512, 4096, 16384]
             for occupancy in ['dense', 'sparse'] if size or occupancy == 'dense'
             for mode in ['loop', 'empty', 'local1', 'local8', 'emulate', 'nested']]
    samples = {case: [[], []] for case in cases}
    states = {case: set() for case in cases}
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8', 'LANG': 'C.UTF-8'}
    order = []
    for sample in range(9):
        rotated = cases[sample:] + cases[:sample]
        if sample % 2:
            rotated.reverse()
        order.append(rotated)
        for case in rotated:
            size, occupancy, mode = case
            for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                command = [str(shells[host]), '-df', str(worker), str(size), str(a.iterations),
                           mode, occupancy, str(modules[host].parent)]
                result = subprocess.run(command, env=env, capture_output=True, timeout=120)
                if result.returncode or result.stderr:
                    raise RuntimeError((case, host, result.returncode, result.stdout, result.stderr))
                elapsed, before, after = result.stdout.splitlines()
                state = json.loads(before)
                assert before == after and state['visible'] == state['count']
                assert state['level'] == 0 and state['local'] == 0
                samples[case][host].append(float(elapsed) * 1000)
                states[case].add(before)
        print('Completed paired sample', sample + 1, 'of 9', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    rows = []
    for case in cases:
        assert len(states[case]) == 1
        medians = [statistics.median(s) for s in samples[case]]
        size, occupancy, mode = case
        rows.append(dict(padding=size, occupancy=occupancy, mode=mode,
                         iterations=a.iterations, samples_ms=samples[case], median_ms=medians,
                         median_us_per_iteration=[m * 1000 / a.iterations for m in medians],
                         table=json.loads(states[case].pop())))
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, environment=env,
        cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9, sample_order=order,
        scope='paired warm batches; setup, warmup, table observation and validation excluded',
        cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
