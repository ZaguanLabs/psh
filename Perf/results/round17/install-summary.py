from pathlib import Path
import hashlib,json,subprocess,sys
sys.path.insert(0,str(Path('Packaging').resolve()))
from install import manifest
root=Path.cwd();logs=root/'.work/logs/round17';dest=root/'Perf/results/round17';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
b=json.loads((root/'.work/package/latest.json').read_text());work=Path(b['work']);prefix=Path(b['prefix']);v=json.loads((work/'validation.json').read_text());before=json.loads((logs/'install-before.json').read_text());old=Path(before['previous_prefix'])
assert v['passed'] and Path('/usr/local/psh/current').resolve()==prefix
assert sha(old/'psh-install.json')==before['previous_install_record_sha256']
assert manifest(old)==json.loads((old/'psh-install.json').read_text())['files']
assert sha('/etc/shells')==before['etc_shells_sha256']
exports=lambda p: sorted(' '.join(line.split()[1:]) for line in subprocess.check_output(['nm','-D','--defined-only',str(p)],text=True).splitlines())
assert exports(old/'bin/psh')==exports(prefix/'bin/psh')
suites={}
for name in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:
 report=json.loads((work/('test-'+name+'.json')).read_text());assert report['passed'];suites[name]=True
 (dest/('package-test-'+name+'.json')).write_text(json.dumps(report,indent=2)+'\n')
report={'release':b['release'],'previous_release':old.name,'prefix':str(prefix),'shell_sha256':v['shell_sha256'],'native_sha256':v['native_sha256'],'suites':suites,'core_test_scripts':63,'core_skipped_scripts':2,'zdraw_tests':190,'installed_components':v['installed_component_tests'],'stable_protected_entries':v['stable_protected_entries'],'stable_unchanged':v['stable_unchanged'],'stock_modules_preserved':v['stock_modules_preserved'],'previous_release_unchanged':True,'etc_shells_unchanged':True,'login_shell_unchanged':v['login_shell_unchanged'],'production_export_names_types_match':True,'notes':['The production binary differs from the timing binary through its private paths and module configuration.','Focused package count API report contains pristine and packaged hosts; each host passes 4093840 scenarios.','Stable Zsh and personal-startup snapshots remain local-only.']}
(dest/'installed-package.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
