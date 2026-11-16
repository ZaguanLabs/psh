#!/usr/bin/env python3
"""Check print -u against an inherited descriptor and independent file data.

Out-of-range values must fail before writing. Ordinary descriptors, lexical
rejections and the undocumented coprocess spelling are recorded for comparison.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def semantic(row, fd):
    result = {key: value for key, value in row.items()
              if key not in ('value', 'passed')}
    result['stderr'] = result['stderr'].replace(str(fd), '{fd}')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    bits = ctypes.sizeof(ctypes.c_int) * 8
    modulus = 1 << bits
    int_max = modulus // 2 - 1
    rows = []
    code = (
        'print -u "$1" -rn -- SENTINEL; '
        'rc=$?; print -r -- "$rc"'
    )
    with tempfile.TemporaryFile() as sink:
        fd = sink.fileno()
        aliases = [str(modulus + fd), str(-modulus + fd),
                   str(2 * modulus + fd)]
        invalid = [str(int_max + 1), str(modulus - 1), '-1',
                   '9223372036854775807', '-9223372036854775808']
        controls = [str(fd), '+' + str(fd), '000' + str(fd),
                    str(fd) + 'x', str(fd) + ' ', '', 'p']
        groups = [('alias', aliases), ('invalid', invalid),
                  ('closed', [str(int_max)]), ('control', controls)]
        for locale in ('C', 'C.UTF-8'):
            for kind, values in groups:
                for value in values:
                    sink.seek(0)
                    sink.truncate()
                    sink.flush()
                    proc = subprocess.run(
                        (['valgrind', '--error-exitcode=97', '--leak-check=no',
                          '--track-origins=yes'] if args.memcheck else []) +
                        [str(shell), '-dfc', code, 'probe', value],
                        stdin=subprocess.DEVNULL, pass_fds=(fd,),
                        capture_output=True,
                        env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale},
                        timeout=3)
                    sink.seek(0)
                    payload = sink.read()
                    passed = None
                    if kind in ('alias', 'invalid'):
                        passed = (proc.returncode == 0 and
                                  proc.stdout == b'1\n' and
                                  b'file descriptor out of range:' in proc.stderr and
                                  payload == b'')
                    rows.append(dict(
                        locale=locale, kind=kind, value=value, passed=passed,
                        status=proc.returncode,
                        stdout=proc.stdout.decode(errors='backslashreplace'),
                        stderr=proc.stderr.decode(errors='backslashreplace'),
                        output=payload.decode(errors='backslashreplace')))
    report = dict(
        shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
        int_bits=bits, fd=fd, cases=len(rows), memcheck=args.memcheck,
        checked=sum(r['kind'] in ('alias', 'invalid') for r in rows),
        failures=sum(r['passed'] is False for r in rows), runs=rows)
    if args.reference:
        reference = json.loads(args.reference.read_text())
        previous = [r for r in reference['runs'] if r['kind'] != 'alias' and
                    r['kind'] != 'invalid']
        current = [r for r in rows if r['kind'] != 'alias' and
                   r['kind'] != 'invalid']
        previous = [semantic(r, reference['fd']) for r in previous]
        current = [semantic(r, fd) for r in current]
        report['controls'] = dict(
            cases=len(current),
            differences=sum(a != b for a, b in zip(previous, current)) +
            abs(len(previous) - len(current)))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'runs'}))
    if args.require_pass and (report['failures'] or
                              report.get('controls', {}).get('differences', 0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
