from pathlib import Path
import json,subprocess,time
l=Path('.work/logs/round30');rows=[]
commands=[('package-build',['python3','Packaging/build.py','--jobs','4']),('package-snapshot',['python3','Packaging/verify.py','snapshot']),('package-install',['sudo','-n','python3','Packaging/install.py','candidate']),('package-tests',['python3','Packaging/test.py','--jobs','3']),('stage-modules',['python3','Packaging/verify.py','stage-modules']),('refresh-modules',['sudo','-n','python3','Packaging/install.py','refresh-modules']),('verification',['python3','Packaging/verify.py','verify'])]
for name,cmd in commands:
 start=time.monotonic()
 with (l/(name+'.log')).open('wb') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
 rows.append(dict(name=name,command=cmd,status=r.returncode,seconds=time.monotonic()-start));(l/'package-commands.json').write_text(json.dumps(rows,indent=2)+'\n');print(name,r.returncode,flush=True);assert not r.returncode
