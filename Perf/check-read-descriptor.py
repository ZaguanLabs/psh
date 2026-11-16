#!/usr/bin/env python3
"""Check read -u against an inherited descriptor and independent file offset.

Out-of-range values must fail before reading. Ordinary descriptors, lexical
rejections and the documented coprocess spelling are recorded for comparison.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def run(shell, code, source, extra_fd, locale):
    source.seek(0)
    proc = subprocess.run(
        [str(shell), '-dfc', code, 'probe'],
        stdin=subprocess.DEVNULL, pass_fds=(extra_fd,), capture_output=True,
        env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, timeout=3)
    return proc, source.tell()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    bits = ctypes.sizeof(ctypes.c_int) * 8
    modulus = 1 << bits
    int_max = modulus // 2 - 1
    rows = []
    with tempfile.TemporaryFile() as source:
        source.write(b'XYZ')
        source.flush()
        fd = source.fileno()
        aliases = [str(modulus + fd), str(-modulus + fd), str(2 * modulus + fd)]
        # INT_MAX is representable but not an open descriptor here.  It must
        # not fault; the OS error leaves REPLY untouched.
        other_invalid = [str(int_max), str(int_max + 1), str(modulus - 1),
                         '-1', '9223372036854775807']
        controls = [str(fd), '+' + str(fd), '000' + str(fd),
                    str(fd) + 'x', str(fd) + ' ', '', 'p']
        for locale in ('C', 'C.UTF-8'):
            for kind, values in (('alias', aliases), ('invalid', other_invalid),
                                 ('control', controls)):
                for value in values:
                    source.seek(0)
                    source.truncate()
                    source.write(b'XYZ')
                    source.flush()
                    source.seek(0)
                    code = (
                        'REPLY=unchanged; '
                        'read -u "$1" -t 0 -k 1; '
                        'rc=$?; print -r -- "$rc|$REPLY"'
                    )
                    # The value is a shell argument, not an arithmetic expression.
                    proc = subprocess.run(
                        [str(shell), '-dfc', code, 'probe', value],
                        stdin=subprocess.DEVNULL, pass_fds=(fd,),
                        capture_output=True,
                        env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, timeout=3)
                    offset = source.tell()
                    reject = kind != 'control' or value in (str(fd) + 'x', str(fd) + ' ', '', 'p')
                    # 'p' without a coprocess is an existing error, not a range error.
                    if kind == 'control' and value in (str(fd), '+' + str(fd), '000' + str(fd)):
                        reject = False
                    passed = None
                    if kind == 'invalid' and value == str(int_max):
                        # Closed but representable.  read -k clears REPLY before
                        # the failed read; the shell must still survive and
                        # leave the inherited file offset alone.
                        passed = (proc.returncode == 0 and offset == 0 and
                                  proc.stdout == b'1|\n' and proc.stderr == b'')
                    elif kind != 'control':
                        passed = (proc.returncode == 0 and
                                  proc.stdout == b'1|unchanged\n' and
                                  b'file descriptor out of range:' in proc.stderr and
                                  offset == 0)
                    rows.append(dict(
                        locale=locale, kind=kind, value=value, reject=reject,
                        passed=passed, status=proc.returncode,
                        stdout=proc.stdout.decode(errors='backslashreplace'),
                        stderr=proc.stderr.decode(errors='backslashreplace'),
                        offset=offset))
    report = dict(
        shell=str(shell),
        sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
        int_bits=bits, fd=fd, cases=len(rows),
        checked=sum(r['kind'] != 'control' for r in rows),
        failures=sum(r['passed'] is False for r in rows),
        runs=rows)
    if args.reference:
        reference = json.loads(args.reference.read_text())
        previous = [r for r in reference['runs'] if r['kind'] == 'control']
        current = [r for r in rows if r['kind'] == 'control']
        differences = sum(a != b for a, b in zip(previous, current))
        differences += abs(len(previous) - len(current))
        report['controls'] = dict(cases=len(current), differences=differences)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))
    if args.require_pass and (report['failures'] or
                              report.get('controls', {}).get('differences', 0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
