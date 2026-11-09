from pathlib import Path
import ast,gzip,hashlib,json,re,shutil,subprocess,sys,tempfile
root=Path.cwd();logs=root/'.work/logs/round29';out=root/'Perf/results/round29';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
parent=json.loads((logs/'parent.json').read_text())['commit'];tracked=['Src/hashtable.c','COMPATIBILITY.md'];new=['Perf/hash-module.c','Perf/check-hash-module.py','Perf/hash-benchmark.py'];files=tracked+new
patch=root/'Perf/0029-grouped-string-hashing.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 r=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert r.returncode==1;data+=r.stdout
patch.write_bytes(('Round twenty-nine: group unsigned string-hash arithmetic\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True);assert all((t/n).read_bytes()==(root/n).read_bytes() for n in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text());assert all(sha(root/'.work/pristine'/n)==h for n,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text());assert all(sha(root/n)==h for n,h in b['core_source_sha256'].items());assert b['settings']['profile']=='release' and not b['settings']['debug_assertions']
def function(s,name):
 m=re.search(r'\n'+re.escape(name)+r'\([^;]*?\)\n\{',s);assert m,name;start=m.start()+1;end=s.index('\n}',m.end())+2;return s[start:end]
old=subprocess.check_output(['git','show',parent+':Src/hashtable.c']).decode();cur=(root/'Src/hashtable.c').read_text();up=(root/'.work/pristine/Src/hashtable.c').read_text()
assert cur.replace(function(cur,'hasher'),function(old,'hasher'))==old
assert function(old,'hasher')==function(up,'hasher')
assert function((root/'Perf/hash-module.c').read_text(),'reference_hasher')==function(up,'hasher').replace('hasher(','reference_hasher(',1)
for n in ['Src/zsh.h','Src/ztype.h','Src/signals.h','Src/params.c']:assert (root/n).read_bytes()==subprocess.check_output(['git','show',parent+':'+n])
for n in ['hashtable.pro','hashtable.epro']:assert (root/'.work/round29/previous/Src'/n).read_bytes()==(root/'.work/round29/candidate/Src'/n).read_bytes()
for n in new:
 if n.endswith('.py'):ast.parse((root/n).read_text())
assert '#define DEBUG 1' in (root/'.work/candidate/config.h').read_text().splitlines()
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),only_hasher_changed=True,oracle_matches_pristine=True,scanner_and_array_implementation_unchanged=True,public_headers_and_declarations_unchanged=True,development_DEBUG=True,development_sha256=sha(root/'psh'),incremental_patch_replayed=True,fixtures={n:sha(root/n) for n in files}))
if '--source-only' in sys.argv:print('Source, original oracle and patch checks passed.');sys.exit(0)
h=json.loads((logs/'hardware.json').read_text());assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(logs/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
out.mkdir(exist_ok=True);allowed={'.json','.py','.log','.txt','.asm','.patch','.c','.gdb','.zsh'}
for p in logs.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 dest=out/p.relative_to(logs)
 if p.suffix in allowed:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for n in ['validation.json','terminal-profile.json','installed-core-harness.json','ohmyzsh.json']:shutil.copy2(w/n,out/n if n!='validation.json' else out/'package-validation.json')
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['hashtable_sha256']=sha(root/'Src/hashtable.c');pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
