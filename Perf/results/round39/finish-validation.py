from pathlib import Path
import subprocess,json,time
root=Path.cwd();work=root/'.work/package/1.0.0-rc1-a446099eaf93';logs=root/'.work/round39/logs';build=work/'build.json'
limit=time.monotonic()+600
while not (work/'test-zdraw.json').exists():
 if time.monotonic()>limit:raise RuntimeError('zdraw suite did not finish')
 time.sleep(1)
commands=[('stage-modules',['python3','Packaging/verify.py','stage-modules','--build',str(build)]),('refresh-modules',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(build)]),('package-verify',['python3','Packaging/verify.py','verify','--build',str(build)])]
rows=[]
for label,cmd in commands:
 with (logs/(label+'.log')).open('wb') as out:r=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 rows.append(dict(case=label,command=cmd,status=r.returncode));print(rows[-1],flush=True)
 assert r.returncode==0
(logs/'verification-summary.json').write_text(json.dumps(dict(passed=True,runs=rows),indent=2)+'\n')
