from pathlib import Path
import json,shutil
l=Path('.work/logs/round29');d=l/'peeled-noisy';d.mkdir(exist_ok=False);inputs=json.loads((l/'timing-input.json').read_text())
for row in inputs:
 for ext in ['.json','.log']:
  p=l/(row['name']+ext)
  if p.exists():shutil.move(p,d/p.name)
for n in ['timing-input.json','timing-commands.json','timing.py','timing.log','activity-observation.json']:
 if (l/n).exists():shutil.move(l/n,d/n)
for n in ['hash-benchmarks','hardware-fixture-hardware']:
 if (l/n).exists():shutil.move(l/n,d/n)
# Only the benchmark processes will be moved; other programs are untouched.
for row in inputs:
 i=row['command'].index('--cpu');row['command'][i+1]='13'
(l/'timing-input.json').write_text(json.dumps(inputs,indent=2)+'\n');(l/'timing.py').write_text((d/'timing.py').read_text())
print('Noisy CPU-2 pass retained; final timing commands prepared for CPU 13.')
