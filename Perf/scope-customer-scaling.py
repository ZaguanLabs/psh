#!/usr/bin/env python3
"""Measure existing editor kernels with unrelated global bindings present."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shell', type=Path)
    p.add_argument('--module-dir', type=Path, required=True)
    p.add_argument('--labs', type=Path, required=True)
    p.add_argument('--cpu', type=int, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    os.sched_setaffinity(0, {a.cpu})
    root = Path(__file__).resolve().parent
    spec = importlib.util.spec_from_file_location('customer', root / 'customer-benchmark.py')
    customer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(customer)
    projects = {'coder-paste': a.labs.resolve() / 'zcoder.zsh',
                'chat-paste': a.labs.resolve() / 'zchat.zsh'}
    source_hashes = {name: customer.source_hashes(path) for name, path in projects.items()}
    shell = a.shell.resolve(strict=True)
    worker = root / 'customer-workload.zsh'
    wrapper = root / 'scope-customer-workload.zsh'
    module = a.module_dir.resolve(strict=True) / 'psh_scope_observer.so'
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = [shell, worker, wrapper, module, root / 'scope-observer-module.c',
              Path(__file__).resolve(), root / 'customer-benchmark.py']
    fingerprints = {str(p): sha(p) for p in inputs}
    cases = [(name, padding) for name in projects for padding in [0, 512]]
    samples = {case: [] for case in cases}
    states = {name: set() for name in projects}
    tables = {case: set() for case in cases}
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8', 'LANG': 'C.UTF-8'}
    for sample in range(9):
        for name, padding in (cases if sample % 2 == 0 else list(reversed(cases))):
            command = [str(shell), '-df', str(wrapper), str(padding), str(module.parent),
                       str(worker), name, str(projects[name]), '1']
            result = subprocess.run(command, env=env, capture_output=True, timeout=120)
            if result.returncode or result.stderr:
                raise RuntimeError((name, padding, result.returncode, result.stderr))
            output, table = result.stdout.split(b'\n__psh_scope_table__\n')
            elapsed, state = output.split(b'\n', 1)
            assert state
            counts = json.loads(table)
            assert counts['count'] == counts['visible'] and counts['local'] == counts['level'] == 0
            samples[name, padding].append(float(elapsed) * 1000)
            states[name].add(hashlib.sha256(state).hexdigest())
            tables[name, padding].add(table)
        print('Completed project sample', sample + 1, 'of 9', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    assert source_hashes == {name: customer.source_hashes(path) for name, path in projects.items()}
    rows = []
    for name in projects:
        assert len(states[name]) == 1
        for padding in [0, 512]:
            assert len(tables[name, padding]) == 1
        counts = [json.loads(tables[name, padding].pop()) for padding in [0, 512]]
        assert counts[1]['count'] - counts[0]['count'] == 512
        rows.append(dict(case=name, padding=[0, 512],
            samples_ms=[samples[name, padding] for padding in [0, 512]],
            median_ms=[statistics.median(samples[name, padding]) for padding in [0, 512]],
            table=counts, state_sha256=states[name].pop(), source_sha256=source_hashes[name]))
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(fingerprints=fingerprints, environment=env,
        cpu_affinity=sorted(os.sched_getaffinity(0)), samples=9,
        scope='existing warm project timer; global padding and final observations excluded',
        cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
