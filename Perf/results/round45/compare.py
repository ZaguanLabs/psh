from pathlib import Path
import concurrent.futures,json,subprocess
r=Path('.work/round45');candidate='/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh'
cases=[('arrays-pristine',['Perf/compare.py','.work/public-rc0/reference/Src/zsh',candidate,'--appends']),
 ('arrays-previous',['Perf/compare.py','/usr/local/psh/releases/1.0.0-rc1-fcff3fb31d43/bin/psh',candidate,'--appends']),
 ('native-array-cache',['Perf/check-array-cache.py','.work/public-rc0/reference/Src/zsh',candidate,'--headers-build','.work/public-rc0/reference','--headers-source','.work/pristine','--memcheck','--raw-contract','--locale','C','--locale','C.UTF-8'])]
def run(item):
 name,cmd=item;cmd=['python3',*cmd,'--output',str(r/(name+'.json'))]
 with (r/(name+'.log')).open('wb') as out:p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=1200)
 print(name,p.returncode,flush=True);return dict(name=name,command=cmd,status=p.returncode)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:rows=list(pool.map(run,cases))
passed=all(r['status']==0 for r in rows)
(r/'compare.json').write_text(json.dumps(dict(passed=passed,runs=rows),indent=2)+'\n')
raise SystemExit(0 if passed else 1)
