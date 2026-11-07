from pathlib import Path
import difflib,hashlib,json,shutil,subprocess,tempfile
root=Path.cwd();logs=root/'.work/logs/round17';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
pristine=json.loads((root/'Perf/upstream-sha256.json').read_text())
assert all(sha(root/'.work/pristine'/p)==h for p,h in pristine.items())
previous=json.loads((root/'.work/round16/sha256.json').read_text())
assert all(sha(root/'.work/round16'/p)==h for p,h in previous.items())
assert sha(root/'psh')==sha(root/'.work/candidate/Src/zsh')
exports=lambda shell: sorted(' '.join(line.split()[1:]) for line in subprocess.check_output(['nm','-D','--defined-only',str(shell)],text=True).splitlines())
a=exports(root/'.work/baseline/Src/zsh');b=exports(root/'.work/candidate/Src/zsh');assert a==b
public={}
for file in ['exec','glob','params','utils','pattern','subst']:
 before=root/'.work/baseline/Src'/(file+'.epro');after=root/'.work/candidate/Src'/(file+'.epro')
 assert before.read_bytes()==after.read_bytes(),file
 public[file+'.epro']=sha(before)
patch=root/'Perf/0017-character-count-ascii.patch'
patch.write_bytes(subprocess.check_output(['git','diff','4f9e6fa','--','Src/utils.c','Test/D07multibyte.ztst']))
with tempfile.TemporaryDirectory(dir=root/'.work',prefix='round17-patch-') as temp:
 scratch=Path(temp)
 for file in ['Src/utils.c','Test/D07multibyte.ztst']:
  target=scratch/file;target.parent.mkdir(exist_ok=True);shutil.copy2(root/'.work/round16'/file,target)
 with patch.open('rb') as data:subprocess.run(['patch','-p1'],cwd=scratch,stdin=data,check=True,capture_output=True)
 assert all(sha(scratch/f)==sha(root/f) for f in ['Src/utils.c','Test/D07multibyte.ztst'])
for name,folder in [('bounded-loop','round17-bounded-loop'),('unguarded','round17-unguarded'),('nul-guard','round17-nul-guard')]:
 old=(root/'.work/round16/Src/utils.c').read_text().splitlines(True);new=(root/'.work'/folder/'utils.c').read_text().splitlines(True)
 (logs/(name+'-source.patch')).write_text(''.join(difflib.unified_diff(old,new,fromfile='a/Src/utils.c',tofile='b/Src/utils.c')))
source=(root/'.work/pristine/Src/utils.c').read_text();start=source.index('mod_export int\nmb_metastrlenend(');end=source.index('\n}\n',start)+3
body=source[start:end].replace('mod_export int\nmb_metastrlenend(', 'static int\nreference_mb_metastrlenend(').replace('mb_shiftstate','reference_state')
assert (root/'Perf/mb-length-reference.c').read_text().endswith(body)
record={'parent':'4f9e6fa','pristine_files':len(pristine),'pristine_hashes_match':True,'previous_hashes_match':True,'dynamic_names_types':len(a),'public_declarations':public,'patch_reconstruction':True,'reference_source_sha256':sha(root/'.work/pristine/Src/utils.c'),'binary_sha256':sha(root/'.work/candidate/Src/zsh'),'previous_binary_sha256':sha(root/'.work/round16/psh'),'source_sha256':{p:sha(root/p) for p in ['Src/utils.c','Test/D07multibyte.ztst','Perf/slice-benchmark.py','Perf/slice-workload.zsh','Perf/mb-length-module.c','Perf/mb-length-reference.c','Perf/check-mb-length-module.py']}}
(logs/'provenance.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
