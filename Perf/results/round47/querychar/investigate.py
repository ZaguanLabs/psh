from pathlib import Path
import importlib.util,subprocess,json,hashlib
root=Path.cwd();out=root/'.work/round47/querychar';driver=root/'Vendor/zdraw/benchmarks/native.py'
spec=importlib.util.spec_from_file_location('native',driver);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
(out/'pristine/zsh').mkdir(parents=True,exist_ok=True);(out/'pristine/zsh/curses.so').symlink_to(root/'.work/public-rc0/reference/Src/Modules/curses.so')
cases=[('pristine',root/'.work/public-rc0/reference/Src/zsh',out/'pristine','zcurses'),('previous',Path('/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/bin/psh'),Path('/usr/local/psh/releases/1.0.0-rc1-126770ba80d2/lib/psh/5.9.2'),'zcurses'),('candidate-stock',Path('/usr/local/psh/releases/1.0.0-rc1-ec96430ae35f/bin/psh'),Path('/usr/local/psh/releases/1.0.0-rc1-ec96430ae35f/lib/psh/5.9.2'),'zcurses'),('candidate-zdraw',Path('/usr/local/psh/releases/1.0.0-rc1-ec96430ae35f/bin/psh'),Path('/usr/local/psh/releases/1.0.0-rc1-ec96430ae35f/lib/psh/5.9.2'),'zdraw')]
rows=[]
for name,shell,modules,backend in cases:
 result=m.trial(shell,modules,backend,1,fixture=out/'minimal.zsh',capture=out/name)
 report=(out/(name+'.report')).read_bytes();rows.append(dict(host=name,shell=str(shell),shell_sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),report_hex=report.hex(),result=result));print(name,repr(report),flush=True)
(out/'minimal.json').write_text(json.dumps(rows,indent=2)+'\n')
# Give Memcheck an exact object boundary for the original single-wchar capacity.
source=(root/'.work/pristine/Src/Modules/curses.c').read_text();start=source.index('static int\nzccmd_querychar(');end=source.index('\nstatic int\nzccmd_touch',start);body=source[start:end]
assert body.count('wchar_t c;')==1
body=body.replace('wchar_t c;','wchar_t *c = malloc(sizeof(wchar_t));').replace('getcchar(&cc, &c,','getcchar(&cc, c,').replace('wctomb(instr, c);','wctomb(instr, c[0]);\n    free(c);')
source=source[:start]+body+source[end:];file=out/'single-wchar-diagnostic.c';file.write_text(source)
modules=out/'diagnostic';(modules/'zsh').mkdir(parents=True)
cmd=['gcc','-O2','-g','-fPIC','-shared','-DMODULE','-DHAVE_CONFIG_H','-I'+str(root/'.work/public-rc0/reference/Src/Modules'),'-I'+str(root/'.work/public-rc0/reference/Src'),'-I'+str(root/'.work/pristine/Src'),str(file),'-o',str(modules/'zsh/curses.so'),'-lncursesw','-ltinfo'];subprocess.run(cmd,check=True)
try:
 m.trial(cases[0][1],modules,'zcurses',1,fixture=out/'minimal.zsh',prefix=('valgrind','--quiet','--track-origins=yes','--error-exitcode=97','--log-file='+str(out/'diagnostic-memcheck.log')))
except RuntimeError as error:
 (out/'diagnostic-error.txt').write_text(str(error));print('Diagnostic memory check failed as expected',flush=True)
else:raise RuntimeError('Expected memory error not detected')
(out/'diagnostic.json').write_text(json.dumps(dict(command=cmd,scope='original querychar single-wchar capacity moved to an exact heap allocation solely to expose its object boundary to Memcheck; not an unchanged-stock Valgrind run',source_sha256=hashlib.sha256(file.read_bytes()).hexdigest()),indent=2)+'\n')
