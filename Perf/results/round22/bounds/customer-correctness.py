from pathlib import Path
import hashlib,importlib.util,json,subprocess,tempfile
root=Path.cwd();logs=root/'.work/logs/round22/bounds';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('customer',root/'Perf/customer-benchmark.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
rows=[]
for locale in ['C','C.UTF-8']:
 for op,group,project,n in m.CASES:
  if op.endswith('-wide-layout') and locale != 'C.UTF-8':continue
  folder=Path('/home/stig/dev/ai/zaguan/labs' if group=='labs' else '/home/stig/dev/challenge')/project
  states=[]
  for shell in ['.work/round22/previous/Src/zsh','.work/round22/candidate/Src/zsh']:
   cmd=[str(root/shell),'-df','Perf/customer-workload.zsh',op,str(folder),str(n)]
   r=subprocess.run(cmd,capture_output=True,env={'PATH':'/usr/bin:/bin','LC_ALL':locale},timeout=120)
   assert r.returncode==0 and not r.stderr,(project,op,locale,r.returncode,r.stdout[-200:],r.stderr)
   states.append(hashlib.sha256(r.stdout.split(b'\n',1)[1]).hexdigest())
  assert len(set(states))==1,(project,op,locale)
  rows.append({'project':project,'operation':op,'locale':locale,'status':0,'state_sha256':states[0],'source_sha256':m.source_hashes(folder)})
  print(project,op,locale,'matched preceding psh',flush=True)
(logs/'customer-correctness.json').write_text(json.dumps({'worker_sha256':sha(root/'Perf/customer-workload.zsh'),'shells':[str(root/'.work/round22/previous/Src/zsh'),str(root/'.work/round22/candidate/Src/zsh')],'binary_sha256':[sha(root/'.work/round22/previous/Src/zsh'),sha(root/'.work/round22/candidate/Src/zsh')],'cases':rows},indent=2)+'\n')
import sys
if '--kernels-only' in sys.argv:
 raise SystemExit(0)
rows=[]
for project,name in [('endgame','engine'),('endgame','adventure'),('endgame','horizon'),('z3dfx.agy','engine'),('z3dfx.grok','engine')]:
 file=Path('/home/stig/dev/challenge')/project/'tests'/(name+'.zsh');data=[]
 with tempfile.TemporaryDirectory(prefix='customer-tests-',dir=root/'.work') as scratch:
  for shell in ['.work/round22/previous/Src/zsh','.work/round22/candidate/Src/zsh']:
   r=subprocess.run([str(root/shell),'-df',str(file)],cwd=scratch,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','TMPDIR':scratch},capture_output=True,timeout=300)
   data.append((r.returncode,r.stdout,r.stderr))
 assert data[0]==data[1] and data[0][0]==0,(str(file),data)
 rows.append({'test':str(file),'source_sha256':sha(file),'status':0,'stdout':data[0][1].decode()})
 print(project,name,'original suite matched',flush=True)
(logs/'additional-project-tests.json').write_text(json.dumps(rows,indent=2)+'\n')
