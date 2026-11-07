from pathlib import Path
import hashlib,json,pwd,re,subprocess,sys
root=Path.cwd();logs=root/'.work/logs/round18';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sys.path.insert(0,str(root/'Packaging'));from audit import stable_snapshot
from install import manifest
before=json.loads((logs/'protected-before.json').read_text());prefix=Path(before['prefix'])
assert Path('/usr/local/psh/current').resolve()==prefix
assert sha(prefix/'psh-install.json')==before['record_sha256']
assert sha('/etc/shells')==before['etc_shells_sha256']
assert manifest(prefix)==json.loads((prefix/'psh-install.json').read_text())['files']
assert stable_snapshot()==json.loads((logs/'stable-before.json').read_text())
pristine=json.loads((root/'Perf/upstream-sha256.json').read_text())
assert all(sha(root/'.work/pristine'/p)==h for p,h in pristine.items())
build=json.loads((root/'.work/package/latest.json').read_text())
assert build['prefix']==str(prefix)
assert all(sha(root/p)==h for p,h in build['core_source_sha256'].items())
previous=json.loads((root/'.work/round17/sha256.json').read_text())
assert all(sha(root/'.work/round17'/p)==h for p,h in previous.items())
assert sha(root/'psh')==sha(root/'.work/candidate/Src/zsh')==previous['psh']
exports=lambda p:sorted(' '.join(line.split()[1:]) for line in subprocess.check_output(['nm','-D','--defined-only',str(p)],text=True).splitlines())
a=exports(root/'.work/baseline/Src/zsh');assert a==exports(root/'psh')
for variant in ['filter-hoist','wrapper']:assert a==exports(root/'.work'/('round18-'+variant)/'psh')
public={}
for file in ['exec','glob','params','utils','pattern','subst','hashtable']:
 first=root/'.work/baseline/Src'/(file+'.epro');second=root/'.work/candidate/Src'/(file+'.epro')
 assert first.read_bytes()==second.read_bytes();public[file+'.epro']=sha(first)
receipt=json.loads((logs/'validation-receipt.json').read_text());assert not receipt['failures']
api={}
for name in ['filter-hoist-api','wrapper-api','installed-api','no-mb-api']:
 r=json.loads((logs/(name+'.json')).read_text());assert all(c['status']==0 and c['memcheck'] for c in r['cases'])
 files=list(logs.glob(name+'-*.memcheck.log'));assert len(files)==4
 assert all('ERROR SUMMARY: 0 errors from 0 contexts' in p.read_text() for p in files)
 api[name]=sum(c['checks'] for c in r['cases'])
profiles=json.loads((logs/'accepted-profile-commands.json').read_text());combined=[]
for row in profiles:
 p=logs/('accepted-'+row['name']+'-'+row['which']+'.flat.txt')
 n=sum(int(line.split()[0].replace(',','')) for line in p.read_text().splitlines() if re.search(r'hashtable.c:scan(?:match|hash)table(?:\s|\x27)',line))
 combined.append({'kernel':row['name'],'variant':row['which'],'total_instructions':row['instructions'],'combined_scan_self_instructions':n})
record={'adopted':False,'parent':'b9cd392','production_core_inputs_unchanged':True,'pristine_files_verified':len(pristine),'previous_snapshot_verified':True,'dynamic_exported_names_types':len(a),'public_declarations':public,'active_prefix':str(prefix),'installed_sha256':sha(prefix/'bin/psh'),'development_sha256':sha(root/'psh'),'stable_protected_entries':len(stable_snapshot()),'stable_unchanged':True,'installed_manifest_unchanged':True,'etc_shells_unchanged':True,'login_shell':pwd.getpwuid(__import__('os').getuid()).pw_shell,'native_checks':api,'total_native_checks':sum(api.values()),'profiles':combined,'fixture_sha256':sha(root/'Perf/hash-scan-module.c'),'driver_sha256':sha(root/'Perf/check-hash-scan-module.py'),'regression_sha256':sha(root/'Perf/hash-scope.ztst')}
# The actual login-shell value stays private; the existing package verifier
# separately checked it against its original snapshot.
record.pop('login_shell')
(logs/'proof.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
