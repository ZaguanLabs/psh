from pathlib import Path
import hashlib,json,subprocess,time
root=Path.cwd();logs=root/'.work/logs/rc0';rows=[]
def run(name,args,cwd=None):
 start=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(args,cwd=cwd or root,stdout=out,stderr=subprocess.STDOUT)
 rows.append({'name':name,'command':args,'cwd':str(cwd or root),'status':r.returncode,'seconds':round(time.monotonic()-start,3)})
 (logs/'clang-receipt.json').write_text(json.dumps(rows,indent=2)+'\n');print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
for name,source in [('baseline',root/'.work/pristine'),('candidate',root)]:
 folder=root/'.work'/('rc-clang-'+name);folder.mkdir(exist_ok=True)
 run('clang-'+name+'-configure',[str(source/'configure'),'--prefix='+str(folder/'runtime'),'--enable-multibyte','--enable-dynamic','--enable-pcre','--enable-zsh-debug','CC=clang','CFLAGS=-O2 -g'],folder)
 run('clang-'+name+'-build',['make','-j4'],folder)
 run('clang-'+name+'-modules',['make','MODDIR='+str(folder/'runtime/lib/zsh/5.9.2'),'install.modules'],folder)
 run('clang-'+name+'-upstream',['make','check'],folder)
before='.work/rc-clang-baseline/Src/zsh';after='.work/rc-clang-candidate/Src/zsh'
run('clang-math',['python3','Perf/math-compare.py',before,after,'--syntax','--locale','C','--locale','C.UTF-8','--locale','fr_BE.UTF-8','--output',str(logs/'clang-math.json')])
run('clang-numeric-api',['python3','Perf/check-math-locale-module.py',before,after,'--headers-build','.work/rc-clang-baseline','--memcheck','--locale','C','--locale','C.UTF-8','--locale','fr_BE.UTF-8','--output',str(logs/'clang-numeric-api.json')])
run('clang-scalars',['python3','Perf/scalar-compare.py',before,after,'--assignments','--prefixes','--output',str(logs/'clang-scalars.json')])
run('clang-patterns',['python3','Perf/pattern-compare.py',before,after,'--extended','--output',str(logs/'clang-patterns.json')])
print('CLANG VALIDATION PASSED',flush=True)
