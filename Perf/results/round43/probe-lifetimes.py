from pathlib import Path
import subprocess,tempfile,json,os
root=Path.cwd();out=root/'.work/round43';rows=[]
hosts={'pristine':root/'.work/public-rc0/reference/Src/zsh','accepted':Path('/usr/local/psh/releases/1.0.0-rc1-6db51a2527d4/bin/psh'),'upstream':root/'.work/hash-report-upstream/Src/zsh'}
with tempfile.TemporaryDirectory(prefix='psh-lifetime-probe-') as tmp:
 p=Path(tmp);(p/'blocked').write_text(':\n');(p/'blocked').chmod(0)
 for kind in ['history','source']:
  for label,shell in hosts.items():
   if kind=='history':
    (p/'hist').write_bytes(b'echo '+b'x'*18000+b'\x83\n')
    code='fc -p "$1/hist" 100 0; fc -l -n; fc -P'
   else:code='path=("$1"); source blocked; print -r -- status=$?'
   cmd=['valgrind','--quiet','--error-exitcode=97','--track-origins=yes',str(shell),'-dfc',code,'probe',str(p)]
   r=subprocess.run(cmd,capture_output=True,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},timeout=60)
   (out/(kind+'-'+label+'.stderr')).write_bytes(r.stderr)
   rows.append(dict(kind=kind,host=label,command=cmd,status=r.returncode,stdout=r.stdout.decode(errors='replace')[:100],stderr=r.stderr.decode(errors='replace')))
   print(kind,label,r.returncode,r.stderr.decode(errors='replace')[:600],flush=True)
 (p/'blocked').chmod(0o600)
(out/'lifetime-probes.json').write_text(json.dumps(rows,indent=2)+'\n')
