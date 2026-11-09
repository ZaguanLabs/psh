from pathlib import Path
import re,json
p=Path('.work/logs/round28/json-encode.callgrind');lines=p.read_text().splitlines();names={}
for s in lines:
 if s.startswith(('fn=','cfn=')):
  v=s.split('=',1)[1];m=re.match(r'\((\d+)\) (.*)',v)
  if m:names[m[1]]=m[2]
caller='';pending=None;rows=[]
for i,s in enumerate(lines):
 if s.startswith('fn='):
  v=s[3:];m=re.match(r'\((\d+)\)',v);caller=names.get(m[1],v) if m else v
 if s.startswith('cfn='):
  v=s[4:];m=re.match(r'\((\d+)\)',v);pending=names.get(m[1],v) if m else v
 if s.startswith('calls=') and pending=='arrlen':rows.append(dict(caller=caller,calls=s,instructions=lines[i+1]))
print(json.dumps(rows,indent=2))
