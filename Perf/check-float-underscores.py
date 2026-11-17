#!/usr/bin/env python3
"""Compare underscore float values, suffix evaluation, diagnostics and exit status."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess

CODE = '''emulate -R zsh
[[ $1 == default ]] || setopt "$1"
typeset -i side=0 named_value=7
expr=$2
typeset -F 12 result
result=$(( $expr ))
print -r -- "$result:$side:$named_value"
'''


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', type=Path, action='append', required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    a=p.parse_args()
    shells=[s.resolve(strict=True) for s in a.shell]
    sha=lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    hashes=[sha(s) for s in shells]
    tokens=[]
    text='1.2e+3'
    for mask in range(1 << (len(text)+1)):
        tokens.append(''.join(('__' if mask & (1<<i) else '')+ch for i,ch in enumerate(text+' ')).rstrip())
    tokens += ['0.0','-0.0','0001_2.3_4','1_.','1__e','1e+__','1_2.3_4e-5','0x_ff','16#f_f',
               '1e3_09','1e-3_99','.1_25','1_2.3.4', '1'+ '_'*4096+'.25', '1.25'+ '_'*4096+'e+0']
    if a.memcheck:
        tokens=tokens[::16]+tokens[-15:]
    observations=[]
    for locale,mode,token,suffix in itertools.product(['C','C.UTF-8'],['default','forcefloat','octalzeroes'],tokens,
                                                     ['', '+named_value+(side+=2)', '+1_0.2_5', '.9']):
        expression=token+suffix
        if a.memcheck and (mode!='default' or suffix not in ['', '+named_value+(side+=2)']):
            continue
        values=[]
        for shell in shells:
            prefix=['valgrind','--quiet','--error-exitcode=97','--leak-check=no'] if a.memcheck else []
            r=subprocess.run(prefix+[str(shell),'-dfc',CODE,'arithprobe',mode,expression],
                             env={'PATH':'/usr/bin:/bin','LC_ALL':locale},capture_output=True,timeout=30)
            if r.returncode==97:
                raise RuntimeError(('Memcheck error', shell, expression, r.stderr.decode(errors='replace')))
            values.append(dict(status=r.returncode,stdout=r.stdout.hex(),stderr=r.stderr.hex()))
        row=dict(locale=locale,mode=mode,expression=expression,results=values)
        observations.append(row)
        if any(v!=values[0] for v in values[1:]):
            a.output.write_text(json.dumps(dict(passed=False,mismatch=row),indent=2)+'\n')
            raise RuntimeError(('difference', locale,mode,expression))
    assert hashes==[sha(s) for s in shells]
    a.output.write_text(json.dumps(dict(passed=True,shells=list(map(str,shells)),binary_sha256=hashes,
        driver_sha256=sha(Path(__file__)),memcheck=a.memcheck,observations=len(observations),cases=observations),indent=2)+'\n')
    print(len(observations),'observations match across',len(shells),'shells')


if __name__=='__main__':
    main()
