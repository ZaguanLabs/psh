#!/usr/bin/env python3
"""Compare installed zdraw packages in their matching psh releases and real PTYs."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import tempfile


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def package(prefix):
    config = prefix/'bin/psh-config'
    def query(flag):
        return Path(subprocess.check_output([str(config), flag], text=True).strip())
    modules = query('--module-dir')
    draw = query('--script-dir')/'zdraw'
    files = [prefix/'bin/psh', modules/'zdraw.so', draw/'VERSION',
             *sorted((draw/'lib').rglob('*.zsh')), *sorted((draw/'lib').rglob('*.zwc'))]
    return dict(prefix=str(prefix), shell=str(files[0]), modules=str(modules), draw=str(draw),
                zdraw_version=(draw/'VERSION').read_text().strip(),
                file_sha256={str(p):sha(p) for p in files},
                file_mtime_ns={str(p):p.stat().st_mtime_ns for p in files})


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path, help='installed release prefix')
    p.add_argument('candidate', type=Path, help='installed release prefix')
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--frames', type=int, default=30)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.samples < 3 or not 1 <= a.frames <= 1000:
        p.error('at least three samples and 1..1000 frames required')
    os.sched_setaffinity(0, {a.cpu})
    os.environ['ZDRAW_TEST_LOCALE'] = 'C.UTF-8'
    source = Path(__file__).resolve().parent.parent/'Vendor/zdraw/benchmarks'
    spec = importlib.util.spec_from_file_location('zdraw_components', source/'components.py')
    driver = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(driver)
    packages = [package(x.resolve(strict=True)) for x in (a.baseline, a.candidate)]
    hashes = {str(x):sha(x) for x in [Path(__file__).resolve(), source/'components.py', source/'components.zsh']}
    rows = []
    with tempfile.TemporaryDirectory(prefix='psh-zdraw-benchmark-') as tmp:
        roots = []
        for number, entry in enumerate(packages):
            root = Path(tmp)/str(number)
            (root/'.build/zsh/Src').mkdir(parents=True)
            (root/'benchmarks').mkdir()
            (root/'.build/zsh/Src/zsh').symlink_to(entry['shell'])
            (root/'.build/modules').symlink_to(entry['modules'])
            (root/'lib').symlink_to(Path(entry['draw'])/'lib')
            shutil.copyfile(source/'components.zsh', root/'benchmarks/components.zsh')
            roots.append(root)
        for workload in driver.WORKLOADS:
            for pattern in ('repeated', 'changing'):
                for size in ('small', 'large'):
                    samples = [[], []]
                    expected = None
                    for sample in range(a.samples):
                        for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                            driver.ROOT = roots[host]
                            result = driver.trial(workload, pattern, size, a.frames, root=roots[host])
                            state = {key:result[key] for key in ('snapshot_sha256', 'output_sha256', 'output_bytes', 'resources')}
                            if expected is None: expected = state
                            assert state == expected, (workload, pattern, size, host, state, expected)
                            samples[host].append(result)
                    medians = [{key:statistics.median(x[key] for x in side)
                                for key in ('work_ms', 'stage_ms', 'present_ms', 'output_bytes')}
                               for side in samples]
                    rows.append(dict(workload=workload, pattern=pattern, size=size, samples=samples,
                                     medians=medians, state=expected))
                    print(workload, pattern, size, 'work ms', [x['work_ms'] for x in medians], flush=True)
    assert packages == [package(Path(x['prefix'])) for x in packages]
    assert hashes == {name:sha(Path(name)) for name in hashes}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(packages=packages, source_sha256=hashes,
        cpu_affinity=sorted(os.sched_getaffinity(0)), locale='C.UTF-8', terminal='xterm-256color',
        terminal_size=[24, 80], samples=a.samples, frames=a.frames,
        scope='component work per frame; staging/presentation separately timed; no full app or emulator paint claim',
        cases=rows), indent=2)+'\n')


if __name__ == '__main__':
    main()
