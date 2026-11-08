from pathlib import Path
import hashlib,json,os,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round19';rows=[]
def run(name,cmd,cwd=None,env=None):
 start=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:
  r=subprocess.run(cmd,cwd=cwd or root,env=env,stdout=out,stderr=subprocess.STDOUT)
 rows.append({'name':name,'command':cmd,'cwd':str(cwd or root),'status':r.returncode,'seconds':round(time.monotonic()-start,3)})
 (logs/'alternative-validation-receipt.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
def build(name,source,extra):
 folder=root/'.work'/name;folder.mkdir(exist_ok=True)
 run(name+'-configure',[str(source/'configure'),'--prefix='+str(folder/'runtime'),'--enable-multibyte','--enable-zsh-debug','CFLAGS=-O2 -g',*extra],folder)
 run(name+'-build',['make','-j4'],folder)
 run(name+'-modules',['make','MODDIR='+str(folder/'runtime/lib/zsh/5.9.2'),'install.modules'],folder)
 return folder
legacy=build('legacy-locale-candidate',root,['zsh_cv_math_strtod_l=no'])
run('legacy-locale-upstream',['make','check','TESTNUM=C01'],legacy)
run('legacy-locale-api',['python3','Perf/check-math-locale-module.py','.work/baseline/Src/zsh',str(legacy/'Src/zsh'),'--headers-build',str(legacy),'--memcheck','--locale','C','--locale','C.UTF-8','--locale','fr_FR.UTF-8','--output',str(logs/'legacy-locale-api.json')])
run('legacy-locale-corpus',['python3','Perf/math-compare.py','.work/baseline/Src/zsh',str(legacy/'Src/zsh'),'--output',str(logs/'legacy-locale-corpus.json')])
before=build('no-locale-baseline',root/'.work/pristine',['ac_cv_func_setlocale=no'])
after=build('no-locale-candidate',root,['ac_cv_func_setlocale=no'])
for label,folder in [('baseline',before),('candidate',after)]:run('no-locale-'+label+'-upstream',['make','check','TESTNUM=C01'],folder)
run('no-locale-api',['python3','Perf/check-math-locale-module.py',str(before/'Src/zsh'),str(after/'Src/zsh'),'--headers-build',str(before),'--memcheck','--locale','C','--locale','C.UTF-8','--locale','fr_FR.UTF-8','--output',str(logs/'no-locale-api.json')])
run('no-locale-corpus',['python3','Perf/math-compare.py',str(before/'Src/zsh'),str(after/'Src/zsh'),'--output',str(logs/'no-locale-corpus.json')])
print('ALL ALTERNATIVE CONFIGURATIONS PASSED',flush=True)
