#!/usr/bin/env python3
"""Differential readiness oracle and alternating release-module benchmark."""
import argparse, contextlib, hashlib, json, os, random, select, socket, statistics
import subprocess, tempfile, time
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--shell',type=Path,required=True)
p.add_argument('--before',type=Path,required=True)
p.add_argument('--after',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--mode',choices=['check','bench','profile','memcheck'],default='check')
p.add_argument('--samples',type=int,default=9)
a=p.parse_args(); shell=a.shell.resolve(); rows=[]
modules={'before':a.before.resolve(),'after':a.after.resolve()}
env={'PATH':'/usr/bin:/bin','LC_ALL':'C'}
setup='module_path=("$1" $module_path); shift; zmodload zsh/zselect || exit 90; '
identities={}
for label,folder in modules.items():
 r=subprocess.run([str(shell),'-dfc',setup+'cat /proc/$$/maps; :','probe',str(folder)],env=env,capture_output=True,check=True)
 paths={line.split()[-1] for line in r.stdout.decode().splitlines() if line.endswith('/zselect.so')}
 expected=str(folder/'zsh/zselect.so')
 if paths!={expected}:raise RuntimeError(('Unexpected module',paths,expected))
 identities[label]={'path':expected,'sha256':hashlib.sha256(Path(expected).read_bytes()).hexdigest()}
with contextlib.ExitStack() as stack:
 source=stack.enter_context(tempfile.TemporaryFile());source.write(b'X');source.flush();source.seek(0)
 fds=[]
 for _ in range(512):
  fd=os.dup(source.fileno());stack.callback(os.close,fd);fds.append(fd)
 # Include a real TCP urgent-data condition without consuming it.
 listener=stack.enter_context(socket.socket());listener.bind(('127.0.0.1',0));listener.listen(1)
 client=stack.enter_context(socket.socket());client.connect(listener.getsockname())
 server,_=listener.accept();stack.enter_context(server)
 client.sendall(b'normal');client.send(b'!',socket.MSG_OOB)
 urgent=server.fileno()
 if not select.select([],[],[urgent],1)[2]:raise RuntimeError('Urgent fixture not ready')
 all_fds=tuple(fds+[urgent]); rng=random.Random(5501)
 def run(label,code,timeout=30,prefix=()):
  return subprocess.run([*prefix,str(shell),'-dfc',setup+code,'probe',str(modules[label])],
    env=env,pass_fds=all_fds,capture_output=True,timeout=timeout)
 def arguments(groups):
  return ' '.join('-'+kind+' '+' '.join(map(str,values)) for kind,values in zip('rwe',groups) if values)
 if a.mode=='check':
  for count in [0,1,2,8,32,128,512]:
   for pattern in ['read','write','overlap','mixed','urgent']:
    chosen=fds[:count];rng.shuffle(chosen)
    groups=[chosen,[],[]] if pattern=='read' else [[],chosen,[]] if pattern=='write' else [chosen,chosen,[]] if pattern=='overlap' else [chosen[::2],chosen[1:]+chosen[:1],chosen[:2]]
    if pattern=='urgent':groups=[chosen+[urgent],chosen+[urgent],[urgent]]
    ready=select.select(*groups,0)
    truth={fd:''.join(kind for kind,values in zip('rwe',ready) if fd in values) for fd in set(sum(groups,[]))}
    truth={fd:flags for fd,flags in truth.items() if flags}
    for output in ['assoc','array','readonly']:
     declare='typeset -a found=(sentinel); ' if output=='array' else 'typeset -A found=(sentinel keep); '
     if output=='readonly':declare+='readonly found; '
     code=declare+'reply=(untouched); zselect -t 0 '+('-a' if output=='array' else '-A')+' found '+arguments(groups)+'; rc=$?; print -r -- "rc=$rc"; typeset -p found reply; print -r -- ORACLE; '
     if output=='assoc':
      code+='print -r -- "${found[sentinel]-missing}"; '
      code+=' '.join('print -r -- "${found['+str(fd)+']-missing}";' for fd in sorted(set(sum(groups,[]))))
     results={label:run(label,code) for label in modules}
     same=all((r.returncode,r.stdout,r.stderr)==(results['before'].returncode,results['before'].stdout,results['before'].stderr) for r in results.values())
     oracle=True
     if output=='assoc':
      expected=['missing' if truth else 'keep']+[truth.get(fd,'missing') for fd in sorted(set(sum(groups,[])))]
      oracle=results['after'].stdout.decode().split('ORACLE\n',1)[1].splitlines()==expected
     rows.append(dict(count=count,pattern=pattern,output=output,matched=same,oracle=oracle,
       results={label:dict(status=r.returncode,stdout=r.stdout.decode(),stderr=r.stderr.decode()) for label,r in results.items()}))
 elif a.mode=='bench':
  # Run this mode with no concurrent builds, tests, or profiling.
  os.sched_setaffinity(0,{min(os.sched_getaffinity(0))})
  for count in [1,8,64,256,512]:
   for output in ['assoc','array']:
    iterations=10000 if count<64 else 1000
    code='typeset -'+('A' if output=='assoc' else 'a')+' found; integer n; for ((n=0;n<'+str(iterations)+';n++)); do zselect -t 0 '+('-A' if output=='assoc' else '-a')+' found '+arguments([fds[:count],fds[:count],[]])+' || exit 91; done; typeset -p found'
    samples={label:[] for label in modules};digests=set()
    for repeat in range(a.samples):
     for label in (['before','after'] if repeat%2==0 else ['after','before']):
      start=time.perf_counter();r=run(label,code);elapsed=time.perf_counter()-start
      if r.returncode or r.stderr:raise RuntimeError(r.stderr)
      samples[label].append(elapsed);digests.add(hashlib.sha256(r.stdout).hexdigest())
    if len(digests)!=1:raise RuntimeError('Benchmark states differ')
    medians={label:statistics.median(values) for label,values in samples.items()}
    rows.append(dict(count=count,output=output,iterations=iterations,samples=samples,medians=medians,
      time_saved_percent=100*(1-medians['after']/medians['before']),state_sha256=digests.pop()))
 else:
  a.output.parent.mkdir(parents=True,exist_ok=True)
  code='typeset -A found; integer n; for ((n=0;n<100;n++)); do zselect -t 0 -A found '+arguments([fds[:256],fds[:256],[]])+' || exit 91; done; typeset -p found'
  for label in modules:
   path=a.output.parent/('callgrind-'+label)
   prefix=(('valgrind','--tool=callgrind','--callgrind-out-file='+str(path)) if a.mode=='profile' else
           ('valgrind','--tool=memcheck','--error-exitcode=99','--leak-check=no'))
   r=run(label,code,timeout=120,prefix=prefix)
   if r.returncode:raise RuntimeError(r.stderr)
   rows.append(dict(label=label,profile=str(path),stderr=r.stderr.decode(),state_sha256=hashlib.sha256(r.stdout).hexdigest()))
report=dict(shell=str(shell),sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),modules=identities,mode=a.mode,runs=rows)
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'mode':a.mode,'cases':len(rows),'failures':sum(not r.get('matched',True) or not r.get('oracle',True) for r in rows)}))
if any(not r.get('matched',True) or not r.get('oracle',True) for r in rows):raise SystemExit(1)
