#!/usr/bin/env python3
"""Compare complete counter expressions, including fast-path exclusions."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases():
    for mode, declaration, option, initial, expression in itertools.product(
            ('zsh', 'sh', 'ksh'),
            ('integer', 'typeset', 'typeset -F', 'integer -x', 'integer -r', 'integer -Z8'),
            ('', 'forcefloat', 'allexport', 'cprecedences', 'nounset', 'nomultibyte'),
            ('-1', '0', '1', '9223372036854775806', '9223372036854775807'),
            ('i++', 'i++ ', ' i++', '(i++)', 'i++ + i', '0 && i++')):
        source = f'emulate -R {mode}\n'
        if option:
            source += f'setopt {option}\n'
        source += f'{declaration} i={initial}\n'
        # Keep the expression complete: assigning its result in the same
        # arithmetic expression would miss this specialized entry path.
        source += 'run_case() { ((' + expression + ''')); }
run_case
saved_status=$?
print -r -- status=$saved_status
typeset -p i
print -r -- counter-done
'''
        yield f'{mode}/{declaration}/{option}/{initial}/{expression}', source


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shells', type=Path, nargs='+')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    shells = [s.resolve(strict=True) for s in a.shells]
    rows = []
    for label, source in cases():
        observations = []
        for shell in shells:
            r = subprocess.run([str(shell), '-dfc', source, 'math-counter'],
                               capture_output=True, timeout=30,
                               env={'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'})
            observations.append((r.returncode, r.stdout, r.stderr))
        passed = (len(observations) >= 2 and len(set(observations)) == 1
                  and observations[0][0] == 0 and observations[0][1].endswith(b'counter-done\n'))
        row = {'case': label, 'passed': passed}
        if not passed:
            row.update(source=source, observations=[
                {'status': rc, 'stdout': out.hex(), 'stderr': err.hex()}
                for rc, out, err in observations])
        rows.append(row)
    report = {'shells': list(map(str, shells)),
              'binary_sha256': [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells],
              'driver_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'cases': rows, 'passed': all(r['passed'] for r in rows)}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"{len(rows)} complete counter cases; passed={report['passed']}")
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
