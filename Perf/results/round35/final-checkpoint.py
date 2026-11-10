from pathlib import Path
import hashlib
import json
import shutil
import subprocess

root = Path.cwd()
logs = root / '.work/logs/round35'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
for name, command in [
    ('github-final', ['gh', 'release', 'view', 'v1.0.0-rc0', '--repo',
                      'ZaguanLabs/psh', '--json', 'assets,isDraft,isPrerelease,tagName,url']),
    ('repository-final', ['gh', 'repo', 'view', 'ZaguanLabs/psh', '--json', 'isPrivate']),
]:
    (logs / (name + '.json')).write_bytes(subprocess.check_output(command))
original = read(root / '.work/releases/v1.0.0-rc0/github-receipt.json')
assert read(logs / 'github-final.json') == original
assert original['isDraft'] and len(original['assets']) == 7
assert read(logs / 'repository-final.json')['isPrivate']
remote_text = subprocess.check_output([
    'git', 'ls-remote', 'origin', 'refs/heads/main',
    'refs/tags/v1.0.0-rc0', 'refs/tags/v1.0.0-rc0^{}'], text=True)
(logs / 'remote-final.txt').write_text(remote_text)
remote = dict(line.split()[::-1] for line in remote_text.splitlines())
assert remote['refs/heads/main'] == head
assert remote['refs/tags/v1.0.0-rc0'] == '1e5ff955da1e686c74a7b44e47156ec0fc89e673'
assert remote['refs/tags/v1.0.0-rc0^{}'] == 'f6e94e435a7f657725a66dea69ad3038e2655525'
assert not subprocess.check_output(['git', 'status', '--porcelain'])

build = read(root / '.work/package/latest.json')
assert build['release'] == '1.0.0-rc0-bde30291d0ec'
assert Path('/usr/local/psh/current').resolve() == Path(build['prefix'])
assert sha(Path('/usr/local/bin/psh')) == build['installed_shell_sha256']
assert read(logs / 'activation.json')['passed']
source = read(logs / 'source-checks.json')
assert source['passed'] and source['development_DEBUG']
assert sha(root / 'psh') == source['development_sha256']
assert all(sha(root / n) == h for n, h in build['core_source_sha256'].items())
archive = root / 'Perf/results/round35'
assert all(sha(archive / n) == h for n, h in read(archive / 'sha256.json').items())
work = Path(build['work'])
omz = read(work / 'ohmyzsh.json')
assert len(omz['runs']) == 24

status_path = root / '.work/rc0/release-status.json'
backup = status_path.with_name('pre-round35-release-status.json')
assert not backup.exists()
shutil.copy2(status_path, backup)
status = read(status_path)
status.update(
    source_commit=head, binary_source_commit=head,
    installed_prefix=build['prefix'],
    installed_shell_sha256=build['installed_shell_sha256'],
    source_validation='Perf/results/round35/source-checks.json',
    previous_checkpoint_status=str(backup.relative_to(root)),
    source_validation_kind='Canonical input hashes and complete 41-file patch replay; no new source archive is published',
    current_optimization_report='Perf/round35.md', current_optimization_count=27,
    latest_investigation_report='Perf/round35.md',
    latest_investigation_status='Accepted indexed parameter-scope buckets; isolated release activated',
    github_final_receipt='.work/logs/round35/github-final.json',
)
status['development_build'] = dict(
    report='Perf/results/round35/source-checks.json', DEBUG=True,
    shell_sha256=source['development_sha256'])
status['ohmyzsh_gate'] = dict(
    passed=True, sessions=len(omz['runs']), report=str(work / 'ohmyzsh.json'),
    report_sha256=sha(work / 'ohmyzsh.json'), commit=omz['omz']['commit'],
    highlighter_commit=omz['syntax_highlighting']['commit'],
    theme=omz['theme'], plugins=omz['configured_plugins'])
status_path.write_text(json.dumps(status, indent=2) + '\n')
print('Checkpoint complete:', head)
print('Active:', build['release'])
print('Private repository; original rc0 tag/draft/seven assets unchanged; clean worktree.')
