import json,subprocess,time
from pathlib import Path
root=Path.cwd();logs=root/'.work/rc1/logs';selection=root/'.work/rc1/selected-build.json'
limit=time.monotonic()+1200
while not selection.exists():
 if time.monotonic()>limit:raise RuntimeError('selection unavailable')
 time.sleep(1)
b=json.loads(selection.read_text());validation=Path(b['work'])/'validation.json';correctness=logs/'selected-correctness.json'
while not validation.exists() or not correctness.exists():
 if time.monotonic()>limit:raise RuntimeError('validation unavailable')
 time.sleep(1)
v=json.loads(validation.read_text());assert v['passed'] and v['ohmyzsh']['sessions']==24
assert json.loads(correctness.read_text())['passed']
reference=Path('/usr/local/psh/releases/1.0.0-rc0-7e8f4c48abf5/bin/psh')
candidate=Path(b['prefix'])/'bin/psh';pair=[str(reference),str(candidate)]
commands=[
 ('scenes',['python3','Perf/scene-benchmark.py',*pair,'--project','/home/stig/dev/challenge/z3dfx.drawing','--samples','5','--cpu','13','--output',str(logs/'selected-scenes.json')]),
 ('customer',['python3','Perf/customer-benchmark.py',*pair,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13','--output',str(logs/'selected-customer.json')]),
 ('library',['python3','Perf/applications.py',*pair,'--zjson','Vendor/zjson','--arrays','--samples','9','--cpu','13','--output',str(logs/'selected-library.json')]),
 ('scene-repeat',['python3','Perf/scene-benchmark.py',*pair,'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','5','--cpu','13','--output',str(logs/'selected-scene-repeat.json')]),
 ('customer-repeat',['python3','Perf/customer-benchmark.py',*pair,'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13','--output',str(logs/'selected-customer-repeat.json')])]
(logs/'final-timing-commands.json').write_text(json.dumps(commands,indent=2)+'\n')
for name,cmd in commands:
 print('MEASURE',name,flush=True)
 with (logs/('selected-'+name+'-timing.log')).open('wb') as out:subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,check=True)
print('All final timing groups passed with identical outputs',flush=True)
