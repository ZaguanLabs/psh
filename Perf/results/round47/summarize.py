from pathlib import Path
import json
r=Path('.work/round47');runs=[json.loads((r/n).read_text()) for n in ['components.json','components-repeat.json']]
rows=[]
for one,two in zip(runs[0]['cases'],runs[1]['cases']):
 key=lambda c:(c['workload'],c['pattern'],c['size'])
 assert key(one)==key(two)
 values=[]
 for c in (one,two):
  a,b=c['medians'];values.append(dict(baseline_ms=a['work_ms'],candidate_ms=b['work_ms'],time_saved_percent=100*(1-b['work_ms']/a['work_ms'])))
 rows.append(dict(workload=one['workload'],pattern=one['pattern'],size=one['size'],runs=values))
(r/'timing-summary.json').write_text(json.dumps(dict(cases=rows),indent=2)+'\n')
for row in rows:
 print('|',row['workload'],row['pattern'],row['size'],'|',' | '.join(f"{x['baseline_ms']:.4f} → {x['candidate_ms']:.4f} ({x['time_saved_percent']:+.1f}%)" for x in row['runs']),'|')
