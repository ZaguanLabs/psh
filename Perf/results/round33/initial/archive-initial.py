from pathlib import Path
import json,shutil
r=Path.cwd();l=r/'.work/logs/round33';out=l/'initial';out.mkdir(exist_ok=False);allowed={'.json','.py','.log','.txt','.patch','.c','.asm','.zsh','.callgrind'}
for p in list(l.rglob('*')):
 if not p.is_file() or out in p.parents or p.name=='previous-release.json' or 'hardware-fixture-hardware' in p.parts:continue
 if p.suffix in allowed:
  dest=out/p.relative_to(l);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
b=json.loads((r/'.work/package/latest.json').read_text());(out/'inactive-build.json').write_text(json.dumps(b,indent=2)+'\n');w=Path(b['work'])
for name in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/name,out/('package-'+name))
for p in w.glob('test-*.json'):shutil.copy2(p,out/p.name)
for p in (w/'logs').glob('test-*.log'):shutil.copy2(p,out/p.name)
shutil.copy2(r/'Perf/0033-logarithmic-integer-powers.patch',out/'proposed-with-fixtures.patch');shutil.copy2(r/'.work/round33/candidate/Src/zsh',r/'.work/round33/initial-zsh');print('Initial candidate and all nine timing groups preserved.')
