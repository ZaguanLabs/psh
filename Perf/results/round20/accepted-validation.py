from pathlib import Path
import concurrent.futures, hashlib, json, shlex, subprocess, time
root=Path.cwd();logs=root/'.work/logs/round20';rows=[]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(name,args,cwd=None,env=None):
 started=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:
  r=subprocess.run(args,cwd=cwd or root,env=env,stdout=out,stderr=subprocess.STDOUT)
 row={'name':name,'command':args,'cwd':str(cwd or root),'status':r.returncode,'elapsed_seconds':round(time.monotonic()-started,3)}
 rows.append(row);print(name, r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
def diff(name,script,extra=(),baseline='.work/baseline/Src/zsh',candidate='.work/candidate/Src/zsh'):
 run(name,['python3','Perf/'+script,baseline,candidate,*extra,'--output',str(logs/(name+'.json'))])
def no_mb():
 run('no-mb-build-final',['make','-C','.work/no-mb-candidate','-j8'])
 run('no-mb-install-modules',['make','-C','.work/no-mb-candidate','MODDIR='+str(root/'.work/no-mb-runtime/lib/zsh/5.9.2'),'install.modules'])
 for name,test in [('no-mb-upstream','D*'),('no-mb-conditionals','C02'),('no-mb-math','C01')]:run(name,['make','-C','.work/no-mb-candidate','check','TESTNUM='+test])
 diff('accepted-math-no-mb','check-math-locale-module.py',['--memcheck','--headers-build','.work/no-mb-baseline'],baseline='.work/no-mb-baseline/Src/zsh',candidate='.work/no-mb-candidate/Src/zsh')
 diff('accepted-math-corpus-no-mb','math-compare.py',['--syntax','--locale','C','--locale','C.UTF-8'],baseline='.work/no-mb-baseline/Src/zsh',candidate='.work/no-mb-candidate/Src/zsh')
 diff('accepted-scalars-no-mb','scalar-compare.py',['--assignments','--prefixes'],baseline='.work/no-mb-baseline/Src/zsh',candidate='.work/no-mb-candidate/Src/zsh')
def memcheck(name,script):
 args=['valgrind','--error-exitcode=97','--leak-check=no','--log-file='+str(logs/(name+'.log')),str(root/'.work/candidate/Src/zsh'),'-df',script]
 with (logs/(name+'-output.log')).open('wb') as out,(logs/(name+'-stderr.log')).open('wb') as err:
  r=subprocess.run(args,stdout=out,stderr=err,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'})
 rows.append({'name':name,'command':args,'status':r.returncode});print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
def applications():
 checks=[]
 for locale in ['C','C.UTF-8']:
  for test in ['/home/stig/dev/ai/zaguan/labs/zjson/tests/run.zsh','/home/stig/dev/ai/zaguan/labs/zoup/tests/clean.zsh','/home/stig/dev/ai/zaguan/labs/zoup/tests/streams.zsh','/home/stig/dev/challenge/z3dfx/tests/engine.zsh']:
   data=[]
   for shell in [root/'.work/baseline/Src/zsh',root/'.work/candidate/Src/zsh']:
    r=subprocess.run([str(shell),'-df',test],cwd=Path(test).parent.parent,env={'PATH':'/usr/bin:/bin','LC_ALL':locale},capture_output=True,timeout=300);data.append((r.returncode,r.stdout,r.stderr))
   assert data[0]==data[1] and data[0][0]==0,(test,locale,data)
   checks.append({'test':test,'locale':locale,'source_sha256':sha(Path(test)),'stdout':data[0][1].decode(),'status':0})
 (logs/'application-tests.json').write_text(json.dumps(checks,indent=2)+'\n');print('application suites matched',flush=True)
def pristine_test():
 for test in ['C01arith.ztst','D06subscript.ztst','D07multibyte.ztst']:
  cmd=[str(root/'.work/baseline/Src/zsh'),'+Z','-f',str(root/'Test/runtests.zsh')]
  env={'PATH':'/usr/bin:/bin','ZTST_srcdir':str(root/'Test'),'ZTST_exe':str(root/'.work/baseline/Src/zsh'),'ZTST_testlist':str(root/'Test'/test)}
  run('accepted-pristine-'+test,cmd,root/'.work/baseline/Test',env)
def html():
 run('html-final',[str(root/'.work/candidate/Src/zsh'),'-df','tests/run.zsh'],Path('/home/stig/dev/ai/zaguan/labs/zhtml2md'),{'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','ZHTML2MD_TEST_ZSH':str(root/'.work/candidate/Src/zsh')})
tasks=[lambda:run('accepted-upstream',['make','-C','.work/candidate','check']),pristine_test,no_mb,
 lambda:diff('accepted-math-api','check-math-locale-module.py',['--memcheck']),
 lambda:diff('accepted-math-corpus','math-compare.py',['--syntax']),

 lambda:diff('accepted-scalars','scalar-compare.py',['--assignments','--prefixes','--locale','C','--locale','C.UTF-8','--locale','ja_JP.eucjp','--locale','zh_CN.GB18030','--locale','zh_TW.EUC-TW']),
 lambda:diff('accepted-accessors','check-append-module.py',['--search']),
 lambda:diff('accepted-completion','check-completion-prefix.py'),
 lambda:diff('accepted-substitution','substitution-compare.py'),
 lambda:diff('accepted-search','search-compare.py',['--scalars']),
 lambda:diff('accepted-arrays','compare.py',['--appends']),
 lambda:diff('accepted-patterns','pattern-compare.py',['--extended','--locale','C','--locale','C.UTF-8','--locale','ja_JP.eucjp','--locale','zh_CN.GB18030','--locale','zh_TW.EUC-TW']),
 applications,html,lambda:run('accepted-customer-correctness',['python3','.work/logs/round20/accepted-customer-correctness.py'])]
failed=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
 futures=[pool.submit(t) for t in tasks]
 for f in futures:
  try:f.result()
  except Exception as e:failed.append(repr(e))
(logs/'accepted-validation-receipt.json').write_text(json.dumps({'source_sha256':{p:sha(root/p) for p in ['Src/math.c','Test/C01arith.ztst','Perf/math-locale-module.c','Perf/check-math-locale-module.py','Perf/math-compare.py']},'binary_sha256':sha(root/'.work/candidate/Src/zsh'),'runs':rows,'failures':failed},indent=2)+'\n')
assert not failed,failed
print('ALL FINAL VALIDATION PASSED',flush=True)
