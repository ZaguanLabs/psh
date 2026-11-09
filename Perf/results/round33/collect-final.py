from pathlib import Path
import gzip,hashlib,json,shutil
r=Path.cwd();l=r/'.work/logs/round33';out=r/'Perf/results/round33';out.mkdir(exist_ok=True)
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert read(l/'restoration.json')['passed']
assert read(l/'github-precommit.json')==read(r/'.work/releases/v1.0.0-rc0/github-receipt.json')
assert read(l/'repository-precommit.json')['isPrivate']
def copy(p,dest):
 if p.suffix in {'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}:
  dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':
  dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
for p in (l/'initial').rglob('*'):
 if p.is_file():copy(p,out/p.relative_to(l))
names=['restore-proof.py','restoration.json','patch-preservation.json','hardware-scheduling.json','final-checkpoint.py','collect-final.py','github-precommit.json','repository-precommit.json']
for p in l.iterdir():
 if p.is_file() and (p.name in names or p.name.startswith(('aligned-','restored-'))):copy(p,out/p.name)
for p in (l/'restored-power').rglob('*.memcheck.log'):copy(p,out/p.relative_to(l))
b=read(r/'.work/package/latest.json');w=Path(b['work'])
for n in ['ohmyzsh.json','validation.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/n,out/('active-'+n))
for p in w.glob('test-*.json'):shutil.copy2(p,out/('active-prior-'+p.name))
print('Collected',sum(p.is_file() for p in out.rglob('*')),'evidence files; first candidate, layout pilot and restoration kept separate.')
