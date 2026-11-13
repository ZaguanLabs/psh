from pathlib import Path
import runpy,tempfile,subprocess,json,hashlib
r=Path.cwd();out=r/'.work/round46';helpers=runpy.run_path(str(r/'Perf/customer-process-benchmark.py'));cases=runpy.run_path(str(r/'Perf/customer-benchmark.py'))['CASES']
hosts=['/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh','/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh'];worker=r/'Perf/customer-workload.zsh';rows=[]
with tempfile.TemporaryDirectory(prefix='psh-customer-state-') as tmp:
 for op,group,project,iterations in cases:
  root=Path('/home/stig/dev/ai/zaguan/labs' if group=='labs' else '/home/stig/dev/challenge')/project
  inputs=helpers['input_metadata'](root);copy=Path(tmp)/group/project;helpers['copy_text'](root,copy)
  observations=[];expected=None
  for mode,source in [('current',root),('text',copy)]:
   for shell in hosts:
    p=subprocess.run([shell,'-df',str(worker),op,str(source),str(iterations)],env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=120)
    assert p.returncode==0 and not p.stderr,(project,op,mode,p.stderr)
    state=p.stdout.split(b'\n',1)[1]
    if expected is None:expected=state
    assert state==expected,(project,op,mode)
    observations.append(dict(mode=mode,shell=shell,state_sha256=hashlib.sha256(state).hexdigest()))
  assert inputs==helpers['input_metadata'](root)
  rows.append(dict(case=project+'/'+op,passed=True,input_metadata=inputs,observations=observations))
(out/'customer-state-check.json').write_text(json.dumps(dict(passed=True,worker_sha256=helpers['sha'](worker),helper_sha256=helpers['sha'](r/'Perf/customer-process-benchmark.py'),binary_sha256=[helpers['sha'](Path(x)) for x in hosts],cases=rows),indent=2)+'\n')
print('All',len(rows),'customer cases match across both shells and loading modes')
