#!/usr/bin/env python3
"""Compare integer powers and unchanged floating controls in warm shell batches."""
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
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    os.sched_setaffinity(0, {a.cpu})
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    worker = Path(__file__).resolve().with_name('math-token-workload.zsh')
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = [*shells, worker, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    cases = [(text, 30000, 'normal') for text in
             ['0**0','2**0','2**1','2**2','2**3','2**8','(-2)**31','2**60',
              '1.25**2','0.0**2','2**-2','(-2)**3.0','2.0**0.5']]
    cases += [(text, 50, 'normal') for text in
              ['1**65536','1**1048576','0**1048576','(-1)**65537']]
    cases += [(text, 30000, 'float') for text in ['2**2','1**65536']]
    rows = []
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
    for expression, iterations, mode in cases:
        samples, states = [[], []], set()
        for sample in range(9):
            for host in ([0,1] if sample % 2 == 0 else [1,0]):
                command = [str(shells[host]), '-df', str(worker), expression, str(iterations), mode]
                result = subprocess.run(command, env=env, capture_output=True, timeout=120)
                if result.returncode or result.stderr:
                    raise RuntimeError((expression, host, result.returncode, result.stderr))
                elapsed, state = result.stdout.split(b'\n', 1)
                assert state
                samples[host].append(float(elapsed) * 1000)
                states.add(hashlib.sha256(state).hexdigest())
        assert len(states) == 1
        medians = [statistics.median(x) for x in samples]
        rows.append(dict(expression=expression, iterations=iterations, mode=mode,
                         samples_ms=samples, median_ms=medians, state_sha256=states.pop()))
        print(expression, mode, medians, flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, environment=env,
        cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9,
        scope='warm repeat batches including parser/dispatch; definition and warmup excluded',
        cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
