from pathlib import Path
import json,re
l=Path('.work/logs/round32');rows=json.loads((l/'profiles.json').read_text());out=[]
for row in rows:
 text=(l/(row['name']+'-callers.txt')).read_text();scope=set();calls=set();callbacks=set()
 for block in re.split(r'\n\s*\n',text):
  if re.search(r'\* .*params.c:endparamscope(?: |\n|$)',block):
   for line in block.splitlines():
    m=re.match(r'\s*([\d,]+).*\* .*params.c:endparamscope(?: |$)',line)
    if m:scope.add(int(m[1].replace(',','')))
  if re.search(r'\* .*hashtable.c:scanhashtable(?: |\n|$)',block):
   for line in block.splitlines():
    m=re.match(r'\s*([\d,]+).*< .*params.c:endparamscope \(([\d,]+)x\)',line)
    if m:calls.add(tuple(int(s.replace(',','')) for s in m.groups()))
  if re.search(r'\* .*params.c:scanendscope(?: |\n|$)',block):
   for line in block.splitlines():
    m=re.match(r'\s*([\d,]+).*< .*hashtable.c:scanmatchtable \(([\d,]+)x\)',line)
    if m:callbacks.add(tuple(int(s.replace(',','')) for s in m.groups()))
 assert len(scope)==len(calls)==len(callbacks)==1,(row['name'],scope,calls,callbacks)
 cost,scans=calls.pop();callback_cost,number=callbacks.pop();out.append(dict(name=row['name'],process_instructions=row['instructions'],scope_inclusive_instructions=scope.pop(),scope_scanner_inclusive_instructions=cost,scope_exits=scans,scope_cleanup_callbacks=number,callback_inclusive_instructions=callback_cost))
(l/'profile-metrics.json').write_text(json.dumps(out,indent=2)+'\n')
for r in out:print(r)
