from pathlib import Path
import concurrent.futures,hashlib,importlib.util,json,subprocess
root=Path.cwd();logs=root/'.work/logs/round20'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('customer',root/'Perf/customer-benchmark.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
cases=[('mario','mario-race','/home/stig/dev/challenge/z3dfx.mario',120),('shooter','shooter-step','/home/stig/dev/challenge/z3dfx',60),('endgame','endgame-world','/home/stig/dev/challenge/endgame',2),('coder','coder-paste','/home/stig/dev/ai/zaguan/labs/zcoder.zsh',1)]
worker=root/'Perf/customer-workload.zsh'
def pair(case):
 name,operation,project,n=case;folder=Path(project);sources=m.source_hashes(folder);data=[];state=None
 for label,shell in [('previous',root/'.work/round19/psh'),('candidate',root/'.work/candidate/Src/zsh')]:
  profile=logs/('accepted-'+name+'-'+label+'.callgrind');cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(profile),'--log-file='+str(logs/('accepted-'+name+'-'+label+'-callgrind.log')),str(shell),'-df',str(worker),operation,project,str(n)]
  env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','LANG':'C.UTF-8'}
  r=subprocess.run(cmd,env=env,capture_output=True,timeout=900);assert r.returncode==0 and not r.stderr,(name,label,r.returncode,r.stderr)
  assert sources==m.source_hashes(folder)
  current=r.stdout.split(b'\n',1)[1]
  if state is not None:assert state==current
  state=current
  total=int(next(s.split(':')[1] for s in profile.read_text().splitlines() if s.startswith('summary:')))
  with (logs/('accepted-'+name+'-'+label+'.flat.txt')).open('wb') as out:subprocess.run(['callgrind_annotate','--auto=no','--inclusive=no','--threshold=100',str(profile)],stdout=out,check=True)
  (logs/('accepted-'+name+'-'+label+'-output.log')).write_bytes(r.stdout)
  data.append({'label':label,'command':cmd,'environment':env,'binary_sha256':sha(shell),'worker_sha256':sha(worker),'source_sha256':sources,'instructions':total,'state_sha256':hashlib.sha256(current).hexdigest(),'status':r.returncode})
  print(name,label,total,flush=True)
 return {'case':name,'runs':data}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:rows=list(pool.map(pair,cases))
(logs/'accepted-profile-commands.json').write_text(json.dumps(rows,indent=2)+'\n')
