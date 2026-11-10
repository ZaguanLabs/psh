from pathlib import Path
import concurrent.futures,hashlib,importlib.util,json,subprocess
root=Path.cwd();logs=root/'.work/logs/round37';shell=None
hosts={'previous': '/usr/local/psh/releases/1.0.0-rc0-bde30291d0ec/bin/psh', 'candidate': '/usr/local/psh/releases/1.0.0-rc0-7e8f4c48abf5/bin/psh'}
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('customer',root/'Perf/customer-benchmark.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
cases=[('coder','customer','coder-paste','/home/stig/dev/ai/zaguan/labs/zcoder.zsh',1),('chat','customer','chat-paste','/home/stig/dev/ai/zaguan/labs/zchat.zsh',1),('endgame','customer','endgame-world','/home/stig/dev/challenge/endgame',2),('json-encode','application','zjson-encode-array','/home/stig/dev/ai/zaguan/labs/zjson',1)]
cases=[(label,host,*case[1:]) for host in ['previous','candidate'] for case in cases for label in [host+'-'+case[0]]]

def run(case):
 name,host,kind,operation,project,n=case;shell=Path(hosts[host]).resolve();worker=root/'Perf'/(kind+'-workload.zsh');folder=Path(project);sources=m.source_hashes(folder)
 if kind=='application':sources['zjson.zsh']=sha(folder/'zjson.zsh')
 profile=logs/('installed-'+name+'.callgrind');cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(profile),'--log-file='+str(logs/('installed-'+name+'-callgrind.log')),str(shell),'-df',str(worker),operation,project,str(n)]
 env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','LANG':'C.UTF-8'}
 r=subprocess.run(cmd,env=env,capture_output=True,timeout=900);assert r.returncode==0 and not r.stderr,(name,r.returncode,r.stderr)
 current=m.source_hashes(folder)
 if kind=='application':current['zjson.zsh']=sha(folder/'zjson.zsh')
 assert sources==current
 total=int(next(s.split(':')[1] for s in profile.read_text().splitlines() if s.startswith('summary:')))
 with (logs/('installed-'+name+'-flat.txt')).open('wb') as out:subprocess.run(['callgrind_annotate','--auto=no','--inclusive=no','--threshold=100',str(profile)],stdout=out,check=True)
 (logs/('installed-'+name+'-output.log')).write_bytes(r.stdout)
 print(name,total,flush=True)
 return {'name':name,'command':cmd,'environment':env,'binary_sha256':sha(shell),'worker_sha256':sha(worker),'source_sha256':sources,'instructions':total,'output_state_sha256':hashlib.sha256(r.stdout.split(b'\n',1)[1]).hexdigest(),'status':r.returncode}
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:rows=list(pool.map(run,cases))
(logs/'installed-profiles.json').write_text(json.dumps(rows,indent=2)+'\n')
