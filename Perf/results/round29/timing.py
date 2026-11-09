from pathlib import Path
import json,subprocess,time
l=Path('.work/logs/round29');rows=[]
inputs=json.loads((l/'timing-input.json').read_text())
for row in inputs:
 start=time.monotonic()
 with (l/(row['name']+'.log')).open('wb') as f:r=subprocess.run(row['command'],stdout=f,stderr=subprocess.STDOUT)
 rows.append(dict(**row,status=r.returncode,seconds=time.monotonic()-start));(l/'timing-commands.json').write_text(json.dumps(rows,indent=2)+'\n');print(row['name'],r.returncode,flush=True);assert r.returncode==0
