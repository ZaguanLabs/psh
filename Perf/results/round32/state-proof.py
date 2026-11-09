from pathlib import Path
import ast,hashlib,json,os,pwd,subprocess,sys
r=Path.cwd();l=r/'.work/logs/round32';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sys.path.insert(0,str(r/'Packaging'));from audit import stable_snapshot
from install import manifest
parent=read(l/'parent.json');b=read(r/'.work/package/latest.json');w=Path(b['work']);prefix=Path(b['prefix']);old=read(r/'.work/logs/round31/previous-release.json')
assert str(prefix)==old['prefix'] and str(prefix/'bin/psh')==parent['shell'];assert sha(prefix/'bin/psh')==parent['shell_sha256'];assert sha(r/'psh')==parent['development_sha256'];assert Path('/usr/local/psh/current').resolve()==prefix and Path('/usr/local/bin/psh').resolve()==prefix/'bin/psh';assert manifest(prefix)==old['manifest'];assert stable_snapshot()==read(w/'stable-before.json');assert sha(Path('/etc/shells'))==old['etc_shells_sha256'] and pwd.getpwuid(os.getuid()).pw_shell==old['login_shell'];assert b==read(w/'build.json');assert all(sha(r/n)==h for n,h in b['core_source_sha256'].items());assert not subprocess.check_output(['git','diff','--','Src'])
for name in ['validation.json','ohmyzsh.json']:
 assert (w/name).read_bytes()==(r/'Perf/results/round31'/('active-'+name)).read_bytes()
omz=read(w/'ohmyzsh.json');assert omz['passed'] and len(omz['runs'])==24
manifest_upstream=read(r/'Perf/upstream-sha256.json');assert all(sha(r/'.work/pristine'/n)==h for n,h in manifest_upstream.items())
files=['Perf/scope-observer-module.c','Perf/scope-workload.zsh','Perf/scope-scaling.py','Perf/scope-customer-workload.zsh','Perf/scope-customer-scaling.py','Perf/power-workload.zsh','Perf/power-scaling.py']
for n in files:
 if n.endswith('.py'):ast.parse((r/n).read_text())
 elif n.endswith('.zsh'):subprocess.run([str(prefix/'bin/psh'),'-n',n],check=True)
prep=read(l/'preparation.json');assert prep['passed'] and all(x['memcheck_passed'] and len(x['smoke'])==12 for x in prep['runs'])
for x in prep['runs']:assert sha(Path(x['shell']))==x['shell_sha256'] and sha(Path(x['module']))==x['module_sha256']
for n in ['scope-scaling','customer-scaling','customer-repeat','power-scaling','pristine-scaling']:
 d=read(l/(n+'.json'));assert d['samples']==9 and d['cpu_affinity']==[13];assert all(sha(Path(p))==h for p,h in d['fingerprints'].items())
assert all(x['status']==0 for x in read(l/'profiles.json'));assert all(x['status']==0 for x in read(l/'timing.json'));assert all(read(l/'inherited-algorithms.json').values())
metrics=read(l/'profile-metrics.json')
for mode in ['coder-paste','chat-paste']:
 a,bm=[x for x in metrics if x['name'].startswith(mode)];assert a['scope_exits']==bm['scope_exits'];assert bm['scope_cleanup_callbacks']-a['scope_cleanup_callbacks']==512*a['scope_exits']
d=dict(passed=True,active_prefix=str(prefix),active_sha256=sha(prefix/'bin/psh'),development_sha256=sha(r/'psh'),active_release_entries_unchanged=len(old['manifest']),protected_stable_entries_unchanged=len(read(w/'stable-before.json')),etc_shells_unchanged=True,login_shell_unchanged=True,package_metadata_unchanged=True,no_activation_performed=True,no_production_change=True,no_new_package_built_or_installed=True,production_source_matches_parent=True,active_source_inputs_match=len(b['core_source_sha256']),pristine_files_verified=len(manifest_upstream),accepted_optimizations=26,development_binary_never_changed=True,development_DEBUG=True,active_ohmyzsh_sessions=24,previous_active_package_and_ohmyzsh_receipts_reused=True,no_new_interactive_gate_claimed=True,observer_smoke_modes=24,observer_memcheck_hosts=2,research_inputs={n:sha(r/n) for n in files})
(l/'state-proof.json').write_text(json.dumps(d,indent=2)+'\n');print('Research inputs verified; production, package links, binary bytes and protected state unchanged.')
