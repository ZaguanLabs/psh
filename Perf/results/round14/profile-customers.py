from pathlib import Path
import hashlib,json,re,subprocess
root=Path.cwd();logs=root/'.work/logs/round14';previous=[];rows=[]
for name,op,project,n in [('coder','coder-paste','/home/stig/dev/ai/zaguan/labs/zcoder.zsh',1),('fetch','fetch-encode','/home/stig/dev/ai/zaguan/labs/zfetch',3),('endgame','endgame-world','/home/stig/dev/challenge/endgame',2),('mario','mario-race','/home/stig/dev/challenge/z3dfx.mario',120),('drawing','drawing-binning','/home/stig/dev/challenge/z3dfx.drawing',3)]:
 previous.append({'name':name,'command':['valgrind','--tool=callgrind','',str(root/'.work/round13/psh'),'-df','Perf/customer-workload.zsh',op,project,str(n)]})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for entry in previous:
 name=entry['name'];states=[];counts={}
 for which,shell in [('previous',root/'.work/round13/psh'),('candidate',root/'.work/candidate/Src/zsh')]:
  cmd=entry['command'][:];cmd[2]='--callgrind-out-file='+str(logs/(name+'-'+which+'.callgrind'));cmd[3]=str(shell)
  env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'}
  with (logs/(name+'-'+which+'-output.log')).open('wb') as out,(logs/(name+'-'+which+'-profile.log')).open('wb') as err:
   r=subprocess.run(cmd,stdout=out,stderr=err,env=env)
  assert r.returncode==0,(name,which,r.returncode)
  states.append((logs/(name+'-'+which+'-output.log')).read_bytes().split(b'\n',1)[1])
  counts[which]=int(re.search(r'Collected : (\d+)',(logs/(name+'-'+which+'-profile.log')).read_text()).group(1))
  with (logs/(name+'-'+which+'-instructions.log')).open('wb') as out:
   subprocess.run(['callgrind_annotate','--auto=no','--inclusive=no','--threshold=95',str(logs/(name+'-'+which+'.callgrind'))],stdout=out,check=True)
  rows.append({'name':name,'which':which,'command':cmd,'environment':env,'binary_sha256':sha(shell),'worker_sha256':sha(root/'Perf/customer-workload.zsh'),'project_source_sha256':{str(p.relative_to(cmd[-2])):sha(p) for p in sorted((Path(cmd[-2])/'lib').glob('*.zsh'))},'instructions':counts[which],'status':r.returncode})
 assert states[0]==states[1],name
 print(name,counts,flush=True)
(logs/'matched-profile-commands.json').write_text(json.dumps(rows,indent=2)+'\n')
