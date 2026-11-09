from pathlib import Path
import json,subprocess,time
l=Path('.work/logs/round34');hosts=['.work/round34/previous/Src/zsh','.work/round34/candidate/Src/zsh'];rows=[]
for name,command in [('customer-pilot',['python3','Perf/customer-benchmark.py',*hosts,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--cpu','13']),('library-pilot',['python3','Perf/applications.py',*hosts,'--arrays','--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--z3dfx','/home/stig/dev/challenge/z3dfx','--cpu','13'])]:
 command+=['--output',str(l/(name+'.json'))];start=time.monotonic()
 with (l/(name+'.log')).open('wb') as log:
  with subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT) as process:
   for line in process.stdout:log.write(line);log.flush();print(line.decode(),end='',flush=True)
   status=process.wait()
 rows.append(dict(name=name,command=command,status=status,seconds=time.monotonic()-start));(l/'pilot-timing.json').write_text(json.dumps(rows,indent=2)+'\n');assert status==0
