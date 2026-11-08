import subprocess
from pathlib import Path
logs=Path('.work/logs/round20')
previous='.work/round19/psh';candidate='.work/candidate/Src/zsh';labs='/home/stig/dev/ai/zaguan/labs/'
commands=[
('slice-benchmarks',['python3','Perf/slice-benchmark.py',previous,candidate,'--indices','--counts']),
('application-benchmarks',['python3','Perf/applications.py',previous,candidate,'--zjson',labs+'zjson','--z3dfx','/home/stig/dev/challenge/z3dfx','--arrays']),
('parser-benchmarks',['python3','Perf/parser-benchmark.py',previous,candidate,'--zhtml2md',labs+'zhtml2md','--zjson',labs+'zjson','--zoup',labs+'zoup'])]
for name,cmd in commands:
 with (logs/(name+'.log')).open('wb') as out:
  subprocess.run(cmd+['--cpu','2','--samples','9','--output',str(logs/(name+'.json'))],check=True,stdout=out,stderr=subprocess.STDOUT)
 print(name,'complete',flush=True)
