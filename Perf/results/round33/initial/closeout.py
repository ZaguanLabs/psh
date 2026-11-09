from pathlib import Path
import ast,gzip,hashlib,json,re,shutil,subprocess,sys,tempfile
r=Path.cwd();l=r/'.work/logs/round33';out=r/'Perf/results/round33';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');parent=read(l/'parent.json')['commit']
tracked=['Src/math.c','Test/C01arith.ztst','COMPATIBILITY.md'];new=['Perf/power-module.c','Perf/check-power-module.py','Perf/power-benchmark.py'];files=tracked+new;patch=r/'Perf/0033-logarithmic-integer-powers.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 result=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert result.returncode==1;data+=result.stdout
patch.write_bytes(('Round 33: logarithmic integer powers\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as td:
 t=Path(td)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 result=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True);assert all((t/n).read_bytes()==(r/n).read_bytes() for n in files);write(l/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=result.stdout.decode()))
old=subprocess.check_output(['git','show',parent+':Src/math.c']).decode();cur=(r/'Src/math.c').read_text();start=cur.index('\t\t    /* Consume exponent bits;');end=cur.index('\n\t\t} else {',start);restored=cur[:start]+'\t\t    for (c.u.l = 1; b.u.l--; c.u.l *= a.u.l);'+cur[end:];assert restored==old
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h','Src/params.c','Src/hashtable.c','Src/utils.c']:assert (r/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
for name in ['math.pro','math.epro']:assert (r/'.work/round33/previous/Src'/name).read_bytes()==(r/'.work/round33/candidate/Src'/name).read_bytes()
manifest=read(r/'Perf/upstream-sha256.json');assert all(sha(r/'.work/pristine'/n)==h for n,h in manifest.items());b=read(r/'.work/package/latest.json');assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert b['settings']['profile']=='release' and not b['settings']['debug_assertions'];assert '#define DEBUG 1' in (r/'.work/candidate/config.h').read_text().splitlines()
for name in new:
 if name.endswith('.py'):ast.parse((r/name).read_text())
write(l/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),canonical_package_inputs_match=len(b['core_source_sha256']),only_integer_power_block_changed=True,floating_and_negative_promotion_source_unchanged=True,all_other_math_functions_unchanged=True,scope_array_and_public_headers_unchanged=True,public_declarations_unchanged=True,incremental_patch_replayed=True,development_DEBUG=True,development_sha256=sha(r/'psh'),fixtures={n:sha(r/n) for n in files}))
if '--source-only' in sys.argv:print('Source and six-file patch checks passed.');sys.exit(0)
assert read(l/'activation.json')['passed'];h=read(l/'hardware.json');assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(l/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
out.mkdir(exist_ok=True)
for p in l.rglob('*'):
 if not p.is_file() or p.name=='previous-release.json' or 'hardware-fixture-hardware' in p.parts:continue
 dest=out/p.relative_to(l)
 if p.suffix in {'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for name in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/name,out/('package-validation.json' if name=='validation.json' else name))
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['math_sha256']=sha(r/'Src/math.c');pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
