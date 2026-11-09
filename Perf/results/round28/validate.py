from pathlib import Path
import concurrent.futures, hashlib, json, subprocess, time
root=Path.cwd(); logs=root/'.work/logs/round28'; before='.work/round28/previous/Src/zsh'; after='.work/round28/candidate/Src/zsh'; rows=[]
def run(name,args):
 start=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(args,stdout=out,stderr=subprocess.STDOUT)
 row=dict(name=name,command=args,status=r.returncode,seconds=round(time.monotonic()-start,3));rows.append(row);print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
def diff(name,script,*args):
 run(name,['python3','Perf/'+script,before,after,*args,'--output',str(logs/(name+'.json'))])
tasks=[lambda:diff('emulation-front','emulation-compare.py'),
 lambda:diff('math','math-compare.py','--syntax'),
 lambda:diff('scalars','scalar-compare.py','--assignments','--prefixes','--locale','C','--locale','C.UTF-8','--locale','ja_JP.eucjp','--locale','zh_CN.GB18030','--locale','zh_TW.EUC-TW'),
 lambda:diff('arrays','compare.py','--appends'),
 lambda:diff('search','search-compare.py','--scalars'),
 lambda:diff('patterns','pattern-compare.py','--extended','--locale','C','--locale','C.UTF-8','--locale','ja_JP.eucjp','--locale','zh_CN.GB18030','--locale','zh_TW.EUC-TW'),
 lambda:diff('substitution','substitution-compare.py'),
 lambda:diff('numeric-api','check-math-locale-module.py','--headers-build','.work/round28/previous','--memcheck','--locale','C','--locale','C.UTF-8','--locale','fr_BE.UTF-8'),
 lambda:diff('accessors','check-append-module.py','--search'),
 lambda:diff('completion','check-completion-prefix.py'),
 lambda:run('customer',['python3',str(logs/'customer-correctness.py')])]
failures=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 futures=[pool.submit(t) for t in tasks]
 for f in futures:
  try:f.result()
  except Exception as e:failures.append(repr(e))
(logs/'validation.json').write_text(json.dumps(dict(passed=not failures,runs=rows,failures=failures,binary_sha256={p:hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in [before,after]}),indent=2)+'\n')
assert not failures,failures
