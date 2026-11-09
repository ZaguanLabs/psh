from pathlib import Path
import gzip,hashlib,json,shutil
root=Path.cwd();l=root/'.work/logs/round30';out=root/'Perf/results/round30';out.mkdir(exist_ok=True)
rename={'installed-package.json':'inactive-package.json','package-validation.json':'inactive-package-validation.json','ohmyzsh.json':'inactive-ohmyzsh.json','installed-core-harness.json':'inactive-core-harness.json','terminal-profile.json':'inactive-terminal-profile.json','closeout.py':'candidate-closeout.py'}
for old,new in rename.items():
 p=out/old
 if p.exists():p.rename(out/new)
for p in l.rglob('*'):
 if not p.is_file() or p.name in ['previous-release.json','checkpoint.txt'] or 'hardware-fixture-hardware' in p.parts:continue
 relative=p.relative_to(l);dest=out/relative
 if p.name=='closeout.py':dest=dest.with_name('candidate-closeout.py')
 if p.suffix in {'.json','.py','.log','.txt','.asm','.patch','.c','.gdb','.zsh'}:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.parent.mkdir(parents=True,exist_ok=True);dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
b=json.loads((root/'.work/package/latest.json').read_text());w=Path(b['work'])
for n in ['ohmyzsh.json','validation.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/n,out/('active-'+n))
for p in w.glob('test-*.json'):shutil.copy2(p,out/('active-prior-'+p.name))
print('Collected',sum(p.is_file() for p in out.rglob('*')),'evidence files')
