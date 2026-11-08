from pathlib import Path
import ast,gzip,hashlib,json,shutil,subprocess,sys,tempfile
root=Path.cwd();logs=root/'.work/logs/round25';out=root/'Perf/results/round25'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
files=['Src/utils.c','Perf/itype-module.c','Perf/check-itype-module.py','COMPATIBILITY.md']
parent='5cdb994b00ed4c49bc57a115ca29b71d1193fb2d'
patch=root/'Perf/0025-classification-branch-merge.patch'
patch.write_bytes(('Round twenty-five: merge identical ASCII and token classification branches\nParent: '+parent+'\n\n').encode()+subprocess.check_output(['git','diff','--binary',parent,'--',*files]))
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in files:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True)
 assert all((t/name).read_bytes()==(root/name).read_bytes() for name in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text())
assert all(sha(root/'.work/pristine'/name)==h for name,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text())
assert all(sha(root/name)==h for name,h in b['core_source_sha256'].items())
ast.parse((root/'Perf/check-itype-module.py').read_text())
assert '#define DEBUG' in (root/'.work/candidate/config.h').read_text()
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h']:
 assert (root/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),public_headers_unchanged=True,development_DEBUG=True,development_sha256=sha(root/'psh'),incremental_patch_replayed=True,fixtures={name:sha(root/name) for name in files}))
hardware=json.loads((logs/'hardware.json').read_text())
assert all(e['running_ns']==e['enabled_ns'] for c in hardware['cases'] for host in c['measurements'] for sample in host for e in sample['events'])
write(logs/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
if '--source-only' in sys.argv:
 print('Source inputs, public headers, patch reconstruction and counter scheduling verified.');sys.exit(0)
out.mkdir(exist_ok=True)
for p in logs.iterdir():
 if not p.is_file() or p.name=='previous-release.json':continue
 if p.suffix in ('.json','.py','.log','.txt','.asm'):shutil.copy2(p,out/p.name)
 elif p.suffix=='.callgrind':(out/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for name in ['validation.json','terminal-profile.json','installed-core-harness.json','ohmyzsh.json']:
 shutil.copy2(w/name,out/name if name!='validation.json' else out/'package-validation.json')
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
package={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']}
package['utils_sha256']=sha(root/'Src/utils.c')
package['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')}
write(out/'installed-package.json',package)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
