from pathlib import Path
import concurrent.futures,hashlib,json,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round18';rows=[]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(name,cmd,cwd=root,env=None):
 started=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:
  r=subprocess.run(cmd,cwd=cwd,env=env,stdout=out,stderr=subprocess.STDOUT)
 rows.append({'name':name,'command':cmd,'cwd':str(cwd),'status':r.returncode,'seconds':round(time.monotonic()-started,3)})
 print(name,r.returncode,flush=True)
 if r.returncode:raise RuntimeError(name)
def native(name,candidate,headers='.work/baseline',baseline='.work/baseline/Src/zsh'):
 run(name,['python3','Perf/check-hash-scan-module.py',baseline,candidate,'--memcheck','--headers-build',headers,'--output',str(logs/(name+'.json'))])
def scopes():
 hosts=[('pristine','.work/baseline/Src/zsh'),('round17','.work/round17/psh'),('filter-hoist','.work/round18-filter-hoist/psh'),('wrapper','.work/round18-wrapper/psh'),('installed','/usr/local/psh/releases/5.9.2-38c0e71e2244/bin/psh')]
 for name,path in hosts:
  for file in ['Perf/hash-scope.ztst','Test/B02typeset.ztst','Test/V10private.ztst']:
   shell=(root/path).resolve();assert shell.is_file()
   env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','ZTST_srcdir':str(root/'Test'),'ZTST_exe':str(shell),'ZTST_testlist':str(root/file)}
   run('scope-'+name+'-'+Path(file).stem,[str(shell),'+Z','-f',str(root/'Test/runtests.zsh')],root/'.work/baseline/Test',env)
jobs=[lambda:native('filter-hoist-api','.work/round18-filter-hoist/psh'),lambda:native('wrapper-api','.work/round18-wrapper/psh'),lambda:native('installed-api','/usr/local/psh/releases/5.9.2-38c0e71e2244/bin/psh'),lambda:native('no-mb-api','.work/no-mb-candidate/Src/zsh','.work/no-mb-baseline','.work/no-mb-baseline/Src/zsh'),scopes]
failures=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
 futures=[pool.submit(job) for job in jobs]
 for f in futures:
  try:f.result()
  except Exception as e:failures.append(repr(e))
(logs/'validation-receipt.json').write_text(json.dumps({'runs':rows,'failures':failures,'fixture_sha256':sha(root/'Perf/hash-scan-module.c'),'driver_sha256':sha(root/'Perf/check-hash-scan-module.py'),'regression_sha256':sha(root/'Perf/hash-scope.ztst')},indent=2)+'\n')
assert not failures,failures
