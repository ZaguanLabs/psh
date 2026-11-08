from pathlib import Path
import contextlib,hashlib,importlib.util,json,os,sys,tempfile,time
root=Path.cwd(); logs=root/'.work/logs/rc0-release-profile'; sys.path.insert(0,str(root/'Vendor/zcurl/tests'))
import integration
prefixes=[Path('/usr/local/psh/releases/1.0.0-rc0-13aa87c312a1'),Path('/usr/local/psh/releases/1.0.0-rc0-1d099d21957d')]
rows=[]
for n in range(3):
 for prefix in prefixes if n%2==0 else reversed(prefixes):
  with tempfile.TemporaryDirectory(prefix='psh-zcurl-control-') as temporary:
   shim=Path(temporary); (shim/'zsh').symlink_to(prefix/'bin/psh')
   started=time.monotonic();log=logs/f'zcurl-signals-{n}-{prefix.name}.log'; error=None
   with log.open('w') as out,contextlib.redirect_stdout(out),contextlib.redirect_stderr(out):
    try:
     with integration.fixture(prefix/'lib/psh/5.9.2') as (env,plain,tls,fixture):
      env.update(PATH=str(shim)+':/usr/bin:/bin',LC_ALL='C.UTF-8');env.pop('FPATH',None)
      integration.interrupt_test(env,plain)
    except Exception as e:
     error=repr(e);print(error,flush=True)
   row=dict(release=prefix.name,round=n,status=0 if error is None else 1,seconds=round(time.monotonic()-started,3),shell_sha256=hashlib.sha256((prefix/'bin/psh').read_bytes()).hexdigest(),module_sha256=hashlib.sha256((prefix/'lib/psh/5.9.2/zcurl.so').read_bytes()).hexdigest(),log=str(log),error=error)
   rows.append(row);print(prefix.name,n,row['status'],flush=True)
   (logs/'zcurl-signals.json').write_text(json.dumps(dict(passed=all(r['status']==0 for r in rows),runs=rows,fixture_sha256=hashlib.sha256((root/'Vendor/zcurl/tests/integration.py').read_bytes()).hexdigest()),indent=2)+'\n')
assert all(r['status']==0 for r in rows)
