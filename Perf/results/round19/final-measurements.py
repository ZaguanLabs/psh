from pathlib import Path
import subprocess
logs=Path('.work/logs/round19')
commands=[('customer-benchmarks',['python3','Perf/customer-benchmark.py','.work/round17/psh','.work/candidate/Src/zsh','--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--cpu','2','--samples','9','--output',str(logs/'customer-benchmarks.json')]),('hardware-benchmarks',['python3','Perf/hardware-benchmark.py','.work/round17/psh','.work/candidate/Src/zsh','--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--cpu','2','--samples','9','--output',str(logs/'hardware-benchmarks.json')])]
for name,cmd in commands:
 with (logs/(name+'.log')).open('wb') as out:subprocess.run(cmd,check=True,stdout=out,stderr=subprocess.STDOUT)
 print(name,'complete',flush=True)
subprocess.run(['python3',str(logs/'timings.py')],check=True)
