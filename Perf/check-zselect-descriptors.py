#!/usr/bin/env python3
"""Bounded descriptor/state oracle for zselect (32-bit int Linux host)."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--reference', type=Path)
    p.add_argument('--require-pass', action='store_true')
    args = p.parse_args(); shell = args.shell.resolve(); rows = []
    invalid = ['4294967296', '4294967299', '8589934592', '4294967295',
               '9223372036854775807', '4294967296x']
    controls = ['0', '3', '003', '1023', '1024', '2147483647',
                '-1', '+1', '', ' 0', '0x0', '3x', '1024x']
    outputs = {'default': '', 'array': '-a found', 'assoc': '-A foundmap',
               'both': '-a found -A foundmap'}
    forms = {'read': '-r "$1"', 'write': '-w "$1"', 'except': '-e "$1"',
             'attached': '"-r$1"', 'mixed': '-r 0 -w "$1"'}
    with tempfile.TemporaryFile() as source:
        source.write(b'ABC'); source.flush()
        for locale in ('C', 'C.UTF-8'):
            for output, option in outputs.items():
                for form, descriptor in forms.items():
                    for reject, values in ((True, invalid), (False, controls)):
                        for value in values:
                            source.seek(1)
                            code = ('zmodload zsh/zselect || exit 90; exec 3<&0; '
                                    'reply=(sentinel); found=(sentinel); '
                                    'typeset -A foundmap=(sentinel keep); '
                                    'zselect -t 0 '+option+' '+descriptor+'; rc=$?; '
                                    'print -r -- "$rc"; '
                                    'typeset -p reply found foundmap')
                            proc = subprocess.run([str(shell), '-dfc', code, 'probe', value],
                                                  stdin=source, capture_output=True, timeout=5,
                                                  env={'PATH':'/usr/bin:/bin', 'LC_ALL':locale})
                            stdout=proc.stdout.decode(errors='backslashreplace')
                            stderr=proc.stderr.decode(errors='backslashreplace')
                            # The range diagnostic must show the full parsed number.
                            parsed = value.rstrip('x')
                            passed = (proc.returncode==0 and stdout.startswith('1\n') and
                                      'reply=( sentinel )' in stdout and
                                      'found=( sentinel )' in stdout and
                                      'foundmap=( [sentinel]=keep )' in stdout and
                                      'file descriptor out of range' in stderr and
                                      stderr.endswith(': '+parsed+'\n') and source.tell()==1) if reject else None
                            rows.append(dict(locale=locale, output=output, form=form, value=value,
                                             reject=reject, passed=passed, status=proc.returncode,
                                             stdout=stdout, stderr=stderr, offset=source.tell()))
    probe=subprocess.run([str(shell),'-dfc','zmodload zsh/zselect; cat /proc/$$/maps; :'],
                         capture_output=True,check=True,timeout=5)
    modules=sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                    if line.endswith('/zselect.so')})
    if not modules: raise RuntimeError('No zselect module provenance')
    report=dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                modules={m:hashlib.sha256(Path(m).read_bytes()).hexdigest() for m in modules},
                cases=len(rows), checked=sum(r['reject'] for r in rows),
                failures=sum(r['passed'] is False for r in rows), runs=rows)
    if args.reference:
        old=[r for r in json.loads(args.reference.read_text())['runs'] if not r['reject']]
        new=[r for r in rows if not r['reject']]
        diff=sum(a!=b for a,b in zip(old,new))+abs(len(old)-len(new))
        report['controls']=dict(cases=len(new),differences=diff)
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='runs'}))
    if args.require_pass and (report['failures'] or report.get('controls',{}).get('differences',0)):
        raise SystemExit(1)


if __name__=='__main__': main()
