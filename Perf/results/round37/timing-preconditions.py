from pathlib import Path
import json
import time

root = Path.cwd()
logs = root / '.work/logs/round37'
read = lambda p: json.loads(p.read_text())
build = read(root / '.work/package/latest.json')
work = Path(build['work'])
assert read(logs / 'validation.json')['passed']
assert read(logs / 'source-checks.json')['passed']
assert read(logs / 'code-identity.json')['passed']
assert read(logs / 'installed-code-identity.json')['passed']
assert all(row['status'] == 0 for row in read(logs / 'paired-upstream.json'))
assert all(row['status'] == 0 for row in read(logs / 'package-validation.json'))
assert read(logs / 'development-runtime-isolation.json')['passed']
for name in ['clang-paired-state', 'paired-state-memcheck',
             'installed-state-memcheck', 'development-state-memcheck']:
    report = read(logs / (name + '.json'))
    assert report['memcheck'] and len(report['cases']) == 2
    assert sum(row['checks'] for row in report['cases']) == 1296
    assert all(row['status'] == 0 for row in report['cases'])
    files = list(logs.glob(name + '.*.memcheck.log'))
    assert len(files) == 4 and all(not p.read_bytes().strip() for p in files)
for name in ['pristine-debug', 'development']:
    assert '62 successful test scripts, 0 failures, 3 skipped' in (logs / (name + '-upstream.log')).read_text()
for name in ['core', 'zdraw', 'zjson', 'zcurl', 'zmdown', 'zhtml2md', 'zoup']:
    assert read(work / ('test-' + name + '.json'))['passed']
assert read(work / 'validation.json')['passed']
assert read(work / 'ohmyzsh.json')['passed'] and len(read(work / 'ohmyzsh.json')['runs']) == 24
assert len(read(logs / 'installed-profiles.json')) == 8
assert Path('/usr/local/psh/current').resolve() == Path(read(logs / 'previous-package.json')['prefix'])
def cpus():
    return {line.split()[0]: list(map(int, line.split()[1:]))
            for line in Path('/proc/stat').read_text().splitlines()
            if line.startswith(('cpu13 ', 'cpu29 '))}
before = cpus()
time.sleep(1)
after = cpus()
observation = {cpu: [b - a for a, b in zip(before[cpu], after[cpu])] for cpu in before}
(logs / 'activity-before.json').write_text(json.dumps(dict(
    observation_seconds=1, deltas=observation,
    scope='Brief observation before timing; external activity is not continuously audited'), indent=2) + '\n')
(logs / 'timing-preconditions.json').write_text(json.dumps(dict(
    passed=True, own_builds_tests_and_profiles_complete=True, exact_installed_hosts=True,
    package_suites=7, ohmyzsh_sessions=24, native_state_memcheck_runs=16,
    differential_state_comparisons=5184), indent=2) + '\n')
print('All required checks complete; installed timing can begin.')
