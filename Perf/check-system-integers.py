#!/usr/bin/env python3
"""Check zsh/system integer arguments against independent file/offset state.

Out-of-range cases must fail before I/O. In-range and lexical controls are
recorded for exact comparison with the preceding build. No large read buffers
are requested from the unfixed controls.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path,
                        help='compare lexical/in-range controls with a saved report')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    bits = ctypes.sizeof(ctypes.c_int) * 8
    modulus = 1 << bits
    int_max = modulus // 2 - 1
    rows = []
    commands = {
        'read-i': 'sysread -i "$1" -s 1 -c count result',
        'read-o': 'sysread -o "$1" -s 1 -c count result',
        'read-s': 'sysread -s "$1" -c count result',
        'write-o': 'syswrite -o "$1" -c count Z',
        'seek-u': 'sysseek -u "$1" 2',
    }
    for locale in ('C', 'C.UTF-8'):
        for mode, command in commands.items():
            with tempfile.TemporaryFile() as source, tempfile.TemporaryFile() as dest:
                fd = dest.fileno()
                alias = fd if mode in ('read-o', 'write-o') else (1 if mode == 'read-s' else 0)
                invalid = [str(modulus + alias), str(2 * modulus + alias),
                           str(-modulus + alias), str(-2 * modulus + alias), '-1']
                # FD boundaries are safe: there cannot be an open INT_MAX FD
                # in this bounded child. Avoid enormous allocations for -s.
                if mode != 'read-s':
                    invalid += [str(int_max + 1), str(modulus - 1),
                                '9223372036854775807', '9223372036854775808',
                                '18446744073709551616']
                controls = [str(alias), '+' + str(alias), '  ' + str(alias),
                            '000' + str(alias), str(alias) + 'x',
                            str(alias) + '_0', str(alias) + ' ', '', '+', '-']
                if mode != 'read-s':
                    controls.append(str(int_max))
                else:
                    controls += ['0', '2', '8']
                for reject, values in ((True, invalid), (False, controls)):
                    for value in values:
                        source.seek(0)
                        source.truncate()
                        source.write(b'ABC')
                        source.flush()
                        source.seek(0)
                        dest.seek(0)
                        dest.truncate()
                        dest.write(b'KEEP')
                        dest.flush()
                        dest.seek(0)
                        code = ('zmodload zsh/system || exit 90; '
                                'result=unchanged; count=unchanged; ' + command +
                                '; rc=$?; print -r -- "$rc|$result|$count"')
                        proc = subprocess.run(
                            [str(shell), '-dfc', code, 'probe', value],
                            stdin=source, pass_fds=(fd,), capture_output=True,
                            env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, timeout=5)
                        input_offset = source.tell()
                        output_offset = dest.tell()
                        dest.seek(0)
                        contents = dest.read()
                        passed = (proc.returncode == 0 and
                                  proc.stdout == b'1|unchanged|unchanged\n' and
                                  b'integer expected:' in proc.stderr and
                                  input_offset == 0 and output_offset == 0 and
                                  contents == b'KEEP') if reject else None
                        rows.append(dict(locale=locale, mode=mode, value=value,
                                         reject=reject, passed=passed,
                                         status=proc.returncode,
                                         stdout=proc.stdout.decode(errors='backslashreplace'),
                                         stderr=proc.stderr.decode(errors='backslashreplace'),
                                         input_offset=input_offset, output_offset=output_offset,
                                         output_hex=contents.hex()))
    # Record the actual loaded module: rebuilding at the same path changes
    # module behavior even when the executable hash is unchanged.
    probe = subprocess.run([str(shell), '-dfc',
                            'zmodload zsh/system || exit; cat /proc/$$/maps; :'],
                           capture_output=True, check=True)
    modules = sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                      if line.endswith('/system.so')})
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  int_bits=bits, modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
                                         for p in modules},
                  cases=len(rows), checked=sum(r['reject'] for r in rows),
                  failures=sum(r['passed'] is False for r in rows), runs=rows)
    if args.reference:
        reference = json.loads(args.reference.read_text())
        previous = [r for r in reference['runs'] if not r['reject']]
        current = [r for r in rows if not r['reject']]
        differences = (sum(a != b for a, b in zip(previous, current)) +
                       abs(len(previous) - len(current)))
        report['controls'] = dict(reference=str(args.reference), cases=len(current),
                                  differences=differences)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))
    if args.require_pass and (report['failures'] or
                              report.get('controls', {}).get('differences', 0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
