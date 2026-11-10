from pathlib import Path
import hashlib,json,shutil,subprocess
r=Path.cwd();l=r/'.work/logs/round35';rows=[];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for host in ['previous','candidate']:
 build=r/'.work/round35'/host;source=r/'.work/round35/previous-source' if host=='previous' else r
 folder=l/'lifecycle'/host;folder.mkdir(parents=True,exist_ok=True)
 for c,out in [('scope-observer-module.c','psh_scope_observer'),('scope-opaque-module.c','psh_scope_opaque'),('scope-load-signal-module.c','psh_scope_signal')]:
  cmd=['cc','-O2','-g','-shared','-fPIC','-DMODULE','-DHAVE_CONFIG_H','-I'+str(build/'Src'),'-I'+str(source/'Src'),str(r/'Perf'/c),'-o',str(folder/(out+'.so'))];subprocess.run(cmd,check=True)
 shutil.copy2(l/'scope-aware'/('0' if host=='previous' else '1')/'psh_scope_cleanup_fixture.so',folder/'psh_scope_switch.so')
 expected='0' if host=='previous' else '1'
 scripts=[('signal','''module_path=("$1" $module_path)
zmodload zsh/parameter || exit 1
TRAPUSR1() { zmodload -u psh_scope_signal || return 7; }
zmodload psh_scope_signal || exit 2
(( ${+modules[psh_scope_signal]} == 0 )) || exit 3
print -r -- SIGNAL_UNLOAD_OK
'''),('reload','''module_path=("$1" $module_path)
zmodload psh_scope_observer || exit 1
[[ $(psh-scope-tracking) == "$2" ]] || exit 2
repeat 2 {
 zmodload psh_scope_switch || exit 3
 [[ $(psh-scope-tracking) == "$2" ]] || exit 4
 zmodload -u psh_scope_switch || exit 5
}
cp -- "$1/psh_scope_opaque.so" "$1/psh_scope_switch.so" || exit 6
typeset psh_opaque_ctor_target=global
() { local seed=1; }
zmodload psh_scope_switch || exit 7
(( ${+psh_opaque_ctor_target} == 0 )) || exit 8
[[ $(psh-scope-tracking) == 0 ]] || exit 9
print -r -- RELOAD_FALLBACK_OK
''')]
 for name,script in scripts:
  (folder/(name+'.zsh')).write_text(script);log=l/(host+'-'+name+'.memcheck.log');cmd=['valgrind','--error-exitcode=97','--leak-check=no','--log-file='+str(log),str(build/'Src/zsh'),'-dfc',script,'lifecycle',str(folder),expected];p=subprocess.run(cmd,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=120)
  (l/(host+'-'+name+'.log')).write_bytes(p.stdout+p.stderr)
  assert p.returncode==0 and not p.stderr,(host,name,p.returncode,p.stdout,p.stderr)
  assert 'ERROR SUMMARY: 0 errors' in log.read_text()
  rows.append(dict(host=host,test=name,command=cmd,status=p.returncode,stdout=p.stdout.decode(),binary_sha256=sha(build/'Src/zsh')));print(host,name,'passed',flush=True)
(l/'lifecycle.json').write_text(json.dumps(dict(passed=True,runs=rows),indent=2)+'\n')
