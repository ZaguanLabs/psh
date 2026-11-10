from pathlib import Path
import json,subprocess,time
l=Path('.work/logs/round35');rows=[]
inputs=json.loads((l/'timing-input.json').read_text())
for row in inputs:
 start=time.monotonic()
 with (l/(row['name']+'.log')).open('wb') as f:
  with subprocess.Popen(row['command'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT) as process:
   for line in process.stdout:
    f.write(line); f.flush(); print(line.decode(errors='replace'),end='',flush=True)
   status=process.wait()
 r=subprocess.CompletedProcess(row['command'],status)
 rows.append(dict(**row,status=r.returncode,seconds=time.monotonic()-start));(l/'timing-commands.json').write_text(json.dumps(rows,indent=2)+'\n');print(row['name'],r.returncode,flush=True);assert r.returncode==0
