from pathlib import Path
import hashlib,json,subprocess,sys
root=Path.cwd();l=root/'.work/logs/round35';b=json.loads((root/'.work/package/latest.json').read_text());old=json.loads((l/'previous-release.json').read_text())['prefix']
for name,cmd in [('release-identity',['python3','Packaging/check-release.py','--build','.work/package/latest.json','--reference',old+'/bin/psh']),('installed-scope',['python3','Perf/check-scope-cleanup-module.py',old+'/bin/psh',b['prefix']+'/bin/psh','--headers-build','.work/package/1.0.0-rc0-56f97a85e8cb/core','--headers-source','.work/package/1.0.0-rc0-56f97a85e8cb/core','--candidate-headers-build',b['core'],'--candidate-headers-source',b['core'],'--memcheck','--aware','--locale','C.UTF-8'])]:
 cmd+=['--output',str(l/(name+'.json'))]
 with (l/(name+'.log')).open('wb') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
 print(name,'passed',flush=True)
sys.path.insert(0,str(root/'Packaging'));from elf import dynamic_exports
hosts=[Path(old)/'bin/psh',Path(b['prefix'])/'bin/psh'];old_exports=set(dynamic_exports(hosts[0]));new_exports=set(dynamic_exports(hosts[1]));assert old_exports<=new_exports and new_exports-old_exports=={'T psh_scanparamscope','T psh_scope_tracking','T psh_scope_mark','T psh_scope_setlevel','T psh_scope_native_begin','T psh_scope_native_end','T psh_scope_module_ack'}
d=dict(passed=True,existing_dynamic_exports_preserved=len(old_exports),added_internal_dynamic_exports=sorted(new_exports-old_exports),candidate_dynamic_exports=len(new_exports),binary_sha256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in hosts},bytes={str(p):p.stat().st_size for p in hosts});(l/'identity.json').write_text(json.dumps(d,indent=2)+'\n');print('Existing export names/types preserved; scope helpers added')
