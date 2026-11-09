from pathlib import Path
import json,time
r=Path.cwd();l=r/'.work/logs/round34';read=lambda p:json.loads(p.read_text());write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
b=read(r/'.work/package/latest.json');w=Path(b['work'])
for name in ['validation','native-validation','source-checks','identity','release-identity']:assert read(l/(name+'.json'))['passed'],name
assert all(x['status']==0 for x in read(l/'additional-builds.json'));assert all(x['status']==0 for x in read(l/'pre-pilot-validation.json'));assert all(x['status']==0 for x in read(l/'package-finalization.json'))
for n in ['core','zdraw','zmdown','zcurl','zjson','zhtml2md','zoup']:assert read(w/('test-'+n+'.json'))['passed'],n
assert read(w/'validation.json')['passed'];assert read(w/'ohmyzsh.json')['passed'] and len(read(w/'ohmyzsh.json')['runs'])==24
assert Path('/usr/local/psh/current').resolve()==Path(read(l/'previous-release.json')['prefix'])
def cpu():
 return {int(row.split()[0][3:]):list(map(int,row.split()[1:])) for row in Path('/proc/stat').read_text().splitlines() if row.startswith(('cpu13 ','cpu29 '))}
before=cpu();time.sleep(1);after=cpu();rows=[]
for n in before:
 delta=[v-u for u,v in zip(before[n],after[n])];total=sum(delta[:8]);rows.append(dict(cpu=n,busy_percent=100*(total-delta[3]-delta[4])/total,delta=delta))
write(l/'activity-before.json',dict(observation_seconds=1,scope='aggregate CPU observation before timing; no continuous external-activity audit',cpus=rows))
write(l/'timing-preconditions.json',dict(passed=True,all_own_builds_tests_and_profiles_complete=True,package_suites=7,ohmyzsh_sessions=24,native_checks=read(l/'native-validation.json')['checks'],exact_installed_hosts=True,observer_modules_prebuilt=True))
print('All verification phases complete; exact installed timing can start.')
