from pathlib import Path
import ast,gzip,hashlib,json,shutil,subprocess,sys,tempfile
r=Path.cwd();l=r/'.work/logs/round34';out=r/'Perf/results/round34';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');parent=read(l/'parent.json')['commit']
tracked=['Src/hashtable.c','Src/params.c'];new=['Perf/scope-cleanup-module.c','Perf/check-scope-cleanup-module.py','Perf/scope-pair-benchmark.py'];files=tracked+new
patch=r/'Perf/0034-live-level-scope-scan.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 result=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert result.returncode==1;data+=result.stdout
patch.write_bytes(('Round 34: live-level parameter-scope scan\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as td:
 t=Path(td)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 result=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True);assert all((t/n).read_bytes()==(r/n).read_bytes() for n in files)
 write(l/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=result.stdout.decode()))
old=subprocess.check_output(['git','show',parent+':Src/hashtable.c']).decode();cur=(r/'Src/hashtable.c').read_text();start=cur.index('/* Scope cleanup needs only parameters');end=cur.index('/* Expand hash tables',start);assert cur[:start]+cur[end:]==old
old=subprocess.check_output(['git','show',parent+':Src/params.c']).decode();cur=(r/'Src/params.c').read_text();assert cur.replace('scanlocalparams(paramtab, scanendscope);','scanhashtable(paramtab, 0, 0, 0, scanendscope, 0);')==old
assert set(subprocess.check_output(['git','diff','--name-only',parent,'--','Src'],text=True).splitlines())==set(tracked)
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h']:assert (r/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
before=r/'.work/round34/previous/Src';after=r/'.work/round34/candidate/Src';assert (before/'params.epro').read_bytes()==(after/'params.epro').read_bytes()
prototype='extern void scanlocalparams(HashTable ht,ScanFunc scanfunc);\n';assert (after/'hashtable.epro').read_text().replace(prototype,'')==(before/'hashtable.epro').read_text()
manifest=read(r/'Perf/upstream-sha256.json');assert all(sha(r/'.work/pristine'/n)==h for n,h in manifest.items())
b=read(r/'.work/package/latest.json');assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert b['settings']['profile']=='release' and not b['settings']['debug_assertions'];assert '#define DEBUG 1' in (r/'.work/candidate/config.h').read_text().splitlines()
for name in new:
 if name.endswith('.py'):ast.parse((r/name).read_text())
sys.path.insert(0,str(r/'Packaging'));from elf import dynamic_exports
old=set(dynamic_exports(before/'zsh'));cur=set(dynamic_exports(after/'zsh'));assert old<=cur and cur-old=={'T scanlocalparams'}
write(l/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),canonical_package_inputs_match=len(b['core_source_sha256']),only_scope_call_and_new_scanner_changed=True,generic_scanners_unchanged=True,restoration_body_history_locale_and_signal_boundaries_unchanged=True,public_structures_unchanged=True,existing_export_names_and_types_preserved=len(old),additional_internal_elf_symbol='T scanlocalparams',new_core_prototype_only=prototype.strip(),incremental_patch_replayed=True,development_DEBUG=True,development_sha256=sha(r/'psh'),fixtures={n:sha(r/n) for n in files}))
if '--source-only' in sys.argv:print('Source and five-file patch checks passed.');sys.exit(0)
assert read(l/'activation.json')['passed'];h=read(l/'hardware.json');assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(l/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
out.mkdir(exist_ok=True)
for p in l.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 dest=out/p.relative_to(l)
 if p.suffix in {'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for name in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/name,out/('package-validation.json' if name=='validation.json' else name))
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['scope_source_sha256']={n:sha(r/n) for n in tracked};pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
