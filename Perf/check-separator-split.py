#!/usr/bin/env python3
"""Compare literal separator splitting as complete, element-preserving output."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def cases():
    separators = [bytes([value]) for value in range(1, 256)]
    separators += [b'::', 'é'.encode(), '界'.encode(), b'ab', b'aba']
    for separator in separators:
        for subject in (b'', b'a', separator, b'a' + separator + b'b',
                        separator * 2, b'a' + separator * 2 + b'b',
                        b'\\a\\' + separator + b'\\\\', b'\\' + separator,
                        b'caf\xc3\xa9' + separator + b'cargo',
                        b'bad\xff' + separator + b'\x80end',
                        b'a' + separator + b'b' * 258):
            yield separator, subject


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve(strict=True)
    code = ('emulate -R "$1"; typeset sep=$2 text=$3 -a out; '
            'out=("${(@s.$sep.)text}"); '
            'printf "%d\\0" "$#out"; printf "%s\\0" "${out[@]}"')
    rows = []
    sampled = {1, 32, 58, 92, 128, 131, 255}
    multibyte_samples = {'é'.encode(), '界'.encode(), b'ab'}
    for locale in ('C', 'C.UTF-8'):
        for emulation in ('zsh', 'ksh', 'sh'):
            for separator, subject in cases():
                if args.memcheck and not (separator in multibyte_samples or
                                         (len(separator) == 1 and
                                          separator[0] in sampled)):
                    continue
                command = [str(shell), '-dfc', code, 'probe', emulation,
                           separator, subject]
                if args.memcheck:
                    command = ['valgrind', '--error-exitcode=97',
                               '--leak-check=no'] + command
                proc = subprocess.run(command, capture_output=True, timeout=5,
                                      env={'PATH': '/usr/bin:/bin',
                                           'LC_ALL': locale})
                rows.append(dict(locale=locale, emulation=emulation,
                                 separator=separator.hex(), subject=subject.hex(),
                                 status=proc.returncode, stdout=proc.stdout.hex(),
                                 stderr=proc.stderr.decode(errors='backslashreplace')))
    differences = []
    if args.reference:
        previous = {}
        for old in json.loads(args.reference.read_text())['runs']:
            key = tuple(old[name] for name in
                        ('locale', 'emulation', 'separator', 'subject'))
            if key in previous and any(old[name] != previous[key][name]
                                       for name in ('status', 'stdout', 'stderr')):
                raise RuntimeError('conflicting duplicate reference case')
            previous[key] = old
        for new in rows:
            key = tuple(new[name] for name in
                        ('locale', 'emulation', 'separator', 'subject'))
            if key not in previous:
                raise RuntimeError('missing reference case')
            old = previous[key]
            compared = ('status', 'stdout') if args.memcheck else \
                ('status', 'stdout', 'stderr')
            if any(old[key] != new[key] for key in compared):
                differences.append({key: new[key] for key in
                                    ('locale', 'emulation', 'separator', 'subject')})
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  cases=len(rows), memcheck=args.memcheck, failures=len(differences),
                  corpus='representative Memcheck subset' if args.memcheck else
                         'exhaustive one-byte and selected multibyte separators',
                  runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'runs'}))
    if differences:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
