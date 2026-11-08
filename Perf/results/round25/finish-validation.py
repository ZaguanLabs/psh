from pathlib import Path
import json,subprocess,time
logs=Path('.work/logs/round25');b=json.loads(Path('.work/package/latest.json').read_text());work=Path(b['work'])
while not (work/'test-zdraw.json').exists():time.sleep(2)
for name in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:assert json.loads((work/('test-'+name+'.json')).read_text())['passed'],name
for phase,command in [('stage-modules',['python3','Packaging/verify.py','stage-modules']),('refresh-modules',['sudo','-n','python3','Packaging/install.py','refresh-modules']),('verification',['python3','Packaging/verify.py','verify'])]:
 with (logs/(phase+'.log')).open('wb') as out:subprocess.run(command,stdout=out,stderr=subprocess.STDOUT,check=True)
 print(phase,'passed',flush=True)
