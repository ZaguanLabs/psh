from pathlib import Path
import hashlib
import json
import shutil
import subprocess

root = Path.cwd()
logs = root / '.work/logs/round36'
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
proof = read(logs / 'restoration.json')
assert proof['passed'] and proof['no_installation_or_activation_performed']
assert build == read(logs / 'previous-package.json')
assert Path('/usr/local/psh/current').resolve() == Path(build['prefix'])
assert sha(Path('/usr/local/bin/psh')) == proof['active_sha256']
assert sha(root / 'psh') == proof['development_sha256']
assert all(sha(root / n) == h for n, h in build['core_source_sha256'].items())
archive = root / 'Perf/results/round36'
assert all(sha(archive / n) == h for n, h in read(archive / 'sha256.json').items())
status_path = root / '.work/rc0/release-status.json'
backup = status_path.with_name('pre-round36-release-status.json')
assert not backup.exists()
shutil.copy2(status_path, backup)
status = read(status_path)
assert status['binary_source_commit'] == '22bc13984a8b1d7fa791732737678e100e59e73b'
assert status['current_optimization_count'] == 27
assert status['current_optimization_report'] == 'Perf/round35.md'
status.update(
    source_commit=head, source_validation='Perf/results/round36/restoration.json',
    previous_checkpoint_status=str(backup.relative_to(root)),
    source_validation_kind='Production inputs and developer ELF unchanged; no new package or source archive published',
    latest_investigation_report='Perf/round36.md',
    latest_investigation_status='Option-default loop-fusion proposals rejected at private pilot; active release unchanged',
    github_final_receipt='.work/logs/round36/github-final.json',
)
status['development_build'] = dict(
    report='Perf/results/round36/restoration.json', DEBUG=True,
    shell_sha256=proof['development_sha256'])
status_path.write_text(json.dumps(status, indent=2) + '\n')
print('Checkpoint complete:', head)
print('Daily driver unchanged:', build['release'])
print('Private repository; original rc0 tag/draft/seven assets unchanged; clean worktree.')
