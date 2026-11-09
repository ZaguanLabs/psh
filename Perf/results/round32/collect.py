from pathlib import Path
import gzip,hashlib,json,shutil
root=Path.cwd();l=root/'.work/logs/round32';out=root/'Perf/results/round32';out.mkdir(exist_ok=True);allowed={'.json','.py','.log','.txt','.zsh','.c','.asm'}
for p in l.rglob('*'):
 if not p.is_file():continue
 dest=out/p.relative_to(l);dest.parent.mkdir(parents=True,exist_ok=True)
 if p.suffix in allowed:shutil.copy2(p,dest)
 elif p.suffix=='.callgrind':dest.with_suffix(dest.suffix+'.gz').write_bytes(gzip.compress(p.read_bytes(),mtime=0))
(out/'README.md').write_text('''# Round 32 evidence: deeper algorithmic research

[The report](../../round32.md) separates measured baseline costs from proposed
redesigns. No production C source, developer binary, installed package or active
link changes in this round. `state-proof.json` checks canonical source inputs,
exact binaries and payload, protected files, metadata and reuse of the previous
round's package/24-session OMZ receipts. No fresh interactive gate is claimed.

`scope-scaling.json` has nine raw samples for each of 42 cases: dense globals,
created-then-deleted globals, loop-only controls, empty functions, one/eight locals,
emulation and nested functions. Native counts include unset placeholders and
exclude hidden shadow-chain nodes. Setup, warmup and observations are outside
warm timers. Case order rotates/reverses, with every order retained. CPU 13,
C.UTF-8, exact installed executable and separately built observer fingerprints.

`customer-scaling.json` and `customer-repeat.json` each compare original coder/chat
paste kernels with zero and 512 unrelated globals, nine alternating samples per
pair. Artificial padding is introduced before loading the unchanged worker.
Editor output states match; namespace counts differ exactly 512. These are
namespace-sensitivity tests, not optimized binaries or full application sessions.
Their warm timers retain the original worker's definition.

`profiles.json` contains six independent Callgrind commands, executable/worker/
project hashes and states. Raw profiles are compressed with deterministic gzip;
flat and inclusive-caller reports remain. The profiles include whole-process
setup and observations, unlike warm timers. `profile-metrics.py` deduplicates
repeated annotated views of the same edge and records scope-exit scans and
cleanup callbacks. Padding adds exactly 512 callbacks per scope exit in each
project. These counts attribute instructions, not wall time. All six raw profiles
have distinct names and are retained.

`power-scaling.json` has nine samples for 24 non-overflowing base/exponent cases.
Each timer covers 50 powers with parsing, lookup and assignment. Expected values
and state hashes are checked; warmup/setup/validation are outside the timer.
No logarithmic replacement was benchmarked. `pristine-scaling.json` separately
confirms empty-function scaling in the DEBUG pristine build; it is not an
absolute installed/pristine speed comparison.

`preparation.json`, `prepare.py` and two Memcheck logs bind each observer module
to its matching host SDK. Twelve smoke combinations per host and load/observe/
unload under Memcheck pass; leak checks are disabled. Compiled modules are local
fixtures and not archived. `inherited-algorithms.json` confirms identical scope
function bodies and arithmetic operator body in current/pristine source. Full
historical upstream introduction dates were not audited.

`timing.json`, `additional-timing.json`, the drivers and `profile.py` retain phase
commands and statuses. Own builds/tests/profilers finish before timing; external
activity is not continuously audited. The structural index has partial C support
and eight failed files; no exhaustive source audit is claimed.

Protected-file and previous-release snapshots stay local. This archive includes
aggregate protection results only. `sha256.json` fingerprints every archived file
except itself. The pre-commit GitHub receipt preserves the unchanged private rc0
draft/seven assets; no release archive, optimization patch or publication occurs.
''')
files={str(p.relative_to(out)):hashlib.sha256(p.read_bytes()).hexdigest() for p in out.rglob('*') if p.is_file() and p.name!='sha256.json'};(out/'sha256.json').write_text(json.dumps(files,indent=2,sort_keys=True)+'\n');print('Archived/indexed',len(files),'files.')
