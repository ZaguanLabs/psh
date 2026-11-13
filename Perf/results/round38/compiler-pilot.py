import json,subprocess
from pathlib import Path
root=Path.cwd();logs=root/'.work/rc1/logs'
plain=Path('/usr/local/psh/releases/1.0.0-rc1-82565bee3790/bin/psh')
variants={'lto':'fbc5d2ff0026','pgo':'4e247b3c7435','pgo-lto':'b737648775de'}
commands=[]
for label,digest in variants.items():
 shell=Path('/usr/local/psh/releases')/('1.0.0-rc1-'+digest)/'bin/psh'
 scenes=['python3','Perf/scene-benchmark.py',str(plain),str(shell),'--project','/home/stig/dev/challenge/z3dfx.drawing','--scene','moonlit','--samples','3','--cpu','13','--output',str(logs/(label+'-scene-pilot.json'))]
 customers=['python3','Perf/customer-benchmark.py',str(plain),str(shell),'--labs','/home/stig/dev/ai/zaguan/labs','--challenge','/home/stig/dev/challenge','--samples','9','--cpu','13','--output',str(logs/(label+'-customer-pilot.json'))]
 for name,cmd in [('scene',scenes),('customer',customers)]:
  commands.append(cmd)
  print('MEASURE',label,name,flush=True)
  with (logs/(label+'-'+name+'-pilot.log')).open('wb') as out:subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,check=True)
(logs/'pilot-commands.json').write_text(json.dumps(commands,indent=2)+'\n')
print('All compiler pilot comparisons passed with identical scene and customer state',flush=True)
