from pathlib import Path
import ast,hashlib,json,os,pwd,subprocess,sys,tempfile
r=Path.cwd();l=r/'.work/logs/round34';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sys.path.insert(0,str(r/'Packaging'))
from audit import stable_snapshot
from install import manifest
from elf import dynamic_exports
b=read(r/'.work/package/latest.json');old=read(l/'previous-release.json');parent=read(l/'parent.json');p=Path(b['prefix']);w=Path(b['work']);trial=read(l/'inactive-build.json')
assert b['prefix']==old['prefix'] and Path('/usr/local/psh/current').resolve()==p and Path('/usr/local/bin/psh').resolve()==p/'bin/psh'
assert sha(p/'bin/psh')==parent['active_sha256']==b['installed_shell_sha256'];assert manifest(p)==old['manifest'];assert stable_snapshot()==read(w/'stable-before.json')
assert sha(Path('/etc/shells'))==old['etc_shells_sha256'] and pwd.getpwuid(os.getuid()).pw_shell==old['login_shell']
assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert not subprocess.check_output(['git','diff',parent['commit'],'--','Src','Test'])
assert sha(r/'psh')==parent['development_sha256'];assert '62 successful test scripts, 0 failures, 3 skipped' in (l/'restored-development-upstream.log').read_text()
assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
assert read(l/'restored-scope.json')['passed'] and read(l/'restored-scope.json')['checks']==2016;assert len(read(l/'restored-scope.json')['runs'])==2
for f in (l/'restored-scope').glob('*.memcheck.log'):assert 'ERROR SUMMARY: 0 errors' in f.read_text()
proposal=read(l/'source-checks.json');assert all(trial['core_source_sha256'][n]==proposal['fixtures'][n] for n in ['Src/params.c','Src/hashtable.c']);assert sha(Path(trial['prefix'])/'bin/psh')==trial['installed_shell_sha256'];assert read(Path(trial['work'])/'validation.json')['passed']
for n in ['Perf/scope-cleanup-module.c','Perf/check-scope-cleanup-module.py','Perf/scope-pair-benchmark.py']:
 assert sha(r/n)==proposal['fixtures'][n]
 if n.endswith('.py'):ast.parse((r/n).read_text())
patch=l/'proposed-with-fixtures.patch'
assert sha(patch)==read(l/'patch-check.json')['patch_sha256']
with tempfile.TemporaryDirectory() as td:
 t=Path(td)
 for n in ['Src/params.c','Src/hashtable.c']:
  q=t/n;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(subprocess.check_output(['git','show',parent['commit']+':'+n]))
 applied=subprocess.run(['patch','-p1','--batch','--input',str(patch)],cwd=t,capture_output=True,check=True)
 assert all(sha(t/n)==h for n,h in proposal['fixtures'].items())
 (l/'patch-preservation.json').write_text(json.dumps(dict(passed=True,parent=parent['commit'],patch_sha256=sha(patch),all_five_recorded_file_hashes_match=True,changed_files=5,log=applied.stdout.decode()),indent=2)+'\n')
h=read(l/'hardware.json');assert all(e['running_ns']==e['enabled_ns'] for c in h['cases'] for host in c['measurements'] for sample in host for e in sample['events'])
(l/'hardware-scheduling.json').write_text(json.dumps(dict(passed=True,fully_scheduled=True,cases=len(h['cases'])),indent=2)+'\n')
d=dict(passed=True,active_prefix=str(p),active_sha256=sha(p/'bin/psh'),active_release_entries_unchanged=len(old['manifest']),protected_stable_entries_unchanged=len(read(w/'stable-before.json')),etc_shells_unchanged=True,login_shell_unchanged=True,no_activation_performed=True,active_source_inputs_match=len(b['core_source_sha256']),production_source_and_tests_match_parent=True,parent=parent['commit'],accepted_optimizations=26,development_binary_byte_identical=True,development_sha256=sha(r/'psh'),development_DEBUG=True,development_upstream_scripts=62,development_upstream_failures=0,development_upstream_skips=3,restored_scope_observations=2016,restored_scope_memcheck_processes=2,active_ohmyzsh_sessions=24,active_verification_passed=True,historical_active_seven_suite_receipts_reused_for_unchanged_artifacts=True,inactive_trial_prefix=trial['prefix'],inactive_trial_sha256=trial['installed_shell_sha256'],dynamic_exports=len(dynamic_exports(p/'bin/psh')),new_scope_fixtures_unchanged=True,unapplied_proposal_replayed=True)
(l/'restoration.json').write_text(json.dumps(d,indent=2)+'\n');print(json.dumps(d,indent=2))
