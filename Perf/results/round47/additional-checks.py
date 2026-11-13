from pathlib import Path
import subprocess,shutil,json,hashlib,importlib.util,os,tempfile
r=Path.cwd();out=r/'.work/round47';pkg=r/'.work/package/1.0.0-rc1-1d2a092078fb';b=json.loads((pkg/'build.json').read_text());prefix=Path(b['prefix']);old=Path('/usr/local/psh/releases/1.0.0-rc1-126770ba80d2')
assert json.loads((out/'final-checks.json').read_text())['passed']
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
bridge=out/'checks-zdraw';(bridge/'benchmarks').mkdir(parents=True);(bridge/'tests').mkdir();(bridge/'.build/zsh/Src/Modules').mkdir(parents=True)
(bridge/'.build/modules').symlink_to(prefix/'lib/psh/5.9.2');(bridge/'.build/zsh/Src/zsh').symlink_to(prefix/'bin/psh');(bridge/'.build/zsh/config.h').symlink_to(prefix/'include/psh/config.h');(bridge/'.build/zsh/Src/Modules/curses.so').symlink_to(prefix/'lib/psh/5.9.2/zsh/curses.so');(bridge/'lib').symlink_to(prefix/'share/psh/5.9.2/scripts/zdraw/lib')
for name in ['style-differential.py','curses-differential.py','native.py','lifecycle.py','components.py','components.zsh']:
 shutil.copy2(r/'Vendor/zdraw/benchmarks'/name,bridge/'benchmarks'/name)
shutil.copy2(r/'Vendor/zdraw/tests/lifecycle-stress.zsh',bridge/'tests/lifecycle-stress.zsh')
identities={str(p):sha(p) for p in [prefix/'bin/psh',prefix/'lib/psh/5.9.2/zdraw.so',prefix/'lib/psh/5.9.2/zsh/curses.so',*sorted((bridge/'benchmarks').glob('*')),bridge/'tests/lifecycle-stress.zsh']}
rows=[]
def run(name,args,locale='C.UTF-8'):
 cmd=['python3',*map(str,args)];print('Starting',name,flush=True)
 with (out/(name+'.json')).open('wb') as f, (out/(name+'.log')).open('wb') as err:
  p=subprocess.run(cmd,stdout=f,stderr=err,env=dict(os.environ,ZDRAW_TEST_LOCALE=locale),timeout=400)
 rows.append(dict(name=name,command=cmd,status=p.returncode,locale=locale))
 (out/'additional-session.json').write_text(json.dumps(rows,indent=2)+'\n')
 assert p.returncode==0,(name,p.returncode)
 print('Passed',name,flush=True)
# Preserve a failing preceding-build oracle and check the corrected installed module.
for label,release,expected_status in [('previous',old,1),('candidate',prefix,0)]:
 cmd=['python3','Perf/check-curses-querychar.py','--shell',str(release/'bin/psh'),'--modules',str(release/'lib/psh/5.9.2'),'--memcheck','--output',str(out/'querychar'/(label+'-matrix.json'))]
 with (out/'querychar'/(label+'-matrix.log')).open('wb') as log:
  result=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=400)
 assert result.returncode==expected_status,(label,result.returncode)
 data=json.loads((out/'querychar'/(label+'-matrix.json')).read_text())
 assert all(x['passed'] for x in data['runs'] if x['backend']=='zdraw')
 assert data['passed']==(label=='candidate')
 print('Checked querychar',label,flush=True)
for locale,label in [('C','C'),('C.UTF-8','UTF8')]:
 run('styles-'+label,[bridge/'benchmarks/style-differential.py','--baseline-root',old/'share/psh/5.9.2/scripts/zdraw','--cases','2000'],locale)
run('stock-curses',[bridge/'benchmarks/curses-differential.py','--operations','600'])
stock=json.loads((out/'stock-curses.json').read_text());assert stock['identical_statuses_and_cells'] and stock['identical_terminal_bytes']
for mode in ['standalone','stock']:
 run('lifecycle-'+mode,[bridge/'benchmarks/lifecycle.py','--cycles','100','--mode',mode,'--valgrind-log',out/(mode+'-memcheck.log'),'--timeout','300'])
 data=json.loads((out/('lifecycle-'+mode+'.json')).read_text());assert data['terminal_restored'] and data['memcheck']['errors']==0
# Exercise the rejection branch repeatedly under Memcheck, without replacing ncurses.
spec=importlib.util.spec_from_file_location('features',r/'Vendor/zdraw/tests/test_features.py');features=importlib.util.module_from_spec(spec);spec.loader.exec_module(features)
features.BUILD=Path(b['core'])
guard_dir=out/'guarded-build';guard_dir.mkdir()
guard_source=(r/'Vendor/zdraw/Src/Modules/zdraw.c').read_text().replace('#include <stdio.h>','#include <stdio.h>\n#undef HAVE_ZDRAW_SAFE_DELSCREEN',1)
(out/'guarded-source.c').write_text(guard_source)
modules=features.FeatureTests().variant(guard_dir,guard_source)
(modules/'zsh').mkdir();shutil.copy2(prefix/'lib/psh/5.9.2/zsh/curses.so',modules/'zsh/curses.so')
spec=importlib.util.spec_from_file_location('lifecycle',bridge/'benchmarks/lifecycle.py');lifecycle=importlib.util.module_from_spec(spec);spec.loader.exec_module(lifecycle)
guarded=lifecycle.run(100,20261113,'stock',prefix/'bin/psh',modules,True,out/'guarded-memcheck.log',300)
assert guarded['terminal_restored'] and guarded['memcheck']['errors']==0
guarded['source_sha256']=sha(out/'guarded-source.c');guarded['module_sha256']=sha(modules/'zdraw.so')
(out/'lifecycle-guarded.json').write_text(json.dumps(guarded,indent=2)+'\n')
print('Passed forced guard Memcheck lifecycle',flush=True)
assert identities=={name:sha(Path(name)) for name in identities}
(out/'additional-checks.json').write_text(json.dumps(dict(passed=True,identities=identities,runs=rows),indent=2)+'\n')
# Profile a bounded changing form/document workload separately from timing.
spec=importlib.util.spec_from_file_location('components',bridge/'benchmarks/components.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
profile_rows=[]
for label,release in [('baseline',old),('candidate',prefix)]:
 root=out/('profile-'+label);(root/'.build/zsh/Src').mkdir(parents=True);(root/'benchmarks').mkdir()
 (root/'.build/zsh/Src/zsh').symlink_to(release/'bin/psh');(root/'.build/modules').symlink_to(release/'lib/psh/5.9.2');(root/'lib').symlink_to(release/'share/psh/5.9.2/scripts/zdraw/lib')
 shutil.copy2(bridge/'benchmarks/components.zsh',root/'benchmarks/components.zsh');m.ROOT=root
 for workload in ['form','document']:
  path=out/(label+'-'+workload+'-zprof.txt')
  result=m.trial(workload,'changing','large',5,root=root,zprof=path)
  profile_rows.append(dict(host=label,workload=workload,shell_sha256=sha(release/'bin/psh'),module_sha256=sha(release/'lib/psh/5.9.2/zdraw.so'),profile=str(path),result=result))
for workload in ['form','document']:
 items=[x['result'] for x in profile_rows if x['workload']==workload]
 for key in ['snapshot_sha256','output_sha256','resources']:assert items[0][key]==items[1][key],(workload,key)
(out/'profiles.json').write_text(json.dumps(dict(instrumented=True,scope='function profiles only; elapsed times are not benchmark results',runs=profile_rows),indent=2)+'\n')
print('Profiles complete',flush=True)
