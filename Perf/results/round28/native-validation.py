from pathlib import Path
import concurrent.futures,json,subprocess,time
root=Path.cwd();l=root/'.work/logs/round28';before='.work/round28/previous/Src/zsh';after='.work/round28/candidate/Src/zsh'
commands=[('append-prefix-native',['python3','Perf/check-append-prefix.py','.work/baseline/Src/zsh',after,'--headers-build','.work/baseline','--headers-source','.work/pristine','--memcheck']),('cache-native',['python3','Perf/check-array-cache.py',before,after,'--headers-build','.work/round28/previous','--headers-source','.work/round28/previous-source','--memcheck']),('cache-signals',['python3','Perf/check-array-cache-signals.py',after,'--search']),('length-native',['python3','Perf/check-array-length-module.py',before,after,'--memcheck'])]
def run(row):
 name,cmd=row;cmd=cmd+['--output',str(l/(name+'.json'))];start=time.monotonic()
 with (l/(name+'.log')).open('wb') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
 print(name,r.returncode,flush=True);return dict(name=name,command=cmd,status=r.returncode,seconds=time.monotonic()-start)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as p:rows=list(p.map(run,commands))
(l/'native-validation.json').write_text(json.dumps(dict(passed=all(r['status']==0 for r in rows),runs=rows),indent=2)+'\n');assert all(r['status']==0 for r in rows)
