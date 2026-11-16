#!/usr/bin/env python3
"""Profile a real customer kernel with an explicitly selected private release."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--labs', type=Path, required=True)
    parser.add_argument('--challenge', type=Path, required=True)
    parser.add_argument('--case', action='append', required=True,
                        help='project/operation from Perf/customer-benchmark.py')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    definitions = root / 'customer-benchmark.py'
    cases = runpy.run_path(str(definitions))['CASES']
    selected = {f'{project}/{operation}': (operation, group, project, iterations)
                for operation, group, project, iterations in cases}
    unknown = set(args.case) - selected.keys()
    if unknown:
        parser.error('unknown cases: ' + ', '.join(sorted(unknown)))
    process_helpers = runpy.run_path(str(root / 'customer-process-benchmark.py'))
    shell = args.shell.resolve(strict=True)
    worker = (root / 'customer-workload.zsh').resolve(strict=True)
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    rows = []
    for label in args.case:
        operation, group, project, iterations = selected[label]
        project_root = (getattr(args, group) / project).resolve(strict=True)
        sources = process_helpers['source_hashes'](project_root) \
            if 'source_hashes' in process_helpers else {}
        if not sources:
            sources = {str(path.relative_to(project_root)): sha(path)
                       for folder in ('lib', 'levels')
                       for path in sorted((project_root / folder).glob('*.zsh'))}
        inputs = process_helpers['input_metadata'](project_root)
        prefix = output / label.replace('/', '-').replace('.', '-')
        profile = prefix.with_suffix('.callgrind')
        command = ['valgrind', '--tool=callgrind',
                   '--callgrind-out-file=' + str(profile), str(shell), '-df',
                   str(worker), operation, str(project_root), str(iterations)]
        proc = subprocess.run(command, env={'PATH': '/usr/bin:/bin',
                                           'LC_ALL': 'C.UTF-8'},
                              capture_output=True, timeout=300)
        prefix.with_suffix('.stdout').write_bytes(proc.stdout)
        prefix.with_suffix('.stderr').write_bytes(proc.stderr)
        if proc.returncode:
            raise RuntimeError((label, proc.returncode,
                                proc.stderr[-1000:].decode(errors='replace')))
        elapsed, state = proc.stdout.split(b'\n', 1)
        if not state:
            raise RuntimeError(label + ': missing resulting state')
        annotate = subprocess.run(
            ['callgrind_annotate', '--auto=no', '--inclusive=no',
             '--tree=caller', '--threshold=100', str(profile)],
            capture_output=True, check=True, timeout=120)
        prefix.with_suffix('.callers').write_bytes(annotate.stdout)
        summary = next(line.split(':', 1)[1].strip()
                       for line in profile.read_text().splitlines()
                       if line.startswith('summary:'))
        if sources != {str(path.relative_to(project_root)): sha(path)
                       for folder in ('lib', 'levels')
                       for path in sorted((project_root / folder).glob('*.zsh'))}:
            raise RuntimeError(label + ': source changed while profiling')
        if inputs != process_helpers['input_metadata'](project_root):
            raise RuntimeError(label + ': inputs changed while profiling')
        rows.append(dict(case=label, command=command, profile=str(profile),
                         instructions=int(summary), iterations=iterations,
                         project_root=str(project_root),
                         source_sha256=sources, input_metadata=inputs,
                         stdout_sha256=sha(prefix.with_suffix('.stdout')),
                         state_sha256=hashlib.sha256(state).hexdigest()))
        print(label, summary, hashlib.sha256(state).hexdigest(), flush=True)
    report = dict(shell=str(shell), binary_sha256=sha(shell),
                  worker_sha256=sha(worker),
                  case_definitions_sha256=sha(definitions),
                  driver_sha256=sha(Path(__file__)),
                  scope='fresh profiling process, including loading, setup, operation, validation and output; not elapsed timing',
                  environment={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'},
                  cases=rows)
    (output / 'profile.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
