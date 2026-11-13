from pathlib import Path
import subprocess,tempfile,hashlib,json
r=Path.cwd();out=r/'.work/round44';rows=[]
hosts=['/usr/local/psh/releases/1.0.0-rc1-5982ba7e218f/bin/psh','/usr/local/psh/releases/1.0.0-rc1-fcff3fb31d43/bin/psh']
with tempfile.TemporaryDirectory(prefix='psh-glob-profile-') as tmp:
 d=Path(tmp)
 for i in range(10000):(d/f'f{i:05d}').touch()
 code="emulate -R zsh; a=(*(Ne^': "+'x'*1024+"'^)); printf '%s\\0' \"${a[@]}\""
 expected=b''.join(f'f{i:05d}\0'.encode() for i in range(10000))
 for label,shell in zip(('baseline','candidate'),hosts):
  target=out/(label+'.massif')
  cmd=['valgrind','--tool=massif','--massif-out-file='+str(target),'--time-unit=B','--detailed-freq=1','--max-snapshots=30',shell,'-dfc',code]
  p=subprocess.run(cmd,cwd=d,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=240)
  (out/(label+'-massif.log')).write_bytes(p.stderr)
  assert p.returncode==0 and p.stdout==expected,(label,p.returncode,p.stderr,p.stdout[:100])
  snapshots=target.read_text().split('snapshot=')[1:]
  peaks=[]
  for s in snapshots:
   values={k:int(v) for line in s.splitlines() if '=' in line for k,v in [line.split('=',1)] if k in ('mem_heap_B','mem_heap_extra_B','mem_stacks_B')}
   peaks.append(sum(values.values()))
  rows.append(dict(host=label,shell=shell,command=cmd,peak_allocated_bytes=max(peaks),output_sha256=hashlib.sha256(p.stdout).hexdigest(),binary_sha256=hashlib.sha256(Path(shell).read_bytes()).hexdigest()))
(out/'memory-profile.json').write_text(json.dumps(rows,indent=2)+'\n')
print(rows,flush=True)
