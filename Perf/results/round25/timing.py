from pathlib import Path
import json,subprocess,time
logs=Path('.work/logs/round25')
rows=[]
previous=json.loads(Path('Perf/results/round24/timing-commands.json').read_text())
for item in previous:
 name=item['name'];cmd=[s.replace('round24','round25') for s in item['command']]
 start=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 rows.append(dict(name=name,command=cmd,status=r.returncode,seconds=time.monotonic()-start))
 (logs/'timing-commands.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(name,r.returncode,flush=True)
 assert r.returncode==0,name
