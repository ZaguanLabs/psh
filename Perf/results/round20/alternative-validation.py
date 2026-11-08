from pathlib import Path
import hashlib,json,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round20';rows=[]
def run(name,args,cwd=None):
 started=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(args,cwd=cwd or root,stdout=out,stderr=subprocess.STDOUT)
 rows.append({'name':name,'command':args,'cwd':str(cwd or root),'status':r.returncode,'seconds':round(time.monotonic()-started,3)})
 (logs/'alternative-validation-receipt.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
for label,base in [('legacy-locale','.work/baseline'),('no-locale','.work/no-locale-baseline')]:
 folder=root/'.work'/(label+'-candidate')
 run(label+'-build',['make','-j4'],folder)
 run(label+'-upstream',['make','check','TESTNUM=C01'],folder)
 run(label+'-corpus',['python3','Perf/math-compare.py',base+'/Src/zsh',str(folder/'Src/zsh'),'--syntax','--locale','C','--locale','C.UTF-8','--output',str(logs/(label+'-corpus.json'))])
 run(label+'-api',['python3','Perf/check-math-locale-module.py',base+'/Src/zsh',str(folder/'Src/zsh'),'--headers-build',base,'--memcheck','--locale','C','--locale','C.UTF-8','--output',str(logs/(label+'-api.json'))])
print('ALL ALTERNATIVE CONFIGURATIONS PASSED',flush=True)
