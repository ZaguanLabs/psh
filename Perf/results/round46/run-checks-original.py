import json, subprocess, time
from pathlib import Path
r=Path('.work/round46'); b=Path('.work/package/1.0.0-rc1-126770ba80d2/build.json')
old='/usr/local/psh/releases/1.0.0-rc1-345edd03d312/bin/psh'
new='/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh'
pristine='.work/public-rc0/reference/Src/zsh'
results=[]
def run(name, cmd, timeout=1800):
    start=time.time(); print('Starting', name, flush=True)
    with (r/(name+'.log')).open('wb') as out:
        p=subprocess.run(cmd,stdout=out,stderr=subprocess.STDOUT,timeout=timeout)
    results.append(dict(name=name,command=cmd,status=p.returncode,seconds=time.time()-start))
    (r/'check-session.json').write_text(json.dumps(results,indent=2)+'\n')
    if p.returncode: raise RuntimeError((name,p.returncode))
    print('Passed',name,flush=True)
assert b.exists()
run('snapshot',['python3','Packaging/verify.py','snapshot','--build',str(b)])
run('install',['sudo','-n','python3','Packaging/install.py','candidate','--build',str(b)])
run('lexer',['python3','Perf/check-lexer-copy.py',pristine,old,new,'--memcheck','--output',str(r/'lexer-release.json')])
run('glob',['python3','Perf/check-glob-programs.py',pristine,old,new,'--headers-build','.work/public-rc0/reference','--headers-source','.work/pristine','--memcheck','--output',str(r/'glob.json')])
run('profile',['python3',str(r/'profile.py')])
run('package-test',['python3','Packaging/test.py','--build',str(b),'--jobs','1'])
run('stage',['python3','Packaging/verify.py','stage-modules','--build',str(b)])
run('refresh',['sudo','-n','python3','Packaging/install.py','refresh-modules','--build',str(b)])
run('verify',['python3','Packaging/verify.py','verify','--build',str(b)])
(r/'final-checks.json').write_text(json.dumps(dict(passed=True,runs=results),indent=2)+'\n')
