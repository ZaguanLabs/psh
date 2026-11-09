from pathlib import Path
import gzip,hashlib,json,shutil
r=Path.cwd();l=r/'.work/logs/round34';out=r/'Perf/results/round34';out.mkdir(exist_ok=True);read=lambda p:json.loads(p.read_text())
assert read(l/'restoration.json')['passed']
for p in l.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 dest=out/p.relative_to(l)
 if p.name=='closeout.py':dest=dest.with_name('candidate-closeout.py')
 if p.suffix in {'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
trial=read(l/'inactive-build.json');w=Path(trial['work'])
for n in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/n,out/('inactive-'+n))
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
b=read(r/'.work/package/latest.json');w=Path(b['work'])
for n in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/n,out/('active-'+n))
for p in w.glob('test-*.json'):shutil.copy2(p,out/('active-prior-'+p.name))
print('Collected',sum(p.is_file() for p in out.rglob('*')),'evidence files.')
