from pathlib import Path
import json,subprocess
r=Path.cwd();l=r/'.work/logs/round35';b=json.loads((r/'.work/package/latest.json').read_text());w=Path(b['work'])
for n in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:
 d=json.loads((w/('test-'+n+'.json')).read_text());assert d['passed'] and all(x['status']==0 for x in d['runs'])
rows=[]
for name,cmd in [('stage-modules',['python3','Packaging/verify.py','stage-modules']),('refresh-modules',['sudo','-n','python3','Packaging/install.py','refresh-modules']),('package-verification',['python3','Packaging/verify.py','verify'])]:
 with (l/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 rows.append(dict(name=name,command=cmd,status=p.returncode));print(name,p.returncode,flush=True);assert p.returncode==0
(l/'package-finalization.json').write_text(json.dumps(rows,indent=2)+'\n')
