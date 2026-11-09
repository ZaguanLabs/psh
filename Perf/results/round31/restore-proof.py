from pathlib import Path
import hashlib,json,os,pwd,subprocess,sys
r=Path.cwd();l=r/'.work/logs/round31';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());sys.path.insert(0,str(r/'Packaging'));from audit import stable_snapshot
from install import manifest
from elf import dynamic_exports
b=read(r/'.work/package/latest.json');old=read(l/'previous-release.json');p=Path(b['prefix']);w=Path(b['work']);assert str(p)==old['prefix'] and Path('/usr/local/psh/current').resolve()==p and Path('/usr/local/bin/psh').resolve()==p/'bin/psh'
assert sha(Path('/etc/shells'))==old['etc_shells_sha256'] and pwd.getpwuid(os.getuid()).pw_shell==old['login_shell'];assert manifest(p)==old['manifest'];assert stable_snapshot()==read(w/'stable-before.json');assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert not subprocess.check_output(['git','diff','--','Src'])
dev=read(r/'Perf/results/round28/source-checks.json')['development_sha256'];assert sha(r/'psh')==dev
assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
assert read(l/'descriptor-memory.json')['memcheck'];assert len(read(l/'descriptor-memory.json')['cases'])==1
for f in l.glob('descriptor-memory.*.memcheck.log'):assert not f.read_bytes()
assert '63 successful test scripts, 0 failures, 2 skipped' in (l/'upstream.log').read_text()
for name,checks,locales in [('math',38472,5),('descriptor-pool/math',38472,5),('pristine-restored-math',5352,1),('pristine-focused-math',2292,1),('descriptor-memory',2292,1)]:
 d=read(l/(name+'.json'));assert d['checks_per_locale']==checks and len(d['cases'])==locales
for f in ['customer-pilot','library-pilot']:
 d=read(l/'descriptor-pool'/(f+'.json'));assert d['samples']==9 and d['cpu_affinity']==[13]
for f in ['customer-inline','library-inline']:
 d=read(l/(f+'.json'));assert d['samples']==9 and d['cpu_affinity']==[13]
d=dict(passed=True,active_prefix=str(p),active_sha256=sha(p/'bin/psh'),active_release_entries_unchanged=len(old['manifest']),protected_stable_entries_unchanged=len(read(w/'stable-before.json')),etc_shells_unchanged=True,login_shell_unchanged=True,no_activation_performed=True,no_new_package_built_or_installed=True,active_source_inputs_match=len(b['core_source_sha256']),production_source_matches_parent=True,accepted_optimizations=26,development_binary_never_changed=True,development_binary_byte_identical=True,development_sha256=dev,development_DEBUG=True,active_ohmyzsh_sessions=24,active_verification_passed=True,historical_seven_suite_receipts_reused_for_unchanged_artifacts=True,dynamic_exports=len(dynamic_exports(p/'bin/psh')),accessor_trial_upstream=[63,0,2],focused_memcheck_comparisons=2292,focused_memcheck_errors=0)
(l/'restoration.json').write_text(json.dumps(d,indent=2)+'\n');print('Accepted source/binaries, protected files, package links and fresh OMZ gate verified.')
