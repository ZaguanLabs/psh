from pathlib import Path
import subprocess,json
root=Path.cwd();logs=root/'.work/round40/logs';old='/usr/local/psh/releases/1.0.0-rc1-b0850020f4a1/bin/psh';bad='/usr/local/psh/releases/1.0.0-rc1-a446099eaf93/bin/psh';new='/usr/local/psh/releases/1.0.0-rc1-519928894f02/bin/psh'
commands=[('restored-moonlit',['python3','Perf/scene-benchmark.py',old,new,'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','5','--cpu','13']),('restored-customer',['python3','Perf/customer-benchmark.py',old,new,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),('withdrawal-control',['python3','Perf/scene-benchmark.py',bad,new,'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','3','--cpu','13'])]
rows=[]
for label,cmd in commands:
 cmd=cmd+['--output',str(logs/(label+'.json'))]
 with (logs/(label+'.log')).open('wb') as out:r=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 row=dict(case=label,command=cmd,status=r.returncode);rows.append(row);print(row,flush=True);assert r.returncode==0
(logs/'measurement-summary.json').write_text(json.dumps(dict(passed=True,runs=rows),indent=2)+'\n')
