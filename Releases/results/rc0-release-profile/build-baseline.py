from pathlib import Path
import hashlib, json, os, subprocess, time
root=Path.cwd(); source=root/'.work/pristine'; work=root/'.work/rc0-release-baseline'; logs=root/'.work/logs/rc0-release-profile'
manifest=json.loads((root/'Perf/upstream-sha256.json').read_text())
assert {p.relative_to(source).as_posix() for p in source.rglob('*') if p.is_file() or p.is_symlink()}==set(manifest)
assert all(hashlib.sha256((source/p).read_bytes()).hexdigest()==h for p,h in manifest.items())
work.mkdir(exist_ok=False); runtime=root/'.work/rc0-release-baseline-runtime'
configure=[str(source/'configure'),f'--prefix={runtime}','--enable-dynamic','--enable-multibyte','--disable-zsh-debug','--enable-pcre','--enable-site-fndir=no']
rows=[]
for name,cmd in [('configure',configure),('build',['make','-j4']),('modules',['make',f'MODDIR={runtime}/lib/zsh/5.9.2','install.modules']),('upstream',['make','check'])]:
 started=time.monotonic()
 with (logs/('pristine-'+name+'.log')).open('wb') as out:
  result=subprocess.run(cmd,cwd=work,env=dict(os.environ,CFLAGS='-O2 -g',TERM='xterm',LC_ALL='C.UTF-8'),stdout=out,stderr=subprocess.STDOUT)
 rows.append(dict(name=name,command=cmd,status=result.returncode,seconds=round(time.monotonic()-started,3)))
 print(name,result.returncode,flush=True)
 if result.returncode: raise RuntimeError(name)
assert '#define DEBUG 1' not in (work/'config.h').read_text().splitlines()
(logs/'pristine-build.json').write_text(json.dumps(dict(passed=True,baseline_files_verified=len(manifest),source=str(source),build=str(work),configure=configure,binary_sha256=hashlib.sha256((work/'Src/zsh').read_bytes()).hexdigest(),runs=rows),indent=2)+'\n')
