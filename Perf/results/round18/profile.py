from pathlib import Path
import hashlib,importlib.util,json,subprocess
root=Path.cwd();logs=root/'.work/logs/round18';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('customer',root/'Perf/customer-benchmark.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
rows=[]
for name,operation,project in [('coder','coder-paste','zcoder.zsh'),('chat','chat-paste','zchat.zsh')]:
 states=[]
 for which,shell in [('previous',root/'.work/round17/psh'),('filter-hoist',root/'.work/round18-filter-hoist/psh'),('wrapper',root/'.work/round18-wrapper/psh')]:
  folder=Path('/home/stig/dev/ai/zaguan/labs')/project;worker=root/'Perf/customer-workload.zsh'
  sources=m.source_hashes(folder);binary=sha(shell);worker_sha=sha(worker)
  profile=logs/('accepted-'+name+'-'+which+'.callgrind');log=logs/('accepted-'+name+'-'+which+'-instructions.log')
  cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(profile),'--log-file='+str(log),str(shell),'-df',str(worker),operation,str(folder),'1']
  env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','LANG':'C.UTF-8'}
  r=subprocess.run(cmd,env=env,capture_output=True,timeout=600)
  assert r.returncode==0 and not r.stderr,(cmd,r.returncode,r.stderr)
  assert binary==sha(shell) and worker_sha==sha(worker) and sources==m.source_hashes(folder)
  state=hashlib.sha256(r.stdout.split(b'\n',1)[1]).hexdigest();states.append(state)
  total=int(next(l.split(':')[1] for l in profile.read_text().splitlines() if l.startswith('summary:')))
  with profile.with_suffix('.flat.txt').open('wb') as out:
   subprocess.run(['callgrind_annotate','--auto=no','--inclusive=no','--threshold=100',str(profile)],stdout=out,check=True)
  rows.append({'name':name,'which':which,'command':cmd,'environment':env,'binary_sha256':binary,'worker_sha256':worker_sha,'project_source_sha256':sources,'instructions':total,'state_sha256':state,'status':r.returncode})
  print(name,which,total,flush=True)
 assert len(set(states))==1
(logs/'accepted-profile-commands.json').write_text(json.dumps(rows,indent=2)+'\n')
