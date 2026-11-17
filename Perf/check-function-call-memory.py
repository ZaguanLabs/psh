#!/usr/bin/env python3
"""Compare live Linux memory during a batch of chpwd hooks or native callbacks."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import selectors
import subprocess

HERE = Path(__file__).resolve().parent
memory = runpy.run_path(str(HERE / 'memory-checkpoints.py'))['memory']


def sample(shell, module, length, mode):
    module_dir = str(module.parent) if module else ''
    command = [str(shell), '-df', str(HERE / 'function-call-memory.zsh'), module_dir, str(length), mode]
    points = {}
    with subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}) as proc:
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(proc.stdout, selectors.EVENT_READ)
                for phase in ('ready', 'inside', 'returned'):
                    if not selector.select(30):
                        raise RuntimeError(f'{shell}: timeout waiting for {phase}')
                    observed = proc.stdout.readline().strip()
                    if observed != phase.encode():
                        raise RuntimeError(f'{shell}: expected {phase}, got {observed!r}')
                    points[phase] = memory(proc.pid)
                    proc.stdin.write(b'continue\n')
                    proc.stdin.flush()
            output, errors = proc.communicate(timeout=15)
            if proc.returncode or output or errors:
                raise RuntimeError((command, proc.returncode, output, errors))
        finally:
            if proc.poll() is None:
                proc.kill()
    return dict(command=command, points=points)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', action='append', type=Path, required=True)
    p.add_argument('--module', action='append', type=Path, default=[],
                   help='matching SDK call_probe.so, in shell order (native mode)')
    p.add_argument('--output', required=True, type=Path)
    p.add_argument('--mode', choices=('native', 'chpwd'), required=True)
    args = p.parse_args()
    if len(args.shell) != 2:
        p.error('supply --shell twice, control first')
    if len(args.module) != (2 if args.mode == 'native' else 0):
        p.error('supply two modules for native mode or none for chpwd')
    shells = [shell.resolve(strict=True) for shell in args.shell]
    modules = [module.resolve(strict=True) for module in args.module]
    if any(module.name != 'call_probe.so' for module in modules):
        p.error('module must be named call_probe.so')
    hosts = list(zip(shells, modules or [None, None]))
    paths = shells + modules + [Path(__file__), HERE / 'function-call-memory.zsh', HERE / 'memory-checkpoints.py']
    if modules:
        paths.append(HERE / 'function-call-probe.c')
    def identities():
        return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    hashes = identities()
    rows = []
    for length in (24, 1024):
        for rep in range(3):
            for index in ((0, 1) if rep % 2 == 0 else (1, 0)):
                row = sample(*hosts[index], length, args.mode)
                rows.append(dict(host=index, length=length, sample=rep, **row))
    if identities() != hashes:
        raise RuntimeError('measurement input changed')
    args.output.write_text(json.dumps(dict(identity=hashes, samples=rows), indent=2)+'\n')


if __name__ == '__main__':
    main()
