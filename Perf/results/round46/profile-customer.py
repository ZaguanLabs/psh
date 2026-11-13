from pathlib import Path
import subprocess,tempfile,hashlib,json,runpy
r=Path.cwd();out=r/'.work/round46'
helpers=runpy.run_path(str(r/'Perf/customer-process-benchmark.py'))
sha=helpers['sha'];project=Path('/home/stig/dev/ai/zaguan/labs/zcoder.zsh');worker=r/'Perf/customer-workload.zsh'
inputs=helpers['input_metadata'](project)
hosts=['/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh','/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh']
rows=[];expected=None
with tempfile.TemporaryDirectory(prefix='psh-lexer-profile-') as tmp:
    text_root=Path(tmp)/'zcoder.zsh';helpers['copy_text'](project,text_root)
    for mode,root in [('current',project),('text',text_root)]:
        for label,shell in zip(('baseline','candidate'),hosts):
            name=mode+'-'+label+'-coder';target=out/(name+'.callgrind')
            cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(target),shell,'-df',str(worker),'coder-layout',str(root),'2']
            p=subprocess.run(cmd,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=240)
            (out/(name+'.log')).write_bytes(p.stderr);(out/(name+'.out')).write_bytes(p.stdout)
            assert p.returncode==0
            state=p.stdout.split(b'\n',1)[1]
            if expected is None:expected=state
            assert state==expected
            total=int(next(line.split(':')[1] for line in target.read_text().splitlines() if line.startswith('summary:')))
            with (out/(name+'-callers.txt')).open('w') as f:subprocess.run(['callgrind_annotate','--auto=no','--inclusive=no','--tree=caller','--threshold=100',str(target)],stdout=f,check=True)
            rows.append(dict(mode=mode,shell=shell,binary_sha256=sha(Path(shell)),instructions=total,state_sha256=hashlib.sha256(state).hexdigest()))
assert inputs==helpers['input_metadata'](project)
(out/'customer-loading-profile.json').write_text(json.dumps(dict(scope='full fresh kernel including loading, setup, warmup, operation, validation and output',input_metadata=inputs,worker_sha256=sha(worker),helper_sha256=sha(r/'Perf/customer-process-benchmark.py'),runs=rows),indent=2)+'\n')
print([(x['mode'],x['instructions']) for x in rows],flush=True)
