from pathlib import Path
import hashlib,json,os,pwd,subprocess,sys
root=Path.cwd();logs=root/'.work/logs/round27';sys.path.insert(0,str(root/'Packaging'))
from audit import stable_snapshot
from install import manifest
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
b=read(root/'.work/package/latest.json');assert b['release']=='1.0.0-rc0-e84bb6129d9e';w=Path(b['work']);old=read(logs/'previous-release.json')
for name in ['validation','source-checks','release-identity']:assert read(logs/(name+'.json'))['passed']
total=0
for name in ['emulation-native','clang-emulation','development-emulation','installed-emulation']:
 d=read(logs/(name+'.json'));assert d['passed']
 for p in [root/'Perf/emulation-module.c']:assert d['fingerprints'][str(p)]==sha(p)
 assert all(x['status']==0 and x['memcheck'] for x in d['runs']);total+=d['checks']
assert total==567220
for name in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:assert read(w/('test-'+name+'.json'))['passed']
assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
assert Path('/usr/local/psh/current').resolve()==Path(old['prefix'])
subprocess.run(['sudo','-n','python3','Packaging/install.py','activate'],check=True)
assert manifest(Path(old['prefix']))==old['manifest']
assert sha(Path('/etc/shells'))==old['etc_shells_sha256'] and pwd.getpwuid(os.getuid()).pw_shell==old['login_shell']
stable=read(w/'stable-before.json');assert stable_snapshot()==stable
assert Path('/usr/local/psh/current').resolve()==Path(b['prefix']) and Path('/usr/local/bin/psh').resolve()==Path(b['prefix'])/'bin/psh'
a=dict(passed=True,active_prefix=b['prefix'],shell_sha256=sha(Path('/usr/local/bin/psh')),previous_prefix=old['prefix'],previous_release_entries_unchanged=len(old['manifest']),stable_zsh_startup_entries_unchanged=len(stable),etc_shells_unchanged=True,login_shell_unchanged=True)
(logs/'activation.json').write_text(json.dumps(a,indent=2)+'\n');print(json.dumps(a,indent=2))
