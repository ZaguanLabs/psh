from pathlib import Path
import ast,gzip,hashlib,json,re,shutil,subprocess,sys,tempfile
r=Path.cwd();l=r/'.work/logs/round35';out=r/'Perf/results/round35';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');parent=read(l/'parent.json')['commit']
existing=['Perf/scope-cleanup-module.c','Perf/check-scope-cleanup-module.py','Perf/scope-observer-module.c','COMPATIBILITY.md']
tracked=subprocess.check_output(['git','diff','--name-only',parent,'--','Src','Vendor',*existing],text=True).splitlines();new=['Perf/scope-growth.zsh','Perf/scope-opaque-module.c','Perf/scope-load-signal-module.c'];files=tracked+new
patch=r/'Perf/0035-indexed-parameter-scopes.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for n in new:
 p=subprocess.run(['git','diff','--no-index','--','/dev/null',n],capture_output=True);assert p.returncode==1;data+=p.stdout
patch.write_bytes(('Round 35: indexed parameter-scope buckets\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as td:
 t=Path(td)
 for n in tracked:
  p=t/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+n]))
 p=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True);assert all((t/n).read_bytes()==(r/n).read_bytes() for n in files)
 write(l/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=p.stdout.decode()))
old=lambda n:subprocess.check_output(['git','show',parent+':'+n]).decode()
for n in [n for n in tracked if n.startswith('Src/')]:
 s=(r/n).read_text();original=old(n)
 if n=='Src/hashtable.c':
  a=s.index('/* Only the real parameter table is indexed.');b=s.index('/********************************/\n/* Generic Hash Table functions',a);s=s[:a]+s[b:]
  a=s.index('/* Walk candidate buckets in exactly');b=s.index('/* Expand hash tables',a);s=s[:a]+s[b:]
  s=re.sub(r'^    scope_(?:invalidate\(ht\)|mark_bucket\(ht, hashval\));\n','',s,flags=re.M)
 elif n=='Src/module.c':
  a=s.index('/* Awareness is private:');b=s.index('/*\n * List of linked-in modules.',a);s=s[:a]+s[b:]
  s=s.replace('    scope_module_forget(m);\n','').replace('    psh_scope_module_ack(m);\n','')
  a=s.index('/* Native constructors and setup');b=s.index('/* This ensures that the module with the name',a)
  body=s[s.index('/**/\nstatic int\nload_module_tracked_body(',a):b]
  body=body.replace('/**/\nstatic int\nload_module_tracked_body(', '/**/\nmod_export int\nload_module(').replace(', void *context)',')')
  body=re.sub(r'^    struct scope_load_frame \*frame = .*;\n','',body,flags=re.M)
  body=re.sub(r'^[ \t]*(?:frame->.*|scope_load_frame = frame;|scope_load_frame->module = m;|scope_module_pause\(\);|scope_module_forget\(m\);|scope_module_leave\([^;]*\);)\n','',body,flags=re.M)
  oa=original.index('/**/\nmod_export int\nload_module(');ob=original.index('/* This ensures that the module with the name',oa)
  assert body.strip()==original[oa:ob].strip(),'loader body or original signal boundaries differ'
  s=s[:a]+original[oa:ob]+s[b:]
 elif n=='Src/zsh.h':
  s=s.replace('/* Explicit native opt-in: notify promotions of live parameter scope levels. */\n#define PSH_SCOPE_INDEX_VERSION 1\n','')
 else:
  s=s.replace('    psh_scope_module_ack(m);\n','')
  s=re.sub(r'psh_scope_setlevel\((\w+), (locallevel(?: \+ 1)?|keeplocal)\);',r'\1->level = \2;',s)
  s=s.replace('psh_scanparamscope(paramtab, scanendscope);','scanhashtable(paramtab, 0, 0, 0, scanendscope, 0);')
 assert s==original,('unexpected source change',n)
# Preserve the imported revisions and every unpatched vendor input.
base=json.loads(old('Vendor/sources.json'));cur=read(r/'Vendor/sources.json')
for name,relative in [('zdraw','Src/Modules/zdraw.c'),('zcurl','src/zcurl.c'),('zmdown','src/zmdown.c')]:
 entry=cur[name];record=entry['psh_patches'];assert len(record)==1
 assert record[0]['upstream_sha256']==base[name]['files'][relative] and record[0]['patched_sha256']==sha(r/'Vendor'/name/relative)
 compare=json.loads(json.dumps(entry));compare.pop('psh_patches');compare['files'][relative]=base[name]['files'][relative];assert compare==base[name]
 n='Vendor/'+name+'/'+relative;s=(r/n).read_text();original=old(n)
 if name!='zmdown':assert s.replace('#ifdef PSH_SCOPE_INDEX_VERSION\n    psh_scope_module_ack(m);\n#endif\n','')==original
 else:
  a=s.index('setup_(UNUSED(Module m))');b=s.index('\n}',a)+2;oa=original.index('setup_(UNUSED(Module m))');ob=original.index('}',oa)+1
  assert s[:a]+original[oa:ob]+s[b:]==original
for name,entry in cur.items():
 for n,h in entry['files'].items():assert sha(r/'Vendor'/name/n)==h
manifest=read(r/'Perf/upstream-sha256.json');assert all(sha(r/'.work/pristine'/n)==h for n,h in manifest.items())
b=read(r/'.work/package/latest.json');assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert all(sha(r/n)==h for n,h in read(l/'frozen-inputs.json').items());assert b['settings']['profile']=='release' and not b['settings']['debug_assertions'];assert '#define DEBUG 1' in (r/'.work/candidate/config.h').read_text().splitlines()
for n in ['Perf/check-scope-cleanup-module.py','Perf/scope-pair-benchmark.py']:ast.parse((r/n).read_text())
write(l/'source-checks.json',dict(passed=True,parent=parent,pristine_files_verified=len(manifest),canonical_package_inputs_match=len(b['core_source_sha256']),all_changed_core_files_reconstructed=True,original_module_loader_logic_and_outer_signal_boundaries_preserved=True,generic_hash_scanners_unchanged=True,scope_restoration_body_unchanged=True,public_structures_and_existing_API_signatures_unchanged=True,vendor_pins_and_original_revisions_verified=True,incremental_patch_replayed=True,development_DEBUG=True,development_sha256=sha(r/'psh'),fixtures={n:sha(r/n) for n in files}))
if '--source-only' in sys.argv:print('All core transformations and source patch verified.');sys.exit(0)
assert read(l/'activation.json')['passed'];h=read(l/'hardware.json');assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(l/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
out.mkdir(exist_ok=True)
for p in l.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 dest=out/p.relative_to(l)
 if p.suffix in {'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for n in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/n,out/('package-validation.json' if n=='validation.json' else n))
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
