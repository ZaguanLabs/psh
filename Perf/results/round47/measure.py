from pathlib import Path
import subprocess,json,time
r=Path('.work/round47');assert json.loads((r/'additional-checks.json').read_text())['passed'];assert (r/'profiles.json').exists()
a='/usr/local/psh/releases/1.0.0-rc1-126770ba80d2';b='/usr/local/psh/releases/1.0.0-rc1-1d2a092078fb';rows=[]
for name in ['components','components-repeat']:
 cmd=['python3','Perf/zdraw-components-benchmark.py',a,b,'--samples','9','--frames','30','--cpu','13','--output',str(r/(name+'.json'))];start=time.time();print('Starting',name,flush=True)
 with (r/(name+'.log')).open('wb') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,timeout=1800)
 rows.append(dict(name=name,command=cmd,status=p.returncode,started_unix=start,elapsed_seconds=time.time()-start))
 (r/'measurement-session.json').write_text(json.dumps(rows,indent=2)+'\n');assert p.returncode==0
 print('Finished',name,flush=True)
