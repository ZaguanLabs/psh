from pathlib import Path
import json,subprocess,tempfile
r=Path.cwd();l=r/'.work/logs/round34';rows=[]
def run(name,cmd,**kw):
 with (l/(name+'.log')).open('wb') as out:process=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,**kw)
 rows.append(dict(name=name,command=cmd,status=process.returncode));(l/'additional-builds.json').write_text(json.dumps(rows,indent=2)+'\n');print(name,process.returncode,flush=True);assert process.returncode==0,name
run('clang-build',['python3',str(l/'clang-build.py')]);run('development-build',['python3','Perf/build.py','--which','candidate','--jobs','4']);run('additional-upstream',['python3',str(l/'additional-upstream.py')])
run('clang-scope',['python3','Perf/check-scope-cleanup-module.py','.work/round34/clang-previous/Src/zsh','.work/round34/clang-candidate/Src/zsh','--headers-build','.work/round34/clang-previous','--headers-source','.work/round34/previous-source','--candidate-headers-build','.work/round34/clang-candidate','--candidate-headers-source','.','--memcheck','--locale','C.UTF-8','--output',str(l/'clang-scope.json')])
run('development-scope',['python3','Perf/check-scope-cleanup-module.py','.work/baseline/Src/zsh','./psh','--candidate-headers-build','.work/candidate','--candidate-headers-source','.','--memcheck','--locale','C.UTF-8','--output',str(l/'development-scope.json')])
