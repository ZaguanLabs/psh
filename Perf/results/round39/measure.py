from pathlib import Path
import subprocess,json
root=Path.cwd();logs=root/'.work/round39/logs'
old='/usr/local/psh/releases/1.0.0-rc1-b0850020f4a1/bin/psh';new='/usr/local/psh/releases/1.0.0-rc1-a446099eaf93/bin/psh'
scene=['python3','Perf/scene-benchmark.py',old,new,'--project','/home/stig/dev/challenge/z3dfx.drawing','--samples','5','--cpu','13']
commands=[('final-scenes',scene),('final-customer',['python3','Perf/customer-benchmark.py',old,new,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13']),('same-binary-fallback',['python3','Perf/scene-benchmark.py',new,new,'--project','/home/stig/dev/challenge/z3dfx.drawing','--samples','5','--cpu','13','--scene','moonlit','--baseline-preload',str(root/'.work/round39/opaque-preload.so')]),('final-scene-repeat',scene+['--scene','moonlit'])]
rows=[]
for label,cmd in commands:
 command=cmd+['--output',str(logs/(label+'.json'))]
 with (logs/(label+'.log')).open('wb') as out:r=subprocess.run(command,stdout=out,stderr=subprocess.STDOUT)
 row=dict(case=label,command=command,status=r.returncode);rows.append(row);print(row,flush=True)
 assert r.returncode==0
(logs/'measurement-summary.json').write_text(json.dumps(dict(passed=True,runs=rows),indent=2)+'\n')
