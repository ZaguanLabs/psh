import json,subprocess,time,hashlib,os
from pathlib import Path
r=Path('.work/round44');b=Path('.work/package/1.0.0-rc1-fcff3fb31d43/build.json')
start=time.monotonic()
while True:
 try:os.kill(2281172,0);package_running=True
 except ProcessLookupError:package_running=False
 reports=[]
 for n in ('release-check','heap-check'):
  x=json.loads((r/(n+'.json')).read_text())
  reports.append(x['passed'] and x['driver_sha256']==hashlib.sha256(Path('Perf/check-glob-programs.py').read_bytes()).hexdigest())
 if not package_running and all(reports):break
 if time.monotonic()-start>1200:raise RuntimeError('test prerequisites not ready')
 time.sleep(2)
results=[]
def run(name,cmd):
 with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1800)
 results.append(dict(name=name,command=cmd,status=p.returncode));print(name,p.returncode,flush=True)
 if p.returncode:raise RuntimeError((name,p.returncode))
run('core-isolated',['python3','Packaging/test.py','--build',str(b),'--suite','core','--jobs','1'])
run('stage',['python3','Packaging/verify.py','stage-modules','--build',str(b)])
run('refresh',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(b)])
run('verify',['python3','Packaging/verify.py','verify','--build',str(b)])
(r/'final-checks.json').write_text(json.dumps(dict(passed=True,runs=results),indent=2)+'\n')
