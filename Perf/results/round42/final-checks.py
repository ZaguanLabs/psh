import concurrent.futures,json,subprocess,time
from pathlib import Path
r=Path('.work/round42');b=Path('.work/package/1.0.0-rc1-6db51a2527d4/build.json')
limit=time.monotonic()+600
while not b.exists():
 if time.monotonic()>limit:raise RuntimeError('final build not ready')
 time.sleep(1)
def command(name,cmd,expected=0):
 with (r/(name+'.log')).open('wb') as out:
  p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=2400)
 if p.returncode!=expected:raise RuntimeError((name,p.returncode,expected))
 print(name,p.returncode,flush=True)
 return {'name':name,'command':cmd,'status':p.returncode,'expected_status':expected}
command('snapshot-final',['python3','Packaging/verify.py','snapshot','--build',str(b)])
command('install-final',['sudo','-n','python3','Packaging/install.py','candidate','--build',str(b)])
base=(r/'validate.py').read_text()
for group,reference in [('final-reference',None),('final-preceding','/usr/local/psh/releases/1.0.0-rc1-519928894f02/bin/psh')]:
 s=base.replace("logs=root/'.work/round42/logs'",f"logs=root/'.work/round42/{group}'").replace('cde7f840ec94','6db51a2527d4')
 if reference:
  s=s.replace("reference=root/'.work/public-rc0/reference/Src/zsh'",f"reference=Path('{reference}')").replace(",'--raw-contract'",'')
 (r/group).mkdir(exist_ok=True)
 (r/(group+'.py')).write_text(s)
cases=[('package-final',['python3','Packaging/test.py','--build',str(b),'--jobs','3']),
 ('final-reference',['python3',str(r/'final-reference.py')]),
 ('final-preceding',['python3',str(r/'final-preceding.py')])]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 results=list(pool.map(lambda row: command(*row),cases))
args=['--headers-build','.work/public-rc0/reference','--headers-source','.work/pristine','--memcheck']
results.append(command('reentry-final-negative',['python3','Perf/check-hash-reentry-module.py','.work/public-rc0/reference/Src/zsh','/usr/local/psh/releases/1.0.0-rc1-519928894f02/bin/psh',*args,'--output',str(r/'reentry-final-negative.json')],1))
results.append(command('reentry-final-positive',['python3','Perf/check-hash-reentry-module.py','/usr/local/psh/releases/1.0.0-rc1-6db51a2527d4/bin/psh',*args,'--output',str(r/'reentry-final-positive.json')]))
results.append(command('stage-final',['python3','Packaging/verify.py','stage-modules','--build',str(b)]))
results.append(command('refresh-final',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(b)]))
results.append(command('verify-final',['python3','Packaging/verify.py','verify','--build',str(b)]))
(r/'final-checks.json').write_text(json.dumps({'passed':True,'runs':results},indent=2)+'\n')
