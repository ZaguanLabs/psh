from pathlib import Path
import ast,gzip,hashlib,json,shutil,subprocess,sys,tempfile
root=Path.cwd();logs=root/'.work/logs/round26';out=root/'Perf/results/round26'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
parent='402746ade22e5a9e8fc80702d4bce53455a62d06'
tracked=['Src/utils.c','COMPATIBILITY.md']
new=['Perf/strtol-reference.c','Perf/strtol-module.c','Perf/check-strtol-module.py','Perf/strtol-benchmark-module.c','Perf/strtol-benchmark.py'];files=tracked+new
patch=root/'Perf/0026-decimal-prefix-conversion.patch'
data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 r=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert r.returncode==1;data+=r.stdout
patch.write_bytes(('Round twenty-six: decimal prefixes without restarting conversion\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True)
 assert all((t/name).read_bytes()==(root/name).read_bytes() for name in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text());assert all(sha(root/'.work/pristine'/name)==h for name,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text());assert all(sha(root/name)==h for name,h in b['core_source_sha256'].items())
assert all((root/name).read_bytes()==(root/'.work/round26/resume-source'/name).read_bytes() for name in [*manifest,'Src/psh_version.h'])
s=(root/'Src/utils.c').read_text();i=s.index('    /* Eighteen decimal digits fit');j=s.index('    while (inblank(*s))',i)
restored=(s[:i]+s[j:]).replace('    decimal_digits:\n','');assert restored.encode()==subprocess.check_output(['git','show',parent+':Src/utils.c'])
up=(root/'.work/pristine/Src/utils.c').read_text();start=up.index('mod_export zlong\nzstrtol_underscore(');end=up.index('\n}\n',start)+3;oracle=up[start:end].replace('mod_export zlong\nzstrtol_underscore(','static zlong\nreference_zstrtol_underscore(');assert oracle in (root/'Perf/strtol-reference.c').read_text()
for name in ['Perf/check-strtol-module.py','Perf/strtol-benchmark.py']:ast.parse((root/name).read_text())
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h']:assert (root/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
assert (root/'.work/round26/previous/Src/utils.pro').read_bytes()==(root/'.work/round26/resume/Src/utils.pro').read_bytes()
assert '#define DEBUG' in (root/'.work/candidate/config.h').read_text()
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),timed_interpreter_inputs_match=len(manifest)+1,original_conversion_body_unchanged=True,oracle_matches_pristine_function=True,public_headers_and_conversion_declarations_unchanged=True,development_DEBUG=True,development_sha256=sha(root/'psh'),incremental_patch_replayed=True,fixtures={n:sha(root/n) for n in files}))
hardware=json.loads((logs/'hardware.json').read_text());assert all(e['running_ns']==e['enabled_ns'] for c in hardware['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(logs/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
if '--source-only' in sys.argv:
 print('Pristine, selected/timed/package inputs, original body, oracle, public declarations and patch verified.');sys.exit(0)
out.mkdir(exist_ok=True)
allowed={'.json','.py','.log','.txt','.asm','.patch','.c'}
for p in logs.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 relative=p.relative_to(logs)
 if relative.parts[0]=='resumed' and len(relative.parts)==2:continue
 dest=out/relative
 if p.suffix in allowed:
  dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':
  dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for name in ['validation.json','terminal-profile.json','installed-core-harness.json','ohmyzsh.json']:shutil.copy2(w/name,out/name if name!='validation.json' else out/'package-validation.json')
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['utils_sha256']=sha(root/'Src/utils.c');pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
