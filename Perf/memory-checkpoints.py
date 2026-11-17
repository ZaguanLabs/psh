#!/usr/bin/env python3
"""Linux resident/private-memory checkpoints, with customer result verification."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import runpy
import selectors
import subprocess
import tempfile


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def memory(pid):
    result = {}
    for filename, prefix in [('smaps_rollup', ''), ('status', 'status_')]:
        for line in Path(f'/proc/{pid}/{filename}').read_text().splitlines():
            fields = line.split()
            if len(fields) == 3 and fields[2] == 'kB':
                result[prefix + fields[0].rstrip(':')] = int(fields[1])
    result['Private'] = result['Private_Clean'] + result['Private_Dirty']
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, action='append', required=True)
    parser.add_argument('--labs', type=Path, required=True)
    parser.add_argument('--challenge', type=Path, required=True)
    parser.add_argument('--case', action='append', required=True,
                        help='project/operation from customer-benchmark.py, or burst')
    parser.add_argument('--samples', type=int, default=3)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--trim-module', type=Path,
                        help='diagnostic only: matching-SDK memory_trim.so, one shell and burst case only')
    args = parser.parse_args()
    if args.samples < 1:
        parser.error('samples must be positive')
    if args.trim_module and (len(args.shell) != 1 or args.case != ['burst']):
        parser.error('trim probe requires exactly one matching shell and --case burst')
    base = Path(__file__).resolve().parent
    definitions = runpy.run_path(str(base / 'customer-benchmark.py'))
    metadata = runpy.run_path(str(base / 'customer-process-benchmark.py'))['input_metadata']
    cases = {f'{project}/{op}': (op, group, project, count)
             for op, group, project, count in definitions['CASES']}
    if set(args.case) - (set(cases) | {'burst'}):
        parser.error('unknown case')
    shells = [p.resolve(strict=True) for p in args.shell]
    wrapper = base / 'memory-checkpoints.zsh'
    worker = base / 'customer-workload.zsh'
    hashes = {str(p): sha(p) for p in [*shells, wrapper, worker, Path(__file__).resolve(),
                                      base / 'customer-benchmark.py', base / 'customer-process-benchmark.py']}
    if args.trim_module:
        args.trim_module = args.trim_module.resolve(strict=True)
        hashes[str(args.trim_module)] = sha(args.trim_module)
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8', 'LANG': 'C.UTF-8'}
    report = dict(identity=hashes, environment=env, samples=args.samples,
                  units='KiB', scope='Linux /proc checkpoints; live customer state retained; no timing claim', cases=[])
    with tempfile.TemporaryDirectory(prefix='psh-memory-') as temporary:
        scratch = Path(temporary)
        for case in args.case:
            burst = case == 'burst'
            op, group, project, count = cases.get(case, ('burst', 'labs', '.', 1))
            root = (getattr(args, group) / project).resolve(strict=True)
            inputs = {} if burst else metadata(root)
            row = dict(case=case, project_root=str(root), input_metadata=inputs, runs=[])
            expected = None
            for sample in range(args.samples):
                order = list(range(len(shells)))
                if sample % 2:
                    order.reverse()
                for host in order:
                    state_file = scratch / 'state'
                    command = [str(shells[host]), '-df', str(wrapper), str(worker),
                               op, str(root), str(count), str(state_file),
                               'burst' if burst else 'customer', str(args.trim_module or '')]
                    points = []
                    with (scratch / 'stderr').open('w+b') as errors:
                        proc = subprocess.Popen(command, env=env, stdin=subprocess.PIPE,
                                                stdout=subprocess.PIPE, stderr=errors)
                        try:
                            with selectors.DefaultSelector() as selector:
                                selector.register(proc.stdout, selectors.EVENT_READ)
                                while True:
                                    if not selector.select(120):
                                        raise RuntimeError(f'timeout: {case}, {host}')
                                    line = proc.stdout.readline()
                                    if not line:
                                        break
                                    phase = line.decode().strip()
                                    point = dict(phase=phase, memory=memory(proc.pid))
                                    if not burst and phase != 'startup':
                                        state = state_file.read_bytes()
                                        if phase == 'initial-workload':
                                            state = state.split(b'\n', 1)[1]
                                        if expected is None:
                                            expected = state
                                        if not state or state != expected:
                                            raise RuntimeError(f'state mismatch: {case}, {host}, {phase}')
                                        point['state_sha256'] = hashlib.sha256(state).hexdigest()
                                    points.append(point)
                                    proc.stdin.write(b'continue\n')
                                    proc.stdin.flush()
                            status = proc.wait(timeout=10)
                            errors.seek(0)
                            error = errors.read()
                            if status or error:
                                raise RuntimeError((command, status, error))
                        finally:
                            if proc.poll() is None:
                                proc.kill()
                                proc.wait()
                            proc.stdin.close()
                            proc.stdout.close()
                    phases = [p['phase'] for p in points]
                    wanted = (['startup', 'live-burst', 'released-burst', 'live-burst', 'released-second-burst']
                              if burst else ['startup', 'initial-workload', 'cycle-1', 'cycle-5', 'cycle-20'])
                    if args.trim_module:
                        wanted.insert(3, 'trimmed-burst')
                        wanted.append('trimmed-second-burst')
                    if phases != wanted:
                        raise RuntimeError(('missing checkpoints', phases))
                    row['runs'].append(dict(sample=sample, host=host, command=command, points=points))
                    print(case, sample, host, [(p['phase'], p['memory']['Rss'], p['memory']['Private']) for p in points], flush=True)
            if not burst and inputs != metadata(root):
                raise RuntimeError('customer inputs changed')
            report['cases'].append(row)
    if hashes != {p: sha(Path(p)) for p in hashes}:
        raise RuntimeError('measurement inputs changed')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
