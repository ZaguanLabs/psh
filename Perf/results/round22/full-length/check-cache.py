from pathlib import Path
import hashlib,json,subprocess
root=Path.cwd();logs=root/'.work/logs/round22';module=logs/'native';module.mkdir(exist_ok=True)
cmd=['cc','-O2','-g','-shared','-fPIC','-DMODULE','-DHAVE_CONFIG_H','-I'+str(root/'.work/round22/previous/Src'),'-I'+str(root/'.work/round22/previous-source/Src'),str(root/'Perf/array-cache-module.c'),'-o',str(module/'psh_array_cache_fixture.so')]
subprocess.run(cmd,check=True);rows=[]
for script in ['array-cache-lifetimes.zsh','array-cache-mutations.zsh']:
 for mode in (['zsh'] if 'lifetimes' in script else ['zsh','ksh','sh']):
  for locale in ['C','C.UTF-8','fr_BE.UTF-8']:
   values=[]
   for label in ['previous','candidate']:
    shell=root/'.work/round22'/label/'Src/zsh';log=logs/(script+'-'+label+'-'+mode+'-'+locale+'.memcheck.log')
    args=['valgrind','--error-exitcode=97','--leak-check=no','--log-file='+str(log),str(shell),'-df',str(root/'Perf'/script),str(module) if 'lifetimes' in script else mode]
    r=subprocess.run(args,capture_output=True,env={'PATH':'/usr/bin:/bin','LC_ALL':locale},timeout=300)
    assert r.returncode==0 and not r.stderr,(script,label,mode,locale,r.returncode,r.stdout[-300:],r.stderr)
    physical=[int(line.split(b'=')[1]) for line in r.stdout.splitlines() if line.startswith(b'same_pointer=')]
    normalized=b'\n'.join(line for line in r.stdout.splitlines() if not line.startswith(b'same_pointer='))
    values.append(normalized);rows.append(dict(script=script,mode=mode,locale=locale,host=label,status=0,in_place_reallocations=sum(physical),stdout_sha256=hashlib.sha256(r.stdout).hexdigest(),binary_sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),command=args))
   assert values[0]==values[1],(script,mode,locale)
   print(script,mode,locale,'matched',flush=True)
(logs/'cache-lifetimes.json').write_text(json.dumps(dict(passed=True,compile_command=cmd,runs=rows),indent=2)+'\n')
