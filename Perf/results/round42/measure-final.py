import json,subprocess,time
from pathlib import Path
r=Path('.work/round42');gate=r/'final-checks.json';limit=time.monotonic()+1800
while not gate.exists():
 if time.monotonic()>limit:raise RuntimeError('final verification incomplete')
 time.sleep(2)
assert json.loads(gate.read_text())['passed']
a='/usr/local/psh/releases/1.0.0-rc1-519928894f02/bin/psh'
b='/usr/local/psh/releases/1.0.0-rc1-6db51a2527d4/bin/psh'
commands=[('final-customer',['Perf/customer-benchmark.py',a,b,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),
 ('final-objects',['Perf/applications.py',a,b,'--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--arrays','--objects','--samples','9','--cpu','13']),
 ('final-hash',['Perf/hash-expansion-benchmark.py',a,b,'--samples','9','--cpu','13']),
 ('final-moonlit',['Perf/scene-benchmark.py',a,b,'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','3','--cpu','13'])]
results=[]
for name,cmd in commands:
 cmd=['python3',*cmd,'--output',str(r/(name+'.json'))];start=time.time()
 print('Starting',name,flush=True)
 with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1200)
 results.append(dict(name=name,command=cmd,started_unix=start,elapsed_seconds=time.time()-start,status=p.returncode))
 (r/'final-measurement-session.json').write_text(json.dumps(results,indent=2)+'\n')
 if p.returncode:raise RuntimeError((name,p.returncode))
 print('Finished',name,flush=True)
