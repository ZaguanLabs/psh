#!/usr/bin/env python3
"""Measure fresh customer kernel processes, including source parsing and output."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import runpy
import shutil
import statistics
import subprocess
import tempfile
import time


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def input_metadata(root):
    paths = [p for folder in ('lib', 'levels') for p in (root/folder).glob('*')
             if p.is_file() and (p.name.endswith('.zsh') or p.name.endswith('.zwc'))]
    return {str(p.relative_to(root)): dict(sha256=sha(p), mtime_ns=p.stat().st_mtime_ns,
                                         size=p.stat().st_size) for p in sorted(paths)}


def copy_text(root, destination):
    for folder in ('lib', 'levels'):
        (destination/folder).mkdir(parents=True, exist_ok=True)
        for source in (root/folder).glob('*.zsh'):
            shutil.copyfile(source, destination/folder/source.name)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--labs', type=Path, required=True)
    p.add_argument('--challenge', type=Path, required=True)
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--source-only', action='store_true',
                   help='use private text copies without changing customer bytecode caches')
    a = p.parse_args()
    if a.samples < 3: p.error('at least three samples required')
    os.sched_setaffinity(0, {a.cpu})
    definitions = Path(__file__).with_name('customer-benchmark.py')
    existing = runpy.run_path(str(definitions))
    worker = definitions.with_name('customer-workload.zsh').resolve()
    shells = [x.resolve(strict=True) for x in (a.baseline, a.candidate)]
    hashes = [sha(x) for x in [*shells, worker, definitions]]
    rows = []
    env = {'PATH':'/usr/bin:/bin', 'LC_ALL':'C.UTF-8', 'LANG':'C.UTF-8'}
    with tempfile.TemporaryDirectory(prefix='psh-customer-process-') as tmp:
        rss = Path(tmp)/'rss'
        for operation, group, project, iterations in existing['CASES']:
            root = (getattr(a, group)/project).resolve(strict=True)
            sources = existing['source_hashes'](root)
            inputs = input_metadata(root)
            execution_root = root
            if a.source_only:
                execution_root = Path(tmp)/group/project
                copy_text(root, execution_root)
            samples = [[], []]
            state = None
            if a.source_only:
                # The private text copy must preserve the current cached workload's result.
                check = subprocess.run([str(shells[0]), '-df', str(worker), operation, str(root), str(iterations)],
                                       env=env, capture_output=True, timeout=120)
                assert check.returncode == 0 and not check.stderr
                state = check.stdout.split(b'\n', 1)[1]
            for sample in range(-1, a.samples):
                for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                    cmd = ['/usr/bin/time', '-f', '%M', '-o', str(rss), str(shells[host]),
                           '-df', str(worker), operation, str(execution_root), str(iterations)]
                    start = time.perf_counter_ns()
                    r = subprocess.run(cmd, env=env, capture_output=True, timeout=120)
                    elapsed = (time.perf_counter_ns()-start)/1e6
                    assert r.returncode == 0 and not r.stderr, (cmd, r.returncode, r.stderr)
                    _, observed = r.stdout.split(b'\n', 1)
                    if state is None: state = observed
                    assert observed and observed == state, (project, operation, host)
                    if sample >= 0:
                        samples[host].append(dict(elapsed_ms=elapsed, max_rss_kib=int(rss.read_text())))
            assert sources == existing['source_hashes'](root)
            assert inputs == input_metadata(root)
            row = dict(case=f'{project}/{operation}', project_root=str(root), source_sha256=sources,
                       input_metadata=inputs, source_only=a.source_only,
                       iterations=iterations, samples=samples,
                       median_ms=[statistics.median(x['elapsed_ms'] for x in side) for side in samples],
                       median_rss_kib=[statistics.median(x['max_rss_kib'] for x in side) for side in samples],
                       state_sha256=hashlib.sha256(state).hexdigest())
            rows.append(row)
            print(row['case'], row['median_ms'], row['median_rss_kib'], flush=True)
    assert hashes == [sha(x) for x in [*shells, worker, definitions]]
    a.output.write_text(json.dumps(dict(shells=list(map(str,shells)), binary_sha256=hashes[:2],
        worker_sha256=hashes[2], case_definitions_sha256=hashes[3], driver_sha256=sha(Path(__file__)),
        samples=a.samples, environment=env, cpu_affinity=sorted(os.sched_getaffinity(0)),
        source_only=a.source_only,
        scope='fresh kernel process: loading, setup, warmup, operation, validation and output; not a full app launch',
        cases=rows), indent=2)+'\n')


if __name__ == '__main__':
    main()
