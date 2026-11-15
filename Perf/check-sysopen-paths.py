#!/usr/bin/env python3
"""Filesystem oracle for sysopen's internal-string / pathname boundary."""
import argparse,hashlib,json,os,subprocess,tempfile
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--shell',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--require-pass',action='store_true');a=p.parse_args()
shell=a.shell.resolve();rows=[]
def run(directory,locale,code,*args):
 r=subprocess.run([str(shell),'-dfc','zmodload zsh/system || exit 90; '+code,'probe',*map(os.fsdecode,args)],cwd=directory,env={'PATH':'/usr/bin:/bin','LC_ALL':locale},capture_output=True,timeout=10)
 return r
with tempfile.TemporaryDirectory(prefix='psh-path-oracle-') as directory:
 for locale in ['C','C.UTF-8']:
  for suffix in [bytes([b]) for b in range(1,256) if b!=47]+[s.encode() for s in ['界','文档','🙂','é']]:
   name=b'name-'+suffix;path=os.fsencode(directory)+b'/'+name
   for mode in ['read','create']:
    if mode=='read':
     with open(path,'wb') as f:f.write(b'RIGHT')
     r=run(directory,locale,'sysopen -r -u fd -- "$1" || exit; sysread -i $fd || exit; print -rn -- "$REPLY"',name)
     passed=r.returncode==0 and r.stdout==b'RIGHT' and not r.stderr
    else:
     r=run(directory,locale,'sysopen -w -o creat,excl -u fd -- "$1" || exit; syswrite -o $fd RIGHT',name)
     passed=r.returncode==0 and os.path.exists(path) and Path(os.fsdecode(path)).read_bytes()==b'RIGHT' and not r.stderr
    rows.append(dict(locale=locale,mode=mode,filename_hex=name.hex(),passed=passed,status=r.returncode,stdout_hex=r.stdout.hex(),stderr_hex=r.stderr.hex()))
    for file in Path(directory).iterdir():file.unlink()
  for mode in ['read','truncate','append']:
   target=b'name-\x83';decoy=b'name-\x83\xa3'
   for name,data in [(target,b'RIGHT'),(decoy,b'DECOY')]:
    with open(os.fsencode(directory)+b'/'+name,'wb') as f:f.write(data)
   code={'read':'sysopen -r -u fd -- "$1" || exit; sysread -i $fd || exit; print -rn -- "$REPLY"','truncate':'sysopen -w -o trunc -u fd -- "$1"','append':'sysopen -a -u fd -- "$1" || exit; syswrite -o $fd APPEND'}[mode]
   r=run(directory,locale,code,target);actual={name.hex():Path(os.fsdecode(os.fsencode(directory)+b'/'+name)).read_bytes().hex() for name in [target,decoy]}
   expected={'read':b'RIGHT','truncate':b'','append':b'RIGHTAPPEND'}[mode]
   passed=r.returncode==0 and actual[target.hex()]==expected.hex() and actual[decoy.hex()]==b'DECOY'.hex() and (mode!='read' or r.stdout==b'RIGHT')
   rows.append(dict(locale=locale,mode='collision-'+mode,passed=passed,status=r.returncode,stdout_hex=r.stdout.hex(),files=actual))
   for file in Path(directory).iterdir():file.unlink()
report=dict(shell=str(shell),sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),cases=len(rows),failures=sum(not r['passed'] for r in rows),runs=rows)
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k!='runs'}))
if a.require_pass and report['failures']:raise SystemExit(1)
