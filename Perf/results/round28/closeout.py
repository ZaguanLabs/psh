from pathlib import Path
import ast,gzip,hashlib,json,re,shutil,subprocess,sys,tempfile
root=Path.cwd();logs=root/'.work/logs/round28';out=root/'Perf/results/round28';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
parent=json.loads((logs/'parent.json').read_text())['commit'];tracked=['Src/params.c','COMPATIBILITY.md','Perf/array-cache-module.c'];new=['Perf/append-prefix.zsh','Perf/check-append-prefix.py'];files=tracked+new
patch=root/'Perf/0028-append-confirmed-prefix.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 r=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert r.returncode==1;data+=r.stdout
patch.write_bytes(('Round twenty-eight: reuse confirmed array prefixes before append\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True);assert all((t/n).read_bytes()==(root/n).read_bytes() for n in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text());assert all(sha(root/'.work/pristine'/n)==h for n,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text());assert all(sha(root/n)==h for n,h in b['core_source_sha256'].items())
def function(s,name):
 m=re.search(r'\n'+re.escape(name)+r'\([^;]*?\)\n\{',s);assert m,name;start=m.start()+1;end=s.index('\n}',m.end())+2;return s[start:end]
old=subprocess.check_output(['git','show',parent+':Src/params.c']).decode();cur=(root/'Src/params.c').read_text();copy=cur
helper=function(cur,'array_length_full');comment=cur.index('/* Complete a length walk from an already confirmed prefix.');end=cur.index(helper)+len(helper)+2;copy=copy[:comment]+copy[end:]
for n in ['setarrvalue_len','assignaparam']:copy=copy.replace(function(copy,n),function(old,n))
assert copy==old
for n in ['array_length_owned','invalidate_array_length','arrsetfn','freeparamnode','arrgetfn','getarrayreadonly']:assert function(old,n)==function(cur,n),n
for n in ['Src/zsh.h','Src/ztype.h','Src/signals.h','Src/hashtable.c']:assert (root/n).read_bytes()==subprocess.check_output(['git','show',parent+':'+n])
assert (root/'.work/round28/previous/Src/params.epro').read_bytes()==(root/'.work/round28/candidate/Src/params.epro').read_bytes()
for n in new:
 if n.endswith('.py'):ast.parse((root/n).read_text())
subprocess.run(['/usr/bin/zsh','-n','Perf/append-prefix.zsh'],check=True);assert '#define DEBUG 1' in (root/'.work/candidate/config.h').read_text().splitlines()
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),only_append_helpers_changed=True,ownership_setter_invalidation_and_getters_unchanged=True,public_headers_and_exported_declarations_unchanged=True,generic_scanner_restored=True,development_DEBUG=True,development_sha256=sha(root/'psh'),incremental_patch_replayed=True,fixtures={n:sha(root/n) for n in files}))
h=json.loads((logs/'hardware.json').read_text());assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(logs/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
if '--source-only' in sys.argv:print('Source and patch checks passed.');sys.exit(0)
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
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['params_sha256']=sha(root/'Src/params.c');pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
