#!/usr/bin/env python3
"""Compare nested associative-array getter state."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('shells', type=Path, nargs='+')
    parser.add_argument('--headers-build', type=Path, required=True)
    parser.add_argument('--headers-source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--memcheck', action='store_true')
    args = parser.parse_args()
    folder = args.output.resolve().with_suffix('')
    folder.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).resolve().with_name('hash-reentry-module.c')
    module = folder / 'psh_hash_reentry.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I' + str(args.headers_build.resolve() / 'Src'),
               '-I' + str(args.headers_source.resolve() / 'Src'),
               str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    script = ('module_path=("$1"); zmodload psh_hash_reentry || exit 2; '
              'psh-hash-reentry-check || exit 3; '
              'zmodload -u psh_hash_reentry || exit 4')
    rows = []
    for shell in [s.resolve(strict=True) for s in args.shells]:
        cmd = [str(shell), '-dfc', script, 'native-hash-reentry', str(folder)]
        if args.memcheck:
            cmd = ['valgrind', '--quiet', '--track-origins=yes', '--error-exitcode=97', *cmd]
        r = subprocess.run(cmd, capture_output=True, timeout=120,
                           env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'})
        rows.append({'shell': str(shell), 'binary_sha256': hashlib.sha256(shell.read_bytes()).hexdigest(),
                     'command': cmd, 'status': r.returncode,
                     'stdout': r.stdout.decode(errors='replace'), 'stderr': r.stderr.decode(errors='replace')})
    passed = (bool(rows)
              and all(r['status'] == 0 and not r['stderr'] and
                      r['stdout'] == ('count=2 calls=1 ok=1\n'
                                      'pattern-ok=1\n'
                                      'matrix-checks=12 ok=1\n'
                                      'boundary-checks=2 ok=1\n') for r in rows))
    report = {'compile_command': command, 'memcheck': args.memcheck, 'runs': rows,
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'module_sha256': hashlib.sha256(module.read_bytes()).hexdigest(), 'passed': passed}
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"native hash reentry: passed={passed}")
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
