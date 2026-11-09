from pathlib import Path
import hashlib,json,os,statistics,subprocess
root=Path.cwd();l=root/'.work/logs/round32';shell=root/'.work/baseline/Src/zsh';module=l/'observer-pristine';worker=root/'Perf/scope-workload.zsh';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();inputs=[shell,module/'psh_scope_observer.so',worker];fingerprints={str(p):sha(p) for p in inputs};os.sched_setaffinity(0,{13});samples={size:[] for size in [0,4096]};states={size:set() for size in samples}
for sample in range(9):
 for size in ([0,4096] if sample%2==0 else [4096,0]):
  result=subprocess.run([str(shell),'-df',str(worker),str(size),'4000','empty','dense',str(module)],env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,check=True);assert not result.stderr;elapsed,before,after=result.stdout.splitlines();assert before==after;samples[size].append(float(elapsed)*1000);states[size].add(before)
assert fingerprints=={str(p):sha(p) for p in inputs};rows=[]
for size in samples:
 assert len(states[size])==1;rows.append(dict(padding=size,samples_ms=samples[size],median_ms=statistics.median(samples[size]),median_us_per_call=statistics.median(samples[size])*1000/4000,table=json.loads(states[size].pop())))
(l/'pristine-scaling.json').write_text(json.dumps(dict(samples=9,cpu_affinity=[13],DEBUG=True,environment={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},fingerprints=fingerprints,cases=rows,scope='baseline-only inherited scaling; absolute times are not an active/pristine speed comparison'),indent=2)+'\n');print(rows)
