from pathlib import Path
import hashlib,json,os,pwd,subprocess,sys
r=Path.cwd();l=r/'.work/logs/round35';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sys.path.insert(0,str(r/'Packaging'))
from audit import stable_snapshot
from install import manifest
b=read(r/'.work/package/latest.json');w=Path(b['work']);old=read(l/'previous-release.json');assert b['release']=='1.0.0-rc0-bde30291d0ec'
for n in ['validation','native-validation','source-checks','release-identity','identity','lifecycle','growth','old-modules']:assert read(l/(n+'.json'))['passed'],n
assert read(l/'source-checks.json')['incremental_patch_replayed'];assert all(sha(r/n)==h for n,h in read(l/'frozen-inputs.json').items())
native=read(l/'native-validation.json');assert (native['checks'],native['memcheck_processes'])==(28392,26)
for row in native['reports']:
 d=read(l/(row['report']+'.json'));assert d['passed']
 for n in ['Perf/scope-cleanup-module.c','Perf/check-scope-cleanup-module.py']:assert d['fingerprints'][str(r/n)]==sha(r/n)
 assert all(x['status']==0 and x['memcheck'] for x in d['runs'])
for n in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:assert read(w/('test-'+n+'.json'))['passed'],n
assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
commands=read(l/'timing-commands.json');assert len(commands)==9 and all(x['status']==0 for x in commands)
for n in ['customer-benchmarks','customer-repeat']:
 d=read(l/(n+'.json'));assert d['samples']==9 and d['cpu_affinity']==[13]
 for c in d['cases']:
  if c['case'] in ['zcoder.zsh/coder-paste','zchat.zsh/chat-paste']:assert c['median_ms'][1]<c['median_ms'][0]*0.95
for n in ['library-benchmarks','library-repeat']:
 d=read(l/(n+'.json'));assert d['samples']==9 and all(c['median_ms'][1]<c['median_ms'][0] for c in d['cases'])
h=read(l/'hardware.json');assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events'])
assert Path('/usr/local/psh/current').resolve()==Path(old['prefix'])
subprocess.run(['sudo','-n','python3','Packaging/install.py','activate'],check=True)
assert manifest(Path(old['prefix']))==old['manifest'];assert sha(Path('/etc/shells'))==old['etc_shells_sha256'];assert pwd.getpwuid(os.getuid()).pw_shell==old['login_shell'];assert stable_snapshot()==read(w/'stable-before.json')
assert Path('/usr/local/psh/current').resolve()==Path(b['prefix']) and Path('/usr/local/bin/psh').resolve()==Path(b['prefix'])/'bin/psh';assert sha(Path('/usr/local/bin/psh'))==b['installed_shell_sha256']
(l/'activation.json').write_text(json.dumps(dict(passed=True,active_prefix=b['prefix'],shell_sha256=sha(Path('/usr/local/bin/psh')),previous_prefix=old['prefix'],previous_release_entries_unchanged=len(old['manifest']),stable_zsh_startup_entries_unchanged=len(read(w/'stable-before.json')),etc_shells_unchanged=True,login_shell_unchanged=True,accepted_optimizations=27),indent=2)+'\n');print('Activated',b['release'],'with protected files and previous release unchanged.')
