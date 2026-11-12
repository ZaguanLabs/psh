#!/usr/bin/env python3
"""Compare arithmetic stack growth, deferred lvalues and recursive evaluation."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def quote(value):
    return "'" + value.replace("'", "'\\''") + "'"


def cases():
    for depth in (0, 1, 7, 8, 14, 15, 16, 17, 31, 32, 33, 63, 64, 97, 98, 99, 100, 101):
        deep = 'v+(' * depth + 'v' + ')' * depth
        recursive = 'v+(' * depth + 'nested' + ')' * depth
        for label, expression in (
                ('read', deep),
                ('compound', 'a[i++] += (' + deep + ')'),
                ('lazy', 'a[i++] &&= (' + deep + ')'),
                ('hash', 'h[k] += (' + deep + ')'),
                ('recursive', 'a[i++] += (' + recursive + ')'),
                ('callback', 'a[i++] += (' + deep + '+storage_callback())'),
                ('short-circuit', '0 && (' + deep + ')'),
                ('conditional', '1 ? (' + deep + ') : 1/0')):
            init = '''emulate -R zsh
integer v=1 i=1 calls=0
typeset -a a=(7 11)
typeset -A h=(k 13)
nested=''' + quote('v+(' * 32 + 'v' + ')' * 32) + '''
storage_callback() { (( calls++ )); REPLY=3; }
functions -M storage_callback 0 0 storage_callback
'''
            # A function contains arithmetic errors and lets us inspect restoration.
            script = init + 'run_case() { (( result = ' + expression + ''' )); }
run_case
integer saved_status=$?
print -r -- "status=$saved_status result=$result i=$i calls=$calls a=${(j:,:)a} h=$h[k]"
(( restored = 17 + v ))
print -r -- "restored=$restored"
'''
            yield f'{label}-{depth}', script


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('shells', type=Path, nargs='+')
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--memcheck', action='store_true')
    args = parser.parse_args()
    shells = [p.resolve(strict=True) for p in args.shells]
    if len(shells) < 2:
        parser.error('at least two shells are required')
    rows = []
    for label, source in cases():
        observations = []
        for shell in shells:
            command = [str(shell), '-dfc', source, 'math-storage']
            if args.memcheck:
                command = ['valgrind', '--quiet', '--error-exitcode=97',
                           '--track-origins=yes', *command]
            result = subprocess.run(command, capture_output=True, timeout=45,
                                    env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'})
            observations.append((result.returncode, result.stdout, result.stderr))
        matching = len(set(observations)) == 1
        memory_clean = all(b'Invalid ' not in r[2] and b'uninitialised' not in r[2]
                           and r[0] != 97 for r in observations)
        restored = all(b'restored=18\n' in r[1] for r in observations)
        rows.append({'case': label, 'source': source, 'matching': matching,
                     'memory_clean': memory_clean, 'restored': restored,
                     'observations': [{'status': r[0], 'stdout': r[1].decode(errors='replace'),
                                       'stderr': r[2].decode(errors='replace')}
                                      for r in observations]})
    report = {'shells': [str(s) for s in shells], 'memcheck': args.memcheck,
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'binary_sha256': [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells],
              'cases': rows,
              'passed': all(r['matching'] and r['memory_clean'] and r['restored'] for r in rows)}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"{len(rows)} stack-storage cases; passed={report['passed']}")
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
