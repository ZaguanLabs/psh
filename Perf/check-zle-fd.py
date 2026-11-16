#!/usr/bin/env python3
"""Check zle -F watcher state before and after descriptor parsing."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile


MODULUS = 4294967296
PREFIX = '''zmodload zsh/zle || exit 90
handler() { :; }
replacement() { :; }
'''
CASES = {
    'wide-add': (
        f'zle -F {MODULUS} handler; print -r -- "wide:$?"\n'
        'zle -F -L; print -r -- "list:$?"\n'
        'zle -F 0; print -r -- "cleanup:$?"\n',
        'wide:1\nlist:0\ncleanup:1\n'),
    'wide-replace': (
        f'zle -F 3 handler\nzle -F -w {MODULUS + 3} replacement; '
        'print -r -- "wide:$?"\nzle -F -L 3\n'
        'zle -F 3; print -r -- "cleanup:$?"\n',
        'wide:1\nzle -F 3 handler\ncleanup:0\n'),
    'wide-list': (
        f'zle -F 3 handler\nzle -F -L {MODULUS + 3}; '
        'print -r -- "wide:$?"\nzle -F -L 3\n'
        'zle -F 3; print -r -- "cleanup:$?"\n',
        'wide:1\nzle -F 3 handler\ncleanup:0\n'),
    'wide-remove': (
        f'zle -F 3 handler\nzle -F {MODULUS + 3}; '
        'print -r -- "wide:$?"\nzle -F 3; print -r -- "cleanup:$?"\n'
        'zle -F -L 3; print -r -- "lookup:$?"\n',
        'wide:1\ncleanup:0\nlookup:1\n'),
    'valid': (
        'for value in 3 +3 003; do\n'
        '  zle -F "$value" handler || exit 91\n'
        '  zle -F -L "$value" || exit 92\n'
        '  zle -F "$value" replacement || exit 93\n'
        '  zle -F -L "$value" || exit 94\n'
        '  zle -F "$value" || exit 95\n'
        'done\nprint -r -- valid',
        'zle -F 3 handler\nzle -F 3 replacement\n'
        'zle -F 3 handler\nzle -F 3 replacement\n'
        'zle -F 3 handler\nzle -F 3 replacement\nvalid\n'),
    'int-max': (
        'zle -F 2147483647 handler; print -r -- "add:$?"\n'
        'zle -F -L 2147483647\n'
        'zle -F 2147483647; print -r -- "remove:$?"\n',
        'add:0\nzle -F 2147483647 handler\nremove:0\n'),
    'invalid': (
        'for value in -1 3x "3 "; do\n'
        '  zle -F "$value" handler; print -r -- "invalid:$?"\n'
        'done\nzle -F; print -r -- "empty:$?"\n',
        'invalid:1\ninvalid:1\ninvalid:1\nempty:0\n'),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    modules = args.modules.resolve(strict=True)
    rows = []
    with tempfile.TemporaryDirectory() as temporary:
        home = Path(temporary)
        for locale in ('C', 'C.UTF-8'):
            for name, (body, expected) in CASES.items():
                env = {'PATH': '/usr/bin:/bin', 'HOME': str(home),
                       'LC_ALL': locale, 'TERM': 'xterm'}
                command = [str(shell), '-dfc',
                           f'module_path=({str(modules)!r} $module_path)\n' +
                           PREFIX + body]
                if args.memcheck:
                    command = ['valgrind', '--error-exitcode=97',
                               '--leak-check=no', '--track-origins=yes'] + command
                proc = subprocess.run(command, env=env, capture_output=True,
                                      timeout=60 if args.memcheck else 3)
                stdout = proc.stdout.decode(errors='backslashreplace')
                stderr = proc.stderr.decode(errors='backslashreplace')
                passed = (proc.returncode == 0 and stdout == expected and
                          ('Bad file descriptor number for -F:' in stderr
                           if name.startswith('wide-') or name == 'invalid'
                           else True))
                rows.append(dict(locale=locale, name=name, passed=passed,
                                 code=PREFIX + body, expected=expected,
                                 status=proc.returncode, stdout=stdout,
                                 stderr=stderr))
    report = dict(shell=str(shell), modules=str(modules), cases=len(rows),
                  memcheck=args.memcheck,
                  failures=sum(not row['passed'] for row in rows), runs=rows)
    if args.reference:
        previous = json.loads(args.reference.read_text())['runs']
        controls = [name for name in CASES if not name.startswith('wide-')]
        differences = []
        for locale in ('C', 'C.UTF-8'):
            for name in controls:
                old = next(row for row in previous if row['locale'] == locale and
                           row['name'] == name)
                new = next(row for row in rows if row['locale'] == locale and
                           row['name'] == name)
                if any(old[key] != new[key]
                       for key in ('status', 'stdout', 'stderr')):
                    differences.append(locale + ':' + name)
        report['controls'] = dict(cases=len(controls) * 2,
                                  differences=differences)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'runs'}))
    if args.require_pass and (report['failures'] or
                              report.get('controls', {}).get('differences')):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
