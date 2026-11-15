#!/usr/bin/env python3
"""Compare newly rejected descriptors with established negative-FD errors.

Each child receives seekable temporary stdin. A known negative descriptor is
the existing error-path oracle for its context; valid FD zero is a control.
ERRNO is recorded, but is not a portable contract on parameter errors.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell = args.shell.resolve()
    actions = {
        'seek': 'sysseek -u "$1" "$((++arg)) + ++x"',
        'read': 'sysread -i "$1" -s 1 -c count result',
        'tell': '(( result = systell(fd) + ++x ))',
        'tell-expand': 'print -r -- "$(( result = systell(fd) + ++x ))"',
    }
    contexts = {
        'plain': '{action}; rc=$?; observed_errno=$ERRNO; print -r -- "rc=$rc"',
        'if': 'if {action}; then print success; else print failure; fi',
        'and': '{action} && print success; print after-and',
        'zerr': 'TRAPZERR() {{ print ZERR; }}; {action}; print after-action',
        'errexit': 'setopt errexit; {action}; print after-action',
        'errreturn': 'f() {{ setopt localoptions errreturn; {action}; print inner; }}; f "$1"; print outer',
        'always': '{{ {action}; print body; }} always {{ print cleanup; }}; print after-always',
    }
    rows = []
    for locale in ('C', 'C.UTF-8'):
        for mode, action in actions.items():
            for context, template in contexts.items():
                for value in ('-1', '0', '4294967296', '-4294967296', '4294967395'):
                    with tempfile.TemporaryFile() as source:
                        source.write(b'ABC'); source.flush(); source.seek(0)
                        setup = ('zmodload zsh/system || exit 90; '
                                 'x=0; arg=0; count=unchanged; result=unchanged; fd=$1; '
                                 'observed_errno=unset; ERRNO=0; '
                                 'TRAPEXIT() { print -r -- "exit=$? x=$x arg=$arg result=$result count=$count errno=$observed_errno"; }; ')
                        code = setup + template.format(action=action)
                        proc = subprocess.run([str(shell), '-dfc', code, 'probe', value],
                                              stdin=source, capture_output=True, timeout=5,
                                              env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale})
                        stdout = proc.stdout.decode(errors='backslashreplace')
                        stderr = proc.stderr.decode(errors='backslashreplace')
                        rows.append(dict(locale=locale, mode=mode, context=context, value=value,
                                         status=proc.returncode, stdout=stdout, stderr=stderr,
                                         offset=source.tell(),
                                         comparison=dict(status=proc.returncode,
                                             stdout=re.sub(r'errno=\S+', 'errno=<observed>', stdout),
                                             stderr=stderr.replace('integer expected: '+value,
                                                                   'integer expected: <argument>'),
                                             offset=source.tell())))
    canonical = {(r['locale'], r['mode'], r['context']): r['comparison']
                 for r in rows if r['value'] == '-1'}
    for row in rows:
        row['rejected_like_negative'] = (row['comparison'] ==
            canonical[(row['locale'], row['mode'], row['context'])]) if row['value'] not in ('-1', '0') else None
    probe = subprocess.run([str(shell), '-dfc', 'zmodload zsh/system; cat /proc/$$/maps; :'],
                           capture_output=True, check=True)
    modules = sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                      if line.endswith('/system.so')})
    if not modules:
        raise RuntimeError('No loaded system module found')
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in modules},
                  cases=len(rows), checked=sum(r['rejected_like_negative'] is not None for r in rows),
                  failures=sum(r['rejected_like_negative'] is False for r in rows), runs=rows)
    if args.reference:
        previous = [r for r in json.loads(args.reference.read_text())['runs'] if r['value'] in ('-1', '0')]
        current = [r for r in rows if r['value'] in ('-1', '0')]
        # Retain raw errno in the report; don't hide other output differences.
        differences = sum(a['comparison'] != b['comparison'] for a, b in zip(previous, current))
        differences += abs(len(previous) - len(current))
        report['controls'] = dict(cases=len(current), differences=differences,
                                  reference=str(args.reference))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))
    if args.require_pass and (report['failures'] or report.get('controls', {}).get('differences', 0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
