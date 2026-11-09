from pathlib import Path
import concurrent.futures,json,os,subprocess,time
root=Path.cwd();logs=root/'.work/logs/round28'
def build(label,source):
 folder=root/'.work/round28'/label;folder.mkdir(exist_ok=False);runtime=root/'.work/round28'/('runtime-'+label)
 commands=[('configure',[str(source/'configure'),f'--prefix={runtime}','--enable-dynamic','--enable-multibyte','--disable-zsh-debug','--enable-pcre','CFLAGS=-O2 -g','LDFLAGS=-g']),('build',['make','-j4']),('modules',['make',f'MODDIR={runtime}/lib/zsh/5.9.2','install.modules']),('functions',['make','install.fns'])];rows=[]
 for phase,cmd in commands:
  started=time.monotonic()
  with (logs/(label+'-'+phase+'.log')).open('wb') as out:r=subprocess.run(cmd,cwd=folder,env=dict(os.environ,TERM='xterm',LC_ALL='C.UTF-8'),stdout=out,stderr=subprocess.STDOUT)
  rows.append(dict(phase=phase,command=cmd,status=r.returncode,seconds=round(time.monotonic()-started,3)));print(label,phase,r.returncode,flush=True)
  if r.returncode:raise RuntimeError(label+' '+phase)
 (logs/(label+'-build.json')).write_text(json.dumps(rows,indent=2)+'\n')
build('candidate',root)
