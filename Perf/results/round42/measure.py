import json,subprocess,time
from pathlib import Path
r=Path('.work/round42'); limit=time.monotonic()+600
report=r/'preceding-logs/selected-correctness.json'
while not report.exists():
 if time.monotonic()>limit: raise RuntimeError('preceding-release tests did not finish')
 time.sleep(1)
rows=json.loads(report.read_text())['runs']
assert all(x['status']==0 for x in rows if x['name']!='array-native')
assert json.loads((r/'preceding-logs/array-native-psh-pair.json').read_text())['passed']
assert json.loads((r/'preceding-logs/raw-alias-psh-pair.json').read_text())['passed']
a='/usr/local/psh/releases/1.0.0-rc1-519928894f02/bin/psh'
b='/usr/local/psh/releases/1.0.0-rc1-cde7f840ec94/bin/psh'
c='/usr/local/psh/releases/1.0.0-rc1-33125fdb23fe/bin/psh'
commands=[]
for name,base,cand in [('fixed',a,b),('count-bound',b,c)]:
 commands += [(name+'-customer',['Perf/customer-benchmark.py',base,cand,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),
              (name+'-objects',['Perf/applications.py',base,cand,'--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--arrays','--objects','--samples','9','--cpu','13']),
              (name+'-hash',['Perf/hash-expansion-benchmark.py',base,cand,'--samples','9','--cpu','13']),
              (name+'-moonlit',['Perf/scene-benchmark.py',base,cand,'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','3','--cpu','13'])]
results=[]
for name,command in commands:
 cmd=['python3',*command,'--output',str(r/(name+'.json'))]
 start=time.time()
 print('Starting',name,flush=True)
 with (r/(name+'.log')).open('wb') as out:
  p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1200)
 results.append(dict(name=name,command=cmd,started_unix=start,elapsed_seconds=time.time()-start,status=p.returncode))
 (r/'measurement-session.json').write_text(json.dumps(results,indent=2)+'\n')
 if p.returncode:raise RuntimeError((name,p.returncode))
 print('Finished',name,flush=True)
