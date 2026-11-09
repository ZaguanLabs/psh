from pathlib import Path
import hashlib,json,subprocess,sys
root=Path.cwd();l=root/'.work/logs/round29';b=json.loads((root/'.work/package/latest.json').read_text());old=json.loads((l/'previous-release.json').read_text())['prefix']
for name,cmd in [('release-identity',['python3','Packaging/check-release.py','--build','.work/package/latest.json','--reference',old+'/bin/psh']),('installed-hash',['python3','Perf/check-hash-module.py',old+'/bin/psh',b['prefix']+'/bin/psh','--headers-build',b['core'],'--headers-source',b['core'],'--memcheck','--locale','C.UTF-8'])]:
 cmd+=['--output',str(l/(name+'.json'))]
 with (l/(name+'.log')).open('wb') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
 print(name,'passed',flush=True)
sys.path.insert(0,str(root/'Packaging'));from elf import dynamic_exports
hosts=[Path(old)/'bin/psh',Path(b['prefix'])/'bin/psh'];assert dynamic_exports(hosts[0])==dynamic_exports(hosts[1])
d=dict(passed=True,dynamic_exports_unchanged=len(dynamic_exports(hosts[0])),binary_sha256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in hosts},bytes={str(p):p.stat().st_size for p in hosts});(l/'identity.json').write_text(json.dumps(d,indent=2)+'\n');print('Export names/types unchanged')
