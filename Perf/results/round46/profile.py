from pathlib import Path
import subprocess,tempfile,hashlib,json
r=Path.cwd();out=r/'.work/round46';rows=[]
hosts=['/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh','/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh']
with tempfile.TemporaryDirectory(prefix='psh-glob-profile-') as tmp:
 d=Path(tmp)
 for i in range(10000):(d/f'f{i:05d}').touch()
 code="emulate -R zsh; a=(*(Ne^': "+'x'*1024+"'^)); printf '%s\\0' \"${a[@]}\""
 expected=b''.join(f'f{i:05d}\0'.encode() for i in range(10000))
 for label,shell in zip(('baseline','candidate'),hosts):
  target=out/(label+'-pages.massif')
  cmd=['valgrind','--tool=massif','--pages-as-heap=yes','--massif-out-file='+str(target),'--time-unit=B','--detailed-freq=1','--max-snapshots=30',shell,'-dfc',code]
  p=subprocess.run(cmd,cwd=d,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=240)
  (out/(label+'-pages-massif.log')).write_bytes(p.stderr)
  assert p.returncode==0 and p.stdout==expected,(label,p.returncode,p.stderr,p.stdout[:100])
  snapshots=target.read_text().split('snapshot=')[1:]
  peaks=[]
  for s in snapshots:
   values={k:int(v) for line in s.splitlines() if '=' in line for k,v in [line.split('=',1)] if k in ('mem_heap_B','mem_heap_extra_B','mem_stacks_B')}
   peaks.append(sum(values.values()))
  rows.append(dict(scope='page allocations, including mmap-backed Zsh arenas',host=label,shell=shell,command=cmd,peak_allocated_bytes=max(peaks),output_sha256=hashlib.sha256(p.stdout).hexdigest(),binary_sha256=hashlib.sha256(Path(shell).read_bytes()).hexdigest()))
(out/'memory-profile.json').write_text(json.dumps(rows,indent=2)+'\n')
print(rows,flush=True)

# Profile a real project kernel in a fresh process; this is not elapsed timing.
worker=r/'Perf/customer-workload.zsh'
project=Path('/home/stig/dev/ai/zaguan/labs/zcoder.zsh')
sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((project/'lib').glob('*.zsh'))}
observations=[]
for label,shell in zip(('baseline','candidate'),hosts):
    target=out/(label+'-coder.callgrind')
    cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(target),shell,'-df',str(worker),'coder-layout',str(project),'2']
    p=subprocess.run(cmd,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=240)
    (out/(label+'-coder-profile.log')).write_bytes(p.stderr)
    (out/(label+'-coder-profile.out')).write_bytes(p.stdout)
    assert p.returncode==0
    state=p.stdout.split(b'\n',1)[1]
    total=int(next(line.split(':')[1] for line in target.read_text().splitlines() if line.startswith('summary:')))
    observations.append(dict(shell=shell,binary_sha256=hashlib.sha256(Path(shell).read_bytes()).hexdigest(),instructions=total,state_sha256=hashlib.sha256(state).hexdigest()))
assert observations[0]['state_sha256']==observations[1]['state_sha256']
assert sources=={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((project/'lib').glob('*.zsh'))}
(out/'customer-profile.json').write_text(json.dumps(dict(scope='full fresh kernel including setup, parsing, warmup, operation, validation and output',worker_sha256=hashlib.sha256(worker.read_bytes()).hexdigest(),source_sha256=sources,runs=observations),indent=2)+'\n')
