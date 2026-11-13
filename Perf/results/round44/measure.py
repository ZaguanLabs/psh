import json,subprocess,time
from pathlib import Path
r=Path('.work/round44')
assert json.loads((r/'final-checks.json').read_text())['passed']
a='/usr/local/psh/releases/1.0.0-rc1-5982ba7e218f/bin/psh'
b='/usr/local/psh/releases/1.0.0-rc1-fcff3fb31d43/bin/psh'
commands=[('glob',['Perf/glob-memory-benchmark.py',a,b,'--samples','9','--cpu','13']),
 ('customer',['Perf/customer-benchmark.py',a,b,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),
 ('objects',['Perf/applications.py',a,b,'--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--arrays','--objects','--samples','9','--cpu','13'])]
results=[]
for name,cmd in commands:
 cmd=['python3',*cmd,'--output',str(r/(name+'.json'))];start=time.time()
 print('Starting',name,flush=True)
 with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1200)
 results.append(dict(name=name,command=cmd,started_unix=start,elapsed_seconds=time.time()-start,status=p.returncode))
 (r/'measurement-session.json').write_text(json.dumps(results,indent=2)+'\n')
 if p.returncode:raise RuntimeError((name,p.returncode))
 print('Finished',name,flush=True)
