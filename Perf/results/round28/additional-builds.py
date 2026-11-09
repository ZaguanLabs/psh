from pathlib import Path
import json,subprocess,time
l=Path('.work/logs/round28')
def run(name,cmd):
 with (l/(name+'.log')).open('wb') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
 print(name,r.returncode,flush=True);assert not r.returncode
run('clang-build',['python3',str(l/'clang-build.py')])
run('development-build',['python3','Perf/build.py','--which','candidate','--jobs','4'])
run('additional-upstream',['python3',str(l/'additional-upstream.py')])
for name,hosts,headers,source in [('clang-prefix',['.work/round28/clang-previous/Src/zsh','.work/round28/clang-candidate/Src/zsh'],'.work/round28/clang-previous','.work/round28/previous-source'),('development-prefix',['.work/baseline/Src/zsh','./psh'],'.work/baseline','.work/pristine')]:
 run(name,['python3','Perf/check-append-prefix.py',*hosts,'--headers-build',headers,'--headers-source',source,'--memcheck','--locale','C.UTF-8','--output',str(l/(name+'.json'))])
