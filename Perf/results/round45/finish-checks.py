import json,subprocess,time,hashlib,os
from pathlib import Path
r=Path('.work/round45');b=Path('.work/package/1.0.0-rc1-345edd03d312/build.json');started=time.monotonic()
while True:
 try:os.kill(2615703,0);running=True
 except ProcessLookupError:running=False
 ready=True
 for n in ('array-copy','compare'):
  try:x=json.loads((r/(n+'.json')).read_text());ready=ready and x['passed']
  except FileNotFoundError:ready=False
 if not running and ready:break
 if time.monotonic()-started>1200:raise RuntimeError('prerequisite checks did not pass')
 time.sleep(2)
results=[]
def run(name,cmd):
 with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1800)
 results.append(dict(name=name,command=cmd,status=p.returncode));print(name,p.returncode,flush=True)
 if p.returncode:raise RuntimeError((name,p.returncode))
run('core',['python3','Packaging/test.py','--build',str(b),'--suite','core','--jobs','1'])
run('stage',['python3','Packaging/verify.py','stage-modules','--build',str(b)])
run('refresh',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(b)])
run('verify',['python3','Packaging/verify.py','verify','--build',str(b)])
(r/'final-checks.json').write_text(json.dumps(dict(passed=True,runs=results),indent=2)+'\n')
