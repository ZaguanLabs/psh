import concurrent.futures,json,subprocess,time
from pathlib import Path
root=Path.cwd();logs=root/'.work/round40/logs';selection=root/'.work/package/1.0.0-rc1-519928894f02/build.json'
limit=time.monotonic()+600
while not selection.exists():
 if time.monotonic()>limit:raise RuntimeError('selected build unavailable')
 time.sleep(1)
b=json.loads(selection.read_text());shell=Path(b['prefix'])/'bin/psh';core=Path(b['core'])
while not shell.exists():
 if time.monotonic()>limit:raise RuntimeError('selected shell not installed')
 time.sleep(1)
reference=root/'.work/public-rc0/reference/Src/zsh'
base=['python3'];pair=[str(reference),str(shell)]
cases={
'array':['Perf/compare.py',*pair,'--appends'],
'scalar':['Perf/scalar-compare.py',*pair,'--assignments','--prefixes'],
'search':['Perf/search-compare.py',*pair,'--scalars','--large'],
'pattern':['Perf/pattern-compare.py',*pair,'--extended'],
'substitution':['Perf/substitution-compare.py',*pair],
'emulation':['Perf/emulation-compare.py',*pair],
'math':['Perf/math-compare.py',*pair,'--operators','--syntax','--descriptors','--state-frames'],
'stateful':['Perf/stateful-compare.py',*pair,'--steps','1000'],
'stateful-memcheck':['Perf/stateful-compare.py',*pair,'--steps','150','--seed','11','--seed','29','--memcheck'],
'array-native':['Perf/check-array-cache.py',*pair,'--headers-build','.work/public-rc0/reference','--headers-source','.work/pristine','--memcheck','--raw-contract','--locale','C','--locale','C.UTF-8'],
'scope-native':['Perf/check-scope-cleanup-module.py',*pair,'--headers-build','.work/public-rc0/reference','--headers-source','.work/pristine','--candidate-headers-build',str(core),'--candidate-headers-source',str(core),'--aware','--memcheck','--locale','C','--locale','C.UTF-8'],
'math-native':['Perf/check-math-locale-module.py',*pair,'--headers-build','.work/public-rc0/reference','--memcheck','--locale','C','--locale','C.UTF-8']}
def run(item):
 name,command=item
 cmd=base+command+['--output',str(logs/('selected-'+name+'.json'))]
 start=time.monotonic()
 with (logs/('selected-'+name+'.log')).open('wb') as out:
  r=subprocess.run(cmd,cwd=root,stdout=out,stderr=subprocess.STDOUT,timeout=1800)
 row={'name':name,'command':cmd,'status':r.returncode,'seconds':round(time.monotonic()-start,3)}
 print(name,r.returncode,flush=True)
 return row
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:rows=list(pool.map(run,cases.items()))
report={'passed':all(r['status']==0 for r in rows),'release':b['release'],'shell':str(shell),'runs':rows}
(logs/'selected-correctness.json').write_text(json.dumps(report,indent=2)+'\n')
assert report['passed'],rows
