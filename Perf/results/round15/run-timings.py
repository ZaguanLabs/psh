from pathlib import Path
import json,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round15';shells=['.work/round14/psh','.work/candidate/Src/zsh'];rows=[]
cases=[('customer-benchmarks','customer-benchmark.py',['--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge']),('application-benchmarks','applications.py',['--arrays','--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--z3dfx','/home/stig/dev/challenge/z3dfx']),('parser-benchmarks','parser-benchmark.py',['--zhtml2md','/home/stig/dev/ai/zaguan/labs/zhtml2md','--zjson','/home/stig/dev/ai/zaguan/labs/zjson','--zoup','/home/stig/dev/ai/zaguan/labs/zoup'])]
for name,driver,extra in cases:
 cmd=['python3','Perf/'+driver,*shells,*extra,'--samples','9','--cpu','2','--output',str(logs/(name+'.json'))];started=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 rows.append({'command':cmd,'status':r.returncode,'elapsed_seconds':time.monotonic()-started})
 (logs/'timing-receipt.json').write_text(json.dumps(rows,indent=2)+'\n')
 assert r.returncode==0,name
 print(name,'complete',flush=True)
