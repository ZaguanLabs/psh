from pathlib import Path
import json,subprocess
l=Path('.work/logs/round26');b=json.loads(Path('.work/package/latest.json').read_text());old=json.loads((l/'parent.json').read_text())['installed_prefix']
commands=[('clang-strtol',['.work/round26/clang-previous/Src/zsh','.work/round26/clang-candidate/Src/zsh','--headers-build','.work/round26/clang-previous','--headers-source','.work/round26/previous-source']),('development-strtol',['.work/baseline/Src/zsh','./psh']),('installed-strtol',[old+'/bin/psh',b['prefix']+'/bin/psh','--headers-build',b['core'],'--headers-source',b['core']])]
for name,hosts in commands:
 cmd=['python3','Perf/check-strtol-module.py',*hosts,'--memcheck','--locale','C.UTF-8','--output',str(l/(name+'.json'))]
 with (l/(name+'.log')).open('wb') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
 print(name,'passed',flush=True)
