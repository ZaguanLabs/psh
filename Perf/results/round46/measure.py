import json,subprocess,time,runpy,hashlib
from pathlib import Path
r=Path('.work/round46'); assert json.loads((r/'final-checks.json').read_text())['passed']
a='/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh'
b='/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh'
commands=[('glob',['Perf/glob-memory-benchmark.py',a,b,'--samples','9','--cpu','13']),
 ('customer',['Perf/customer-benchmark.py',a,b,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),
 ('applications',['Perf/applications.py',a,b,'--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--arrays','--objects','--samples','9','--cpu','13']),
 ('fresh-customer',['Perf/customer-process-benchmark.py',a,b,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13'])]
commands.append(('text-customer', [*commands[-1][1], '--source-only']))
helpers=runpy.run_path('Perf/customer-process-benchmark.py')
def inputs():
 roots={str(Path('/home/stig/dev/ai/zaguan/labs')/project) if group=='labs' else str(Path('/home/stig/dev/challenge')/project) for _,group,project,_ in runpy.run_path('Perf/customer-benchmark.py')['CASES']}
 roots.add('/home/stig/dev/ai/zaguan/labs/zjson')
 result={}
 for name in sorted(roots):
  root=Path(name); entry=helpers['input_metadata'](root)
  for f in sorted([*root.glob('*.zsh'),*root.glob('*.zwc')]):
   entry[f.name]=dict(sha256=hashlib.sha256(f.read_bytes()).hexdigest(),mtime_ns=f.stat().st_mtime_ns,size=f.stat().st_size)
  result[name]=entry
 return result
before=inputs()
(r/'input-metadata-before.json').write_text(json.dumps(before,indent=2)+'\n')
results=[]
for suffix in ['', '-repeat']:
 for label,cmd in commands:
  name=label+suffix; cmd=['python3',*cmd,'--output',str(r/(name+'.json'))]; start=time.time()
  print('Starting',name,flush=True)
  with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1200)
  results.append(dict(name=name,command=cmd,started_unix=start,elapsed_seconds=time.time()-start,status=p.returncode))
  (r/'measurement-session.json').write_text(json.dumps(results,indent=2)+'\n')
  if p.returncode:raise RuntimeError((name,p.returncode))
  print('Finished',name,flush=True)

after=inputs()
(r/'input-metadata-after.json').write_text(json.dumps(after,indent=2)+'\n')
assert before==after, 'Customer sources or bytecode caches changed during measurement'
