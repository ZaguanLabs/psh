from pathlib import Path
import subprocess,tarfile,hashlib,json,shutil
r=Path.cwd();work=r/'.work/round47';project=Path('/home/stig/dev/ai/zaguan/labs/zdraw');commit='3ab773ca8ecd24c541ca9fc2fdbe739abff5a3f8'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=r/'Vendor/sources.json';old=json.loads(manifest.read_text());(work/'sources-before.json').write_bytes(manifest.read_bytes())
for name,entry in old.items():
 for file,digest in entry['files'].items():assert sha(r/'Vendor'/name/file)==digest,(name,file)
with (work/'zdraw-v0.1.4.tar').open('wb') as out:subprocess.run(['git','-C',str(project),'archive','--format=tar',commit],stdout=out,check=True)
upstream=work/'upstream';upstream.mkdir()
with tarfile.open(work/'zdraw-v0.1.4.tar') as archive:archive.extractall(upstream,filter='data')
newfiles={str(p.relative_to(upstream)):sha(p) for p in sorted(upstream.rglob('*')) if p.is_file()}
assert len(newfiles)==450
assert (upstream/'VERSION').read_text().strip()=='0.1.4'
# Keep the exact preceding bundle for comparisons; do not include its build cache.
base=work/'baseline-zdraw'
for file in old['zdraw']['files']:
 target=base/file;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/'Vendor/zdraw'/file,target)
for file in old['zdraw']['files'].keys()-newfiles.keys():(r/'Vendor/zdraw'/file).unlink()
for file in newfiles:
 target=r/'Vendor/zdraw'/file;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(upstream/file,target)
source=r/'Vendor/zdraw/Src/Modules/zdraw.c';text=source.read_text();before=sha(source)
needle='setup_(UNUSED(Module m))\n{\n'
assert text.count(needle)==1
text=text.replace(needle,needle+'#ifdef PSH_SCOPE_INDEX_VERSION\n    psh_scope_module_ack(m);\n#endif\n');source.write_text(text)
entry=dict(origin=old['zdraw']['origin'],commit=commit,tag='v0.1.4',files={file:sha(r/'Vendor/zdraw'/file) for file in newfiles},psh_patches=[dict(name='scope-index-awareness',file='Src/Modules/zdraw.c',upstream_sha256=before,patched_sha256=sha(source),description='Conditional psh scope-tracking acknowledgment; module makes no direct parameter-level promotions.')])
updated=dict(old);updated['zdraw']=entry;manifest.write_text(json.dumps(updated,indent=2)+'\n')
report=dict(tag='v0.1.4',tag_object='d549e76c75451175142dca251b5898c2dd58dd97',commit=commit,previous_commit=old['zdraw']['commit'],archive_sha256=sha(work/'zdraw-v0.1.4.tar'),files=len(newfiles),upstream_file_sha256=newfiles,local_patch=entry['psh_patches'][0],unchanged_other_vendors=all(updated[n]==old[n] for n in old if n!='zdraw'))
(work/'import.json').write_text(json.dumps(report,indent=2)+'\n')
print('Imported',len(newfiles),'files from v0.1.4; only the existing scope acknowledgment differs from upstream')
