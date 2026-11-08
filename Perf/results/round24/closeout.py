from pathlib import Path
import ast, gzip, hashlib, importlib.util, json, shutil, subprocess, tempfile
root=Path.cwd(); logs=root/'.work/logs/round24'; out=root/'Perf/results/round24'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
parent=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
assert parent=='9d710a9d617d4458afd166577fe40d98b11140d7'
files=['Src/params.c','Perf/search-compare.py','Perf/array-cache-lifetimes.zsh','Perf/array-cache-mutations.zsh','Perf/check-array-cache-signals.py','Perf/check-array-search.py','COMPATIBILITY.md']
patch=root/'Perf/0024-forward-search-prefix-reuse.patch'
tracked=[p for p in files if p!='Perf/check-array-search.py']
data=subprocess.check_output(['git','diff','--binary','HEAD','--',*tracked])
new=root/'Perf/check-array-search.py'
r=subprocess.run(['git','diff','--no-index','--','/dev/null',str(new.relative_to(root))],capture_output=True)
assert r.returncode==1
patch.write_bytes(('Round twenty-four: reuse confirmed array prefixes for forward search starts\nParent: '+parent+'\n\n').encode()+data+r.stdout)
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True)
 assert all((t/name).read_bytes()==(root/name).read_bytes() for name in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text())
assert all(sha(root/'.work/pristine'/name)==h for name,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text())
assert all(sha(root/name)==h for name,h in b['core_source_sha256'].items())
for name in ['Perf/search-compare.py','Perf/check-array-cache-signals.py','Perf/check-array-search.py']:
 ast.parse((root/name).read_text())
for name in ['Perf/array-cache-lifetimes.zsh','Perf/array-cache-mutations.zsh']:
 subprocess.run([str(root/'psh'),'-dfn',str(root/name)],check=True)
def load(path,label):
 spec=importlib.util.spec_from_file_location(label,path); mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
with tempfile.TemporaryDirectory() as tmp:
 p=Path(tmp)/'previous-search.py';p.write_bytes(subprocess.check_output(['git','show',parent+':Perf/search-compare.py']))
 prev=load(p,'old_search');cur=load(root/'Perf/search-compare.py','new_search')
 assert list(prev.cases())==list(cur.cases())
 assert list(prev.scalar_cases())==list(cur.scalar_cases())
assert '#define DEBUG' in (root/'.work/candidate/config.h').read_text()
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),development_DEBUG=True,development_sha256=sha(root/'psh'),default_search_corpus_unchanged=True,scalar_search_corpus_unchanged=True,incremental_patch_replayed=True,fixtures={name:sha(root/name) for name in files}))
for p in logs.iterdir():
 if not p.is_file() or p.name=='previous-release.json':continue
 if p.name=='cache-fixture-flag-setup.log':
  (out/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
 elif p.suffix in ('.json','.py','.log','.txt','.asm'):shutil.copy2(p,out/p.name)
 elif p.suffix=='.callgrind':(out/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
for d in logs.glob('*-native'):
 for p in d.glob('*.memcheck.log'):
  dest=out/d.name/p.name;dest.parent.mkdir(exist_ok=True);shutil.copy2(p,dest)
w=Path(b['work'])
for name in ['validation.json','terminal-profile.json','installed-core-harness.json','ohmyzsh.json']:
 shutil.copy2(w/name,out/name if name!='validation.json' else out/'package-validation.json')
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
package={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']}
package['params_sha256']=sha(root/'Src/params.c')
package['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')}
write(out/'installed-package.json',package)
print(json.dumps(dict(source_checks='passed',patch_files=len(files),evidence_files=sum(p.is_file() for p in out.rglob('*')),evidence_bytes=sum(p.stat().st_size for p in out.rglob('*') if p.is_file())),indent=2))
