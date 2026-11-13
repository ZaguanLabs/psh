#!/usr/bin/env python3
"""Compare short literal quotes, command prefixes and expansion fallbacks."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases():
    words = ("''", '""', "'x'", '"x"', "a''b", "a\"\"b", "'' ''", "'*'", "'~'",
             "'='", "'$'", "' '", "';'", "'{'", "'}'", "'?'", "'['", "'!'",
             "'foo'", "'foo bar'", r"'\*'", "$'\\0'", "'é'", '""x',
             '"$value"', '${array[@]}', '"${array[@]}"', '$(print -r -- x)',
             'x{a,b}', 'x$((++calls))')
    for mode, prefix, word in itertools.product(
            ('zsh', 'sh', 'ksh'), ('', 'noglob ', 'command ', 'builtin '), words):
        script = f'emulate -R {mode}\n'
        script += "value='v *'; array=('a b' '' c); integer calls=0\n"
        script += prefix + "printf '<%s>\\n' fixed " + word + " tail\n"
        script += 'print -r -- calls=$calls\nprint -r -- literal-done\n'
        yield f'{mode}/{prefix}/{word}', script
    for option in ('shfileexpansion', 'noshfileexpansion', 'magicequalsubst',
                   'nomagicequalsubst', 'kshtypeset', 'noksharrays', 'ksharrays'):
        yield option, f'''emulate -R zsh
setopt {option}
() {{ local 'x'; typeset x=''; 'typeset' x='y'; print -r -- "$x"; }}
printf '<%s>\\n' '' 'x' '~' '=' 'a' ''
print -r -- literal-done
'''
    yield 'function-roundtrip', '''emulate -R zsh
p() { printf '<%s>\\n' '' 'x' '*' '~' '$'; }
functions p
p
definition=$functions[p]
unfunction p
functions[p]=$definition
p
print -r -- literal-done
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('shells', type=Path, nargs='+')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    shells = [s.resolve(strict=True) for s in args.shells]
    if len(shells) < 2:
        parser.error('at least two shells are required')
    rows = []
    for locale in ('C', 'C.UTF-8'):
        for label, source in cases():
            observations = []
            for shell in shells:
                r = subprocess.run([str(shell), '-dfc', source, 'literal-arguments'],
                                   capture_output=True, timeout=30,
                                   env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale})
                observations.append((r.returncode, r.stdout, r.stderr))
            passed = (len(set(observations)) == 1 and observations[0][0] == 0
                      and observations[0][1].endswith(b'literal-done\n'))
            row = {'case': label, 'locale': locale, 'passed': passed}
            if not passed:
                row.update(source=source, observations=[
                    {'status': status, 'stdout_hex': out.hex(), 'stderr_hex': err.hex()}
                    for status, out, err in observations])
            rows.append(row)
    report = {'shells': list(map(str, shells)), 'cases': rows,
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'binary_sha256': [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells],
              'passed': all(r['passed'] for r in rows)}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"{len(rows)} literal argument cases; passed={report['passed']}")
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
