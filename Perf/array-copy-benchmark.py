#!/usr/bin/env python3
"""Time bounded array copies and unchanged controls, comparing complete states."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.samples < 3: p.error('at least three samples required')
    os.sched_setaffinity(0, {a.cpu})
    shells = [s.resolve(strict=True) for s in (a.baseline,a.candidate)]
    worker = Path(__file__).with_name('array-copy-workload.zsh').resolve()
    hashes = [sha(x) for x in [*shells,worker]]
    rows = []
    env = {'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'}
    for size in (32,4096,32768):
        for operation in ('prefix','middle','full','negative','beyond'):
            iterations = 50 if operation == 'full' else 1000
            samples = [[],[]]
            state = None
            for sample in range(a.samples):
                for host in ([0,1] if sample%2 == 0 else [1,0]):
                    cmd = [str(shells[host]),'-df',str(worker),operation,str(size),str(iterations)]
                    r = subprocess.run(cmd,env=env,capture_output=True,timeout=120)
                    if r.returncode or r.stderr: raise RuntimeError((cmd,r.returncode,r.stderr))
                    elapsed,observed = r.stdout.split(b'\n',1)
                    if state is None: state = observed
                    assert observed == state,(operation,size,host)
                    samples[host].append(float(elapsed)*1000)
            medians = list(map(statistics.median,samples))
            rows.append(dict(operation=operation,size=size,iterations=iterations,samples_ms=samples,
                             median_ms=medians,state_sha256=hashlib.sha256(state).hexdigest()))
            print(operation,size,'ms',medians,flush=True)
    assert hashes == [sha(x) for x in [*shells,worker]]
    a.output.write_text(json.dumps(dict(shells=list(map(str,shells)),binary_sha256=hashes[:2],
                                      worker_sha256=hashes[2],driver_sha256=sha(Path(__file__)),
                                      samples=a.samples,environment=env,cpu_affinity=sorted(os.sched_getaffinity(0)),
                                      cases=rows),indent=2)+'\n')


if __name__ == '__main__': main()
