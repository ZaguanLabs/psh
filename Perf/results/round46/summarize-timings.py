from pathlib import Path
import json
r=Path('.work/round46');p=Path('Perf/results/round46');p.mkdir(parents=True,exist_ok=True)
rows=['# Round 46 complete timing results','','Two complete runs each use nine alternating samples per release on CPU 13,','C.UTF-8. Positive changes mean more elapsed time (slower); negative means less.','All complete output states match. See the raw JSON for samples, source/cache','metadata, binary hashes and measurement scopes. Setup of files/private source','copies and reference-result validation are outside the process timers.','']
for group,unit in [('glob','ms/process'),('customer','ms/batch, warm operation'),('applications','ms/call, warm operation'),('fresh-customer','ms/current project kernel process'),('text-customer','ms/private text-only project kernel process')]:
 a=json.loads((r/(group+'.json')).read_text());b=json.loads((r/(group+'-repeat.json')).read_text());has_rss='median_rss_kib' in a['cases'][0]
 rows+=['## '+group,'',unit+'. Neither fresh kernel mode represents a complete app launch.' if 'customer' in group and group!='customer' else unit+'.','','| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |'+(' First RSS, KiB | Repeat RSS, KiB |' if has_rss else ''),'| --- | ---: | ---: | ---: | ---: |'+(' ---: | ---: |' if has_rss else '')]
 for x,y in zip(a['cases'],b['cases'],strict=True):
  label=x.get('case',x.get('operation'));assert label==y.get('case',y.get('operation'))
  if 'files' in x:label+=f" ({x['files']} files)";assert x['files']==y['files']
  m,n=x['median_ms'];u,v=y['median_ms'];row=f'| {label} | {m:.3f} → {n:.3f} | {(n/m-1)*100:+.2f}% | {u:.3f} → {v:.3f} | {(v/u-1)*100:+.2f}% |'
  if has_rss:
   aa,bb=x['median_rss_kib'];cc,dd=y['median_rss_kib'];row+=f' {aa:,} → {bb:,} | {cc:,} → {dd:,} |'
  rows.append(row)
 rows+=['']
(p/'timings.md').write_text('\n'.join(rows).rstrip()+'\n')
