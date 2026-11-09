from pathlib import Path
import concurrent.futures,hashlib,importlib.util,json,subprocess
root=Path.cwd();l=root/'.work/logs/round32';parent=json.loads((l/'parent.json').read_text());shell=parent['shell'];module=l/'observer-active';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();spec=importlib.util.spec_from_file_location('customer',root/'Perf/customer-benchmark.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
cases=[(name+'-'+str(padding),name,padding) for name in ['coder-paste','chat-paste'] for padding in [0,512]]
cases += [('empty-'+str(padding),'empty',padding) for padding in [0,4096]]
def run(row):
 name,mode,padding=row;source=None
 if mode=='empty':args=[str(root/'Perf/scope-workload.zsh'),str(padding),'200','empty','dense',str(module)];sources={}
 else:
  source=Path('/home/stig/dev/ai/zaguan/labs')/('zcoder.zsh' if mode=='coder-paste' else 'zchat.zsh');sources=m.source_hashes(source);args=[str(root/'Perf/scope-customer-workload.zsh'),str(padding),str(module),str(root/'Perf/customer-workload.zsh'),mode,str(source),'1']
 profile=l/(name+'.callgrind');cmd=['valgrind','--tool=callgrind','--callgrind-out-file='+str(profile),'--log-file='+str(l/(name+'-callgrind.log')),shell,'-df',*args];result=subprocess.run(cmd,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8','LANG':'C.UTF-8'},capture_output=True,timeout=900);assert result.returncode==0 and not result.stderr,(name,result.returncode,result.stderr)
 if source:assert sources==m.source_hashes(source)
 for suffix,options in [('flat',['--inclusive=no']),('callers',['--inclusive=yes','--tree=caller'])]:
  with (l/(name+'-'+suffix+'.txt')).open('wb') as output:subprocess.run(['callgrind_annotate','--auto=no','--threshold=100',*options,str(profile)],stdout=output,check=True)
 (l/(name+'-output.log')).write_bytes(result.stdout);total=int(next(x.split(':')[1] for x in profile.read_text().splitlines() if x.startswith('summary:')))
 if source:
  data,counts=result.stdout.split(b'\n__psh_scope_table__\n');state=data.split(b'\n',1)[1];table=json.loads(counts)
 else:
  _,counts,_=result.stdout.splitlines();state=counts;table=json.loads(counts)
 print(name,total,flush=True);return dict(name=name,command=cmd,shell_sha256=sha(shell),source_sha256=sources,worker_sha256={p:sha(p) for p in args if Path(p).is_file()},instructions=total,table=table,output_state_sha256=hashlib.sha256(state).hexdigest(),status=0)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:rows=list(pool.map(run,cases))
for mode in ['coder-paste','chat-paste']:
 a,b=[r for r in rows if r['name'].startswith(mode)];assert a['source_sha256']==b['source_sha256'] and a['output_state_sha256']==b['output_state_sha256']
(l/'profiles.json').write_text(json.dumps(rows,indent=2)+'\n')
