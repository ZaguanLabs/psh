from pathlib import Path
import json,subprocess,time
root=Path.cwd();l=root/'.work/logs/round32';shell=json.loads((l/'parent.json').read_text())['shell'];module=l/'observer-active';rows=[]
for name,cmd in [('scope-scaling',['python3','Perf/scope-scaling.py',shell,'--module-dir',str(module),'--cpu','13']),('customer-scaling',['python3','Perf/scope-customer-scaling.py',shell,'--module-dir',str(module),'--labs','/home/stig/dev/ai/zaguan/labs','--cpu','13'])]:
 cmd+=['--output',str(l/(name+'.json'))];start=time.monotonic()
 with (l/(name+'.log')).open('wb') as out:
  with subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT) as process:
   for line in process.stdout:out.write(line);out.flush();print(line.decode(),end='',flush=True)
   status=process.wait()
 rows.append(dict(name=name,command=cmd,status=status,seconds=time.monotonic()-start));(l/'timing.json').write_text(json.dumps(rows,indent=2)+'\n');assert status==0
