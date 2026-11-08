from pathlib import Path
import json,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round22/final';build=json.loads((root/'.work/package/latest.json').read_text());work=Path(build['work'])
required=[work/('test-'+name+'.json') for name in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']]+[logs/(name+'.json') for name in ['validation','upstream','gcc-cache','clang-cache','deep-profiles','installed-cache','release-identity','signal-boundary','installed-signal-boundary']]
print('Waiting for completed final tests and profiles',flush=True)
while not all(p.exists() for p in required):time.sleep(2)
for p in required:
 data=json.loads(p.read_text())
 if isinstance(data,dict):assert data.get('passed',True),(str(p),data)
 else:assert all(row['status']==0 for row in data),str(p)
rows=[]
def run(name,cmd):
 started=time.monotonic()
 with (logs/(name+'.log')).open('wb') as out:r=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT)
 rows.append(dict(name=name,command=cmd,status=r.returncode,seconds=time.monotonic()-started));print(name,r.returncode,flush=True)
 (logs/'final-commands.json').write_text(json.dumps(rows,indent=2)+'\n')
 if r.returncode:raise RuntimeError(name)
run('stage-modules',['python3','Packaging/verify.py','stage-modules'])
run('refresh-modules',['sudo','-n','python3','Packaging/install.py','refresh-modules'])
run('package-verification',['python3','Packaging/verify.py','verify'])
before='.work/round22/previous/Src/zsh';after='.work/round22/candidate/Src/zsh';labs='/home/stig/dev/ai/zaguan/labs';challenge='/home/stig/dev/challenge'
tasks=[('bound-controls','array-bound-benchmark.py',[before,after]),('customer-benchmarks','customer-benchmark.py',[before,after,'--labs',labs,'--challenge',challenge]),('library-benchmarks','applications.py',[before,after,'--arrays','--zjson',labs+'/zjson','--z3dfx',challenge+'/z3dfx']),('parser-benchmarks','parser-benchmark.py',[before,after,'--zhtml2md',labs+'/zhtml2md','--zjson',labs+'/zjson','--zoup',labs+'/zoup']),('array-length-benchmarks','array-length-benchmark.py',[before,after]),('customer-repeat','customer-benchmark.py',[before,after,'--labs',labs,'--challenge',challenge]),('hardware','hardware-benchmark.py',[before,after,'--labs',labs,'--challenge',challenge,'--case','zcoder.zsh/coder-wide-layout','--case','zchat.zsh/chat-wide-layout','--case','z3dfx.drawing/drawing-binning','--case','endgame/endgame-world'])]
for name,script,args in tasks:run(name,['python3','Perf/'+script,*args,'--cpu','2','--output',str(logs/(name+'.json'))])
