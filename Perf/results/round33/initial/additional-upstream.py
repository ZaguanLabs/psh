from pathlib import Path
import concurrent.futures,json,subprocess
logs=Path('.work/logs/round33')
def run(host):
 folder='.work/round33/'+host if host.startswith('clang-') else '.work/candidate'
 cmd=['make','-C',folder,'check']
 with (logs/(host+'-upstream.log')).open('wb') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
 print(host,r.returncode,flush=True);assert r.returncode==0
 return dict(host=host,command=cmd,status=r.returncode)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as p:rows=list(p.map(run,['clang-previous','clang-candidate','development']))
(logs/'additional-upstream.json').write_text(json.dumps(rows,indent=2)+'\n')
