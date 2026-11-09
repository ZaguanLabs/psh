#!/usr/bin/env python3
"""Time native hashing by raw byte length with identical digests."""
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
    p.add_argument('--headers-build', type=Path, default=Path('.work/baseline'))
    p.add_argument('--headers-source', type=Path, default=Path('.work/pristine'))
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    os.sched_setaffinity(0, {a.cpu})
    a.output.parent.mkdir(parents=True, exist_ok=True)
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    source = Path(__file__).resolve().with_name('hash-module.c')
    module = folder / 'psh_hash_fixture.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
        '-I' + str(a.headers_build.resolve(strict=True) / 'Src'),
        '-I' + str(a.headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module)]
    # Prepare the fixture before the first timed call; no build runs in parallel.
    subprocess.run(command, check=True)
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = [*shells, source, module, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}
    script = 'module_path=("$1"); zmodload psh_hash_fixture || exit 1; psh-hash-bench "$2" "$3" || exit 2'
    rows = []
    for length in [0,1,2,3,4,7,8,15,16,31,32,63,64,257,4096]:
        n = max(10000, min(3000000, 24000000 // max(1, length)))
        times = [[], []]
        for sample in range(9):
            for host in ([0,1] if sample % 2 == 0 else [1,0]):
                r = subprocess.run([str(shells[host]), '-dfc', script, 'comparison', str(folder), str(length), str(n)],
                    env=env, capture_output=True, timeout=30)
                if r.returncode or r.stderr:
                    raise RuntimeError((length, host, r.returncode, r.stderr))
                elapsed, value, bits = r.stdout.split()
                mask = (1 << int(bits)) - 1
                expected = 0
                for i in range(length):
                    expected = (expected * 33 + (i * 37 + 17) % 255 + 1) & mask
                assert int(value) == expected * n & mask
                times[host].append(float(elapsed) * 1000)
        medians = [statistics.median(x) for x in times]
        rows.append(dict(length=length, iterations=n, samples_ms=times, median_ms=medians))
        print(length, medians, flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, compile_command=command,
        environment=env, cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9,
        scope='hot repeated native calls; allocation and module load excluded', cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
