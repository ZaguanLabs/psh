from pathlib import Path
import hashlib,json,subprocess
root=Path.cwd();l=root/'.work/logs/round32';b=json.loads((root/'.work/package/latest.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();hosts=[('active',Path(b['prefix'])/'bin/psh',Path(b['core']),Path(b['core'])),('pristine',root/'.work/baseline/Src/zsh',root/'.work/baseline',root/'.work/pristine')];rows=[]
for name,shell,headers,source in hosts:
 folder=l/('observer-'+name);folder.mkdir();module=folder/'psh_scope_observer.so';cmd=['cc','-O2','-g','-shared','-fPIC','-DMODULE','-DHAVE_CONFIG_H','-I'+str(headers/'Src'),'-I'+str(source/'Src'),str(root/'Perf/scope-observer-module.c'),'-o',str(module)]
 subprocess.run(cmd,check=True);tests=[]
 for mode in ['loop','empty','local1','local8','emulate','nested']:
  for occupancy in ['dense','sparse']:
   command=[str(shell),'-df',str(root/'Perf/scope-workload.zsh'),'32','20',mode,occupancy,str(folder)]
   result=subprocess.run(command,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,check=True);assert not result.stderr;elapsed,before,after=result.stdout.splitlines();state=json.loads(before);assert before==after and state['count']==state['visible'] and state['level']==0 and state['local']==0;tests.append(dict(mode=mode,occupancy=occupancy,table=state))
 command=['valgrind','--error-exitcode=97','--leak-check=no','--log-file='+str(l/(name+'-observer.memcheck.log')),str(shell),'-dfc','module_path=("$1"); zmodload psh_scope_observer || exit 1; psh-scope-observe; zmodload -u psh_scope_observer || exit 2','observer',str(folder)]
 result=subprocess.run(command,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,check=True);assert not result.stderr;assert 'ERROR SUMMARY: 0 errors' in (l/(name+'-observer.memcheck.log')).read_text()
 rows.append(dict(host=name,shell=str(shell),shell_sha256=sha(shell),module=str(module),module_sha256=sha(module),compile_command=cmd,smoke=tests,memcheck_command=command,memcheck_passed=True));print(name,'12 smoke modes and Memcheck/load/unload passed.',flush=True)
for script in ['Perf/scope-workload.zsh','Perf/scope-customer-workload.zsh']:subprocess.run([str(hosts[0][1]),'-n',script],check=True)
(l/'preparation.json').write_text(json.dumps(dict(passed=True,source_sha256=sha(root/'Perf/scope-observer-module.c'),runs=rows),indent=2)+'\n')
