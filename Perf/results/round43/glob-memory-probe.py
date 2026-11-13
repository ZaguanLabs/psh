from pathlib import Path
import subprocess,tempfile,json,hashlib,resource
root=Path.cwd();out=root/'.work/round43';rows=[]
hosts={'accepted':Path('/usr/local/psh/releases/1.0.0-rc1-6db51a2527d4/bin/psh'),'upstream':root/'.work/hash-report-upstream/Src/zsh'}
with tempfile.TemporaryDirectory(prefix='psh-glob-memory-') as tmp:
 p=Path(tmp);files=p/'files';files.mkdir()
 last=0
 for count in (100,1000,10000):
  for i in range(last,count):(files/f'f{i:05d}').touch()
  last=count
  for width in (1,1024):
   code="emulate -R zsh; cd -- \"$1\" || exit 2; a=(*(e^': "+'x'*width+"'^)); print -rl -- \"${a[@]}\""
   for label,shell in hosts.items():
    path=p/'rss'
    cmd=['/usr/bin/time','-f','%M','-o',str(path),str(shell),'-dfc',code,'glob-memory',str(files)]
    r=subprocess.run(cmd,capture_output=True,env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},timeout=120)
    expected=''.join(f'f{i:05d}\n' for i in range(count)).encode()
    assert r.returncode==0 and not r.stderr and r.stdout==expected,(label,count,width,r.stderr)
    row=dict(host=label,shell=str(shell),binary_sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),count=count,qualifier_literal_bytes=width,max_rss_kib=int(path.read_text()),output_sha256=hashlib.sha256(r.stdout).hexdigest(),code_sha256=hashlib.sha256(code.encode()).hexdigest())
    rows.append(row);print(row,flush=True)
(out/'glob-memory-probe.json').write_text(json.dumps({'scope':'peak RSS only, not timing; different compiler/core builds, screening comparison only','runs':rows},indent=2)+'\n')
