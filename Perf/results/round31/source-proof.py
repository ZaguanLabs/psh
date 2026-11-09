from pathlib import Path
import ast,hashlib,json,subprocess,sys,tempfile
root=Path.cwd();l=root/'.work/logs/round31';parent=json.loads((l/'parent.json').read_text())['commit'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();original=subprocess.check_output(['git','show',parent+':Src/math.c'])
assert (root/'Src/math.c').read_bytes()==original
records=[]
for patch in [l/'descriptor-pool/source.patch',l/'inline-parser/source.patch',l/'source.patch']:
 with tempfile.TemporaryDirectory() as td:
  t=Path(td);(t/'Src').mkdir();(t/'Src/math.c').write_bytes(original)
  subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,check=True,capture_output=True)
  content=(t/'Src/math.c').read_bytes()
  if patch.parent.name=='inline-parser':assert content.replace(b'static inline void\nmathparse(int pc)',b'static void\nmathparse(int pc)')==original
  elif patch.parent==l:assert content.replace(b'static inline mnumber\ngetmathparam(struct mathvalue *mptr)',b'static mnumber\ngetmathparam(struct mathvalue *mptr)')==original
  records.append(dict(patch=str(patch.relative_to(root)),patch_sha256=sha(patch),proposed_math_sha256=hashlib.sha256(content).hexdigest()))
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text());assert all(sha(root/'.work/pristine'/n)==h for n,h in manifest.items())
b=json.loads((root/'.work/package/latest.json').read_text());assert all(sha(root/n)==h for n,h in b['core_source_sha256'].items())
sys.path.insert(0,str(root/'Packaging'));from elf import dynamic_exports,allocated_sections
hosts=[root/'.work/round31'/n/'Src/zsh' for n in ['previous','candidate']];assert dynamic_exports(hosts[0])==dynamic_exports(hosts[1])
for name in ['Src/zsh.h','Src/ztype.h','Src/signals.h','Src/params.c','Src/hashtable.c','Src/utils.c']:assert (root/name).read_bytes()==subprocess.check_output(['git','show',parent+':'+name])
ast.parse((root/'Perf/math-compare.py').read_text())
assert not subprocess.check_output(['git','diff','--','Src'])
(l/'source-checks.json').write_text(json.dumps(dict(passed=True,parent=parent,pristine_files_verified=len(manifest),active_core_inputs_match=len(b['core_source_sha256']),production_restored=True,trial_patches=records,accessor_trial_only_one_inline_hint=True,public_headers_unchanged=True,dynamic_exports_unchanged=len(dynamic_exports(hosts[0])),private_host_sha256={str(p):sha(p) for p in hosts},math_compare_sha256=sha(root/'Perf/math-compare.py')),indent=2)+'\n')
print('All three source proposals replay; accepted production inputs match.')
