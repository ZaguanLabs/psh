#!/usr/bin/env python3
"""Time arithmetic tokens with short/long integer and fallback controls."""
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
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
    rows = []
    for expression in ['1','99','123456','999999999999999999','1234567890123456789',
                       '-9','0','01','1.25','0.125','1_000','16#ff','1e2']:
        for mode in ['normal','float']:
            samples = [[], []]
            states = set()
            for sample in range(9):
                for host in ([0,1] if sample % 2 == 0 else [1,0]):
                    r = subprocess.run([str(shells[host]), '-df', str(worker), expression, '30000', mode],
                        env=env, capture_output=True, timeout=60)
                    if r.returncode or r.stderr:
                        raise RuntimeError((expression, mode, host, r.returncode, r.stdout, r.stderr))
                    elapsed, state = r.stdout.split(b'\n', 1)
                    assert state
                    samples[host].append(float(elapsed) * 1000)
                    states.add(hashlib.sha256(state).hexdigest())
            assert len(states) == 1, (expression, mode)
            medians = [statistics.median(x) for x in samples]
            rows.append(dict(expression=expression, mode=mode, iterations=30000,
                             samples_ms=samples, median_ms=medians, state_sha256=states.pop()))
            print(expression, mode, medians, flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, environment=env,
        cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9,
        scope='warm shell repeat batches; definition and warmup excluded', cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
