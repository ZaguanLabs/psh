from pathlib import Path
import gzip,hashlib,json,shutil
root=Path.cwd();l=root/'.work/logs/round31';out=root/'Perf/results/round31';out.mkdir(exist_ok=True);allowed={'.json','.py','.log','.txt','.patch','.c','.asm','.zsh'}
for p in l.rglob('*'):
 if not p.is_file() or p.name=='previous-release.json':continue
 dest=out/p.relative_to(l);dest.parent.mkdir(parents=True,exist_ok=True)
 if p.suffix in allowed:shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
b=json.loads((root/'.work/package/latest.json').read_text());w=Path(b['work'])
for name in ['validation.json','ohmyzsh.json','terminal-profile.json','installed-core-harness.json']:shutil.copy2(w/name,out/('active-'+name))
(out/'README.md').write_text('''# Round 31 evidence: three arithmetic trials rejected

[The report](../../round31.md) describes the prototypes and measured tradeoffs.
`restoration.json` proves current canonical inputs, unchanged development/active
binaries, protected entries and the fresh 24-session interactive OMZ gate. No
new package was built, installed or activated. `active-*` receipts describe the
unchanged accepted release; historical seven-suite results were not newly rerun.

`descriptor-pool/` retains the eight-descriptor prototype, its candidate raw
profiles, four fresh accepted-release profiles, nine-sample customer/library
screening and the original expanded arithmetic driver/receipts. Its ELF survives
locally as `.work/round31/descriptor-pool-zsh`. The initial reference raw profiles
were overwritten when shared paths were reused for the accessor trial. Original
reference counts/hashes survive in its JSON; root reference raw profiles belong
to the later accessor run. They must not be relabeled as the initial raw data.

`inline-parser/` retains the one-word parser hint and identical `math.o` text
section fingerprints. No timing or whole-executable identity is claimed for it.
Root `source.patch`, `math-code.json`, matched profiles, `math.json`, `upstream.log`
and `customer-inline`/`library-inline` receipts describe the accessor inline hint.
The separate ELF survives as `.work/round31/inline-accessor-zsh`. Source patches
replay against the recorded parent; the root source is now restored. Work paths
in historical commands may hold a later binary and require reconstruction.

Each measured prototype has one complete customer and one library group, CPU 13,
nine alternating samples per pair. These are private-build screening runs, not
repeated installed-release certifications. All slower controls and fingerprints
remain. Own tests/profilers/builds finished before timing; external activity was
not continuously audited. `pilot-timing.json` at root records accessor groups;
the descriptor variant's timing commands have their own receipt in its folder.

`math.json` and `descriptor-pool/math.json` each cover 192,360 combined comparisons
across five locales. Their original driver hashes match preserved driver copies,
as checked by `validation.json`. `descriptor-memory.json` binds the final focused
Memcheck corpus, 2,292 comparisons between two hosts and their forked subshells.
Both quiet memory logs are empty. `pristine-focused-math.json` binds the same final
driver against pristine/restored hosts; `pristine-restored-math.json` uses the
preceding full extension. These scopes and driver fingerprints remain distinct.

`memory-timeout/` preserves the broader Memcheck attempt that exceeded 300 seconds
on the reference host, its exact driver, empty error log and incomplete status.
It is not a passed memory receipt. The later focused extension completes with
an explicit 600-second allowance. The descriptor-buffer prototype was not given
this later memory certification. `source-checks.json` verifies proposal replay,
pristine inputs, current source restoration, headers and dynamic exports.

Raw profiles are compressed; flat summaries remain. The archive excludes compiled
fixtures, private protected-file snapshots and `previous-release.json`. No source
release archive or accepted incremental optimization patch is produced. The
pre-commit GitHub receipt records the unchanged private rc0 draft and seven assets.
`sha256.json` hashes every archived file except itself.
''')
files={str(p.relative_to(out)):hashlib.sha256(p.read_bytes()).hexdigest() for p in out.rglob('*') if p.is_file() and p.name!='sha256.json'};(out/'sha256.json').write_text(json.dumps(files,indent=2,sort_keys=True)+'\n');print('Archived/indexed',len(files),'files.')
