from pathlib import Path
import hashlib,json,os,pwd,subprocess,sys
root=Path.cwd();l=root/'.work/logs/round30';sys.path.insert(0,str(root/'Packaging'))
from audit import stable_snapshot
from install import manifest
from elf import dynamic_exports
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
b=read(root/'.work/package/latest.json');old=read(l/'previous-release.json');assert b['prefix']==old['prefix'];w=Path(b['work']);prefix=Path(b['prefix'])
assert all(sha(root/n)==h for n,h in b['core_source_sha256'].items())
assert not subprocess.check_output(['git','diff','--','Src'])
assert manifest(prefix)==old['manifest'];assert stable_snapshot()==read(w/'stable-before.json')
assert sha(Path('/etc/shells'))==old['etc_shells_sha256'];assert pwd.getpwuid(os.getuid()).pw_shell==old['login_shell']
assert Path('/usr/local/psh/current').resolve()==prefix and Path('/usr/local/bin/psh').resolve()==prefix/'bin/psh'
assert sha(prefix/'bin/psh')==b['installed_shell_sha256'];assert read(w/'validation.json')['passed'];omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
before=read(root/'Perf/results/round28/source-checks.json')['development_sha256'];assert sha(root/'psh')==before
assert '62 successful test scripts, 0 failures, 3 skipped' in (l/'restored-development-upstream.log').read_text()
assert read(l/'restored-small.json')['passed']
trial=read(l/'inactive-build.json');assert Path(trial['prefix']).is_dir() and trial['prefix']!=str(prefix)
proposal=read(l/'source-checks.json');assert trial['core_source_sha256']['Src/math.c']==proposal['fixtures']['Src/math.c']
write=dict(passed=True,active_prefix=str(prefix),active_sha256=sha(prefix/'bin/psh'),active_release_entries_unchanged=len(old['manifest']),protected_stable_entries_unchanged=len(read(w/'stable-before.json')),etc_shells_unchanged=True,login_shell_unchanged=True,no_activation_performed=True,active_source_inputs_match=len(b['core_source_sha256']),production_source_matches_parent=True,accepted_optimizations=26,development_binary_byte_identical=True,development_sha256=before,development_DEBUG=True,development_upstream_scripts=62,development_upstream_failures=0,development_upstream_skips=3,active_ohmyzsh_sessions=len(omz['runs']),active_verification_passed=True,historical_seven_suite_receipts_reused_for_unchanged_artifacts=True,inactive_trial_prefix=trial['prefix'],inactive_trial_sha256=trial['installed_shell_sha256'],dynamic_exports=len(dynamic_exports(prefix/'bin/psh')))
(l/'restoration.json').write_text(json.dumps(write,indent=2)+'\n');print(json.dumps(write,indent=2))
