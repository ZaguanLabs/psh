#!/usr/bin/env python3
"""Compare scalar append ownership boundaries, attributes, scopes and bytes."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases():
    payloads = ("''", "'a'", "'é界😀'", "$'a\\0b\\203\\377'",
                '"${(l:4097::x:)}"')
    declarations = ('typeset', 'typeset -x', 'typeset -l', 'typeset -u',
                    'typeset -L12', 'typeset -R12', 'typeset -Z12', 'typeset -t')
    for mode, mb, declaration, payload in itertools.product(
            ('zsh', 'sh', 'ksh'), ('multibyte', 'nomultibyte'), declarations, payloads):
        script = f'emulate -R {mode}\nsetopt {mb}\n'
        script += 'test_append() {\n' + declaration + ' s=' + payload + '\n'
        script += r'''local piece
for piece in '' x $'é\0\203\377' "${(l:4096::z:)}"; do
  s+=$piece
  typeset -p s
  print -r -- "${(qqqq)s}"
done
outer() { local s=inner; s+=local; typeset -p s; }
outer
typeset -p s
}
test_append
print -r -- append-done
'''
        yield f'{mode}/{mb}/{declaration}/{payload}', script
    for named in ('autonamedirs', 'noautonamedirs'):
        yield named, f'''emulate -R zsh
setopt {named}
typeset -x psh_append_dir=/tmp
psh_append_dir+=/psh
typeset -p psh_append_dir
print -r -- ${{nameddirs[psh_append_dir]-missing}}
print -r -- ${{(D)psh_append_dir}}
print -r -- append-done
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('shells', type=Path, nargs='+')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--locale', action='append', dest='locales')
    args = parser.parse_args()
    shells = [s.resolve(strict=True) for s in args.shells]
    if len(shells) < 2:
        parser.error('at least two hosts are required')
    rows = []
    for locale in args.locales or ('C', 'C.UTF-8'):
        for label, source in cases():
            observations = []
            for shell in shells:
                r = subprocess.run([str(shell), '-dfc', source, 'scalar-append'],
                                   capture_output=True, timeout=30,
                                   env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale})
                observations.append((r.returncode, r.stdout, r.stderr))
            passed = (len(set(observations)) == 1 and observations[0][0] == 0
                      and observations[0][1].endswith(b'append-done\n'))
            row = {'case': label, 'locale': locale, 'passed': passed}
            if not passed:
                row.update(source=source, observations=[
                    {'status': s, 'stdout_hex': out.hex(), 'stderr_hex': err.hex()}
                    for s, out, err in observations])
            rows.append(row)
    report = {'shells': list(map(str, shells)),
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'binary_sha256': [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells],
              'cases': rows, 'passed': all(r['passed'] for r in rows)}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"{len(rows)} append cases; passed={report['passed']}")
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
