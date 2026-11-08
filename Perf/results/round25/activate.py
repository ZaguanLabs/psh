from pathlib import Path
import hashlib,json,os,pwd,subprocess,sys
root=Path.cwd();logs=root/'.work/logs/round25';sys.path.insert(0,str(root/'Packaging'))
from audit import stable_snapshot
from install import manifest
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
b=read(root/'.work/package/latest.json');w=Path(b['work']);old=read(logs/'previous-release.json')
assert read(logs/'validation.json')['passed'] and read(logs/'source-checks.json')['passed'] and read(logs/'release-identity.json')['passed']
total=0
for name in ['itype-native','clang-itype','development-itype','installed-itype']:
 d=read(logs/(name+'.json'));assert d['source_sha256']==sha(root/'Perf/itype-module.c') and d['reference_sha256']==sha(root/'Perf/itype-reference.c')
 assert all(x['status']==0 and x['memcheck'] for x in d['cases']);total+=sum(x['checks'] for x in d['cases'])
assert total==28588032
for name in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:assert read(w/('test-'+name+'.json'))['passed']
assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
assert Path('/usr/local/psh/current').resolve()==Path(old['prefix'])
subprocess.run(['sudo','-n','python3','Packaging/install.py','activate'],check=True)
assert manifest(Path(old['prefix']))==old['manifest']
assert sha(Path('/etc/shells'))==old['etc_shells_sha256']
assert pwd.getpwuid(os.getuid()).pw_shell==old['login_shell']
stable=read(w/'stable-before.json');assert stable_snapshot()==stable
assert Path('/usr/local/psh/current').resolve()==Path(b['prefix'])
assert Path('/usr/local/bin/psh').resolve()==Path(b['prefix'])/'bin/psh'
a=dict(passed=True,active_prefix=b['prefix'],shell_sha256=sha(Path('/usr/local/bin/psh')),previous_prefix=old['prefix'],previous_release_entries_unchanged=len(old['manifest']),stable_zsh_startup_entries_unchanged=len(stable),etc_shells_unchanged=True,login_shell_unchanged=True)
(logs/'activation.json').write_text(json.dumps(a,indent=2)+'\n');print(json.dumps(a,indent=2))
