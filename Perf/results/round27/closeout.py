from pathlib import Path
import ast,gzip,hashlib,json,re,shutil,subprocess,sys,tempfile
root=Path.cwd();logs=root/'.work/logs/round27';out=root/'Perf/results/round27'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
parent='45d9520b21e92068cb4e9620cf748875874bd75a';tracked=['Src/options.c','COMPATIBILITY.md'];new=['Perf/emulation-module.c','Perf/check-emulation-module.py','Perf/emulation-compare.py'];files=tracked+new
patch=root/'Perf/0027-option-emulation-prefilter.patch';data=subprocess.check_output(['git','diff','--binary',parent,'--',*tracked])
for name in new:
 r=subprocess.run(['git','diff','--no-index','--','/dev/null',name],capture_output=True);assert r.returncode==1;data+=r.stdout
patch.write_bytes(('Round twenty-seven: prefilter option entries during emulation\nParent: '+parent+'\n\n').encode()+data)
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp)
 for name in tracked:
  p=t/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(subprocess.check_output(['git','show',parent+':'+name]))
 r=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True)
 assert all((t/name).read_bytes()==(root/name).read_bytes() for name in files)
 write(logs/'patch-check.json',dict(passed=True,parent=parent,files=files,patch_sha256=sha(patch),log=r.stdout.decode()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text());assert all(sha(root/'.work/pristine'/n)==h for n,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text());assert all(sha(root/n)==h for n,h in b['core_source_sha256'].items())
def function(s,name):
 start=s.index(name+'(');start=s.rfind('\n',0,start)+1;end=s.index('\n}',start)+2;return s[start:end]
old=subprocess.check_output(['git','show',parent+':Src/options.c']).decode();cur=(root/'Src/options.c').read_text();up=(root/'.work/pristine/Src/options.c').read_text()
assert cur.replace(function(cur,'installemulation'),function(old,'installemulation'))==old
assert function(cur,'setemulate')==function(up,'setemulate')
norm=lambda s:re.sub(r'\s+','',re.sub(r'/\*.*?\*/','',s,flags=re.S))
ref=function((root/'Perf/emulation-module.c').read_text(),'reference_set');expected=function(up,'setemulate')
expected=expected[expected.index('{'):];ref=ref[ref.index('{'):]
for a,c in [('setemulate_opts','ref_opts'),('setemulate_emulation','ref_mode'),('OPT_ALIAS','F_ALIAS'),('OPT_SPECIAL','F_SPECIAL'),('OPT_EMULATE','F_EMULATE')]:expected=expected.replace(a,c)
assert norm(expected).replace('defset(on,ref_mode)','!!(on->node.flags&ref_mode)')==norm(ref)
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h']:assert (root/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
for name in ['options.pro','options.epro']:assert (root/'.work/round27/previous/Src'/name).read_bytes()==(root/'.work/round27/candidate/Src'/name).read_bytes()
for name in new:
 if name.endswith('.py'):ast.parse((root/name).read_text())
assert '#define DEBUG' in (root/'.work/candidate/config.h').read_text()
write(logs/'source-checks.json',dict(passed=True,pristine_files_verified=len(manifest),installed_core_inputs_match=len(b['core_source_sha256']),only_installemulation_changed=True,original_setter_matches_pristine=True,native_oracle_matches_pristine_predicate=True,public_headers_and_option_declarations_unchanged=True,development_DEBUG=True,development_sha256=sha(root/'psh'),incremental_patch_replayed=True,fixtures={n:sha(root/n) for n in files}))
h=json.loads((logs/'hardware.json').read_text());assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events']);write(logs/'hardware-scheduling.json',dict(passed=True,fully_scheduled=True))
if '--source-only' in sys.argv:print('Pristine/package inputs, original setter/oracle, public declarations and patch verified.');sys.exit(0)
out.mkdir(exist_ok=True);allowed={'.json','.py','.log','.txt','.asm','.patch','.c','.gdb'}
for p in logs.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 relative=p.relative_to(logs);dest=out/relative
 if p.suffix in allowed:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
w=Path(b['work'])
for name in ['validation.json','terminal-profile.json','installed-core-harness.json','ohmyzsh.json']:shutil.copy2(w/name,out/name if name!='validation.json' else out/'package-validation.json')
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
pkg={k:b[k] for k in ['release','prefix','project_version','zsh_version','settings','raw_shell_sha256','installed_shell_sha256','debug_file_sha256','vendor_commits']};pkg['options_sha256']=sha(root/'Src/options.c');pkg['native_sha256']={str(p.relative_to(Path(b['prefix']))):sha(p) for p in Path(b['prefix']).rglob('*.so')};write(out/'installed-package.json',pkg)
print('Evidence collected:',sum(p.is_file() for p in out.rglob('*')))
