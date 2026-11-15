#!/usr/bin/env python3
"""Characterize systell conversion, errors, evaluation and file state.

Uses seekable temporary stdin and an independently opened descriptor, plus
a pipe and a closed descriptor. Optional instrumented modules stay private.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    env = dict(PATH='/usr/bin:/bin', UBSAN_OPTIONS='halt_on_error=1:exitcode=86')
    setup = 'zmodload zsh/system || exit 90; '
    if args.modules:
        env['PSH_TEST_MODULES'] = str(args.modules.resolve())
        setup = 'module_path=("$PSH_TEST_MODULES"); ' + setup
    rows = []
    with tempfile.TemporaryFile() as source, tempfile.TemporaryFile() as other:
        source.write(b'abcdef'); source.flush()
        other.write(b'uvwxyz'); other.flush()
        fd = other.fileno()
        controls = ['0', '0.0', '-0.0', '0.9', '-0.9', '-0.9999999999999999',
                    str(fd), f'{fd}.9', f'({fd} + 0.25)',
                    '2147483647', '2147483647.0', '2147483647.9',
                    '-1', '-1.0', '-1.1', '-2147483648',
                    'x++', '++x', '(x += 0.9)', '(x += -0.9)',
                    '(x++, 0)', '0 ? systell(4294967296) : 0']
        invalid = ['2147483648', '4294967296', '-4294967296',
                   str(4294967296 + fd), str(-4294967296 + fd),
                   '9223372036854775807', '2147483648.0',
                   '4294967296.0', '-4294967296.0', '1e300', '-1e300',
                   'Inf', '-Inf', 'NaN']
        for locale in ('C', 'C.UTF-8'):
            for options in ('', 'setopt forcefloat; ', 'setopt cprecedences; '):
                for reject, expressions in ((False, controls), (True, invalid)):
                    for expression in expressions:
                        source.seek(2); other.seek(4)
                        code = (setup + options + 'x=0; '
                                'print -r -- $(( systell(' + expression + ') )); '
                                'print -r -- "x=$x"')
                        proc = subprocess.run([str(shell), '-dfc', code], stdin=source,
                                              pass_fds=(fd,), capture_output=True,
                                              env=dict(env, LC_ALL=locale), timeout=5)
                        unchanged = (source.tell(), other.tell()) == (2, 4)
                        safe = b'runtime error:' not in proc.stderr and unchanged
                        passed = safe and (not reject or
                                          (proc.returncode == 1 and not proc.stdout and
                                           b'file descriptor out of range' in proc.stderr))
                        rows.append(dict(locale=locale, options=options, expression=expression,
                                         reject=reject, passed=passed, status=proc.returncode,
                                         stdout=proc.stdout.decode(errors='backslashreplace'),
                                         stderr=proc.stderr.decode(errors='backslashreplace'),
                                         offsets=[source.tell(), other.tell()]))
        for label, code, input_data in [
            ('pipe', setup + 'print -r -- $(( systell(0) ))', b'X'),
            ('closed', setup + 'exec 9<&-; print -r -- $(( systell(9) ))', b'')]:
            proc = subprocess.run([str(shell), '-dfc', code], input=input_data,
                                  capture_output=True, env=dict(env, LC_ALL='C'), timeout=5)
            rows.append(dict(case=label, reject=False, passed=proc.returncode == 0 and
                             proc.stdout == b'-1\n' and not proc.stderr,
                             status=proc.returncode, stdout=proc.stdout.decode(),
                             stderr=proc.stderr.decode()))
    probe = subprocess.run([str(shell), '-dfc', setup + 'cat /proc/$$/maps; :'],
                           capture_output=True, env=env, check=True)
    modules = sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                      if line.endswith('/system.so')})
    if not modules or (args.modules and modules != [str(args.modules.resolve() / 'zsh/system.so')]):
        raise RuntimeError('Unexpected system module provenance: ' + repr(modules))
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in modules},
                  cases=len(rows), rejection_cases=sum(r['reject'] for r in rows),
                  failures=sum(not r['passed'] for r in rows), runs=rows)
    if args.reference:
        previous = [r for r in json.loads(args.reference.read_text())['runs'] if not r['reject']]
        current = [r for r in rows if not r['reject']]
        differences = sum(a != b for a, b in zip(previous, current)) + abs(len(previous)-len(current))
        report['controls'] = dict(cases=len(current), differences=differences,
                                  reference=str(args.reference))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))
    if args.require_pass and (report['failures'] or report.get('controls', {}).get('differences', 0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
