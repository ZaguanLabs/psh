from pathlib import Path
import subprocess,json,time
r=Path('.work/round47');b=Path('.work/package/1.0.0-rc1-1d2a092078fb/build.json');rows=[]
for name,cmd in [
 ('snapshot',['python3','Packaging/verify.py','snapshot','--build',str(b)]),
 ('install',['sudo','-n','python3','Packaging/install.py','candidate','--build',str(b)]),
 ('package-test',['python3','Packaging/test.py','--build',str(b),'--jobs','1']),
 ('stage',['python3','Packaging/verify.py','stage-modules','--build',str(b)]),
 ('refresh',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(b)]),
 ('verify',['python3','Packaging/verify.py','verify','--build',str(b)]),
]:
 print('Starting',name,flush=True);start=time.time()
 with (r/(name+'.log')).open('wb') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,timeout=1800)
 rows.append(dict(name=name,command=cmd,status=p.returncode,seconds=time.time()-start))
 (r/'check-session.json').write_text(json.dumps(rows,indent=2)+'\n')
 if p.returncode:raise RuntimeError((name,p.returncode))
 print('Passed',name,flush=True)
(r/'final-checks.json').write_text(json.dumps(dict(passed=True,runs=rows),indent=2)+'\n')
