#!/usr/bin/env python3
"""Compare direct arithmetic calls, native callbacks, classification and traps."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shells', type=Path, nargs='+')
    p.add_argument('--headers-build', type=Path, required=True)
    p.add_argument('--headers-source', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    a = p.parse_args()
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).resolve().with_name('math-counter-module.c')
    module = folder / 'psh_math_counter_fixture.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I' + str(a.headers_build.resolve() / 'Src'),
               '-I' + str(a.headers_source.resolve() / 'Src'),
               str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    script = '''module_path=("$1"); zmodload psh_math_counter_fixture || exit 2
TRAPUSR1() { typeset -g psh_counter_signal_value=$i; }
psh-math-counter-check || exit 3
print -r -- signal-value=$psh_counter_signal_value
[[ $psh_counter_signal_value == 42 ]] || exit 4
zmodload -u psh_math_counter_fixture || exit 5
'''
    rows, observations = [], []
    for shell in [s.resolve(strict=True) for s in a.shells]:
        cmd = [str(shell), '-dfc', script, 'math-counter-native', str(folder)]
        if a.memcheck:
            cmd = ['valgrind', '--quiet', '--track-origins=yes', '--error-exitcode=97', *cmd]
        r = subprocess.run(cmd, capture_output=True, timeout=120,
                           env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'})
        observations.append((r.returncode, r.stdout, r.stderr))
        rows.append({'shell': str(shell), 'command': cmd,
                     'binary_sha256': hashlib.sha256(shell.read_bytes()).hexdigest(),
                     'status': r.returncode, 'stdout': r.stdout.decode(errors='replace'),
                     'stderr': r.stderr.decode(errors='replace')})
    passed = (len(rows) >= 2 and len(set(observations)) == 1
              and observations[0][0] == 0 and not observations[0][2]
              and observations[0][1].count(b'failed=0') == 8
              and observations[0][1].endswith(b'signal-value=42\n'))
    report = {'compile_command': command, 'memcheck': a.memcheck, 'runs': rows,
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'module_sha256': hashlib.sha256(module.read_bytes()).hexdigest(), 'passed': passed}
    a.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"native math counters: passed={passed}")
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
