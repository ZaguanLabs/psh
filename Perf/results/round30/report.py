from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round30';read=lambda n:json.loads((l/(n+'.json')).read_text())
s='''# Round 30: fused decimal lexer, not adopted

**Neither decimal lexer prototype is adopted.** The active daily driver remains
`1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted optimizations. The selected
prototype reduces Endgame instructions by 3.09% and its installed warm runtime
by 2.1–2.4% in two complete paired groups. However, coder paste takes 3.5–4.8%
more time, chat paste 2.4–3.1% more, and JSON encoding 1.2–1.7% more. These
customer regressions outweigh the narrower improvement.

Production source is restored byte-for-byte to parent
`4b5ff817082a7b045304811f61064acc8b7d52da`. The developer executable is also
byte-identical to the preceding accepted build. No release was activated and no
compatibility difference is introduced. The current accepted report remains
[round 28](round28.md).

## Profile and prototypes

Fresh profiles of the exact accepted installed release cover Endgame, chat paste,
JSON array encoding and JSON validation. Endgame spends substantial work in
arithmetic parsing and evaluation. The experiment targets `lexconstant()` in
`Src/math.c`: normal decimal tokens are first scanned for their shape and then
scanned again during integer conversion. This round tries fusing those walks.

The initial prototype recognizes only complete positive one-digit literals
1–9, preserving live character-table and continuation exceptions. Matched
private-build profiles reduce Endgame instructions from 1,144,450,115 to
1,136,852,272 (0.66%). Its source, profile and pilot validation receipts remain
under [one-digit](results/round30/one-digit/). It was not packaged or timed as an
installed candidate; no installed-performance claim is made for it.

The selected prototype consumes ordinary positive decimals beginning with 1–9,
up to 18 digits for a 64-bit zlong or 9 digits for a 32-bit zlong. Each accepted
prefix fits signed zlong. It returns directly only for a complete ordinary
decimal token, preserving FORCEFLOAT conversion. Leading zero, signs, bases,
underscores, floats, exponents, longer integers and live classification exceptions
retain the original conversion path. The global input pointer remains unchanged
on fallback; the original classification walk resumes from the validated prefix.
No cache, allocation, ownership, ABI, declaration or signal-boundary change is made.

The [unapplied proposal](results/round30/proposed-with-fixtures.patch) includes
source and fixtures. The source checks reconstruct it against its recorded
parent and verify that removing the added prefix block and continuation label
recovers the original function exactly. Every other production function and the
public headers/declarations remain unchanged in the trial.

Matched private release-profile instruction counts have identical customer
source and output-state hashes:

| Kernel | Parent instructions | Trial instructions | Reduction |
| --- | ---: | ---: | ---: |
'''
rows=read('matched-profiles')
for old in rows[:3]:
 new=next(x for x in rows if x['name']==old['name'].replace('previous-','candidate-'));assert old['output_state_sha256']==new['output_state_sha256'] and old['source_sha256']==new['source_sha256'];a,b=old['instructions'],new['instructions'];s+=f"| {old['name'].removeprefix('previous-')} | {a:,} | {b:,} | {(1-b/a)*100:.2f}% |\n"
s+='''
Instruction reductions are not wall-time speedups. Compressed raw profiles and
flat summaries remain in the evidence.

## Exact installed-release measurements

The decisive pairs compare the accepted installed release with inactive trial
`1.0.0-rc0-363dc2fc22b0`. Both are dynamic, multibyte/PCRE release-profile builds,
DEBUG off, `-O2 -g`, explicit `LDFLAGS=-g`, stripped with separate debug files.
The trial is 850,584 bytes versus 846,488 bytes, retaining the same 1,056 dynamic
exported names/types. The additional page of file size is not a memory-use claim.

Nine alternating fresh-process samples per pair run on CPU 13, after own builds,
tests and profilers finish. Customer, library, parser, search, hardware and token
controls use C.UTF-8; array controls use C. A single pre-run aggregate observation
found CPU 13 idle and its sibling about 1% busy. This is not a continuous activity
audit. Warm timers exclude startup, loading and fixture construction; output/state
hashes match. Positive percentages mean more time. Small differences alone do not
establish a useful general benefit.

'''
for base,rep,title in [('customer-benchmarks','customer-repeat','Customer kernels'),('library-benchmarks','library-repeat','Library operations')]:
 s+='### '+title+'\n\n| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n'
 for a,b in zip(read(base)['cases'],read(rep)['cases']):
  name=a.get('case',a.get('operation'));assert name==b.get('case',b.get('operation'));o,n=a['median_ms'];u,v=b['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% | {u:.3f} | {v:.3f} | {(v/u-1)*100:+.1f}% |\n'
 s+='\n'
for key,title in [('parser-benchmarks','Parser controls'),('search-benchmarks','Search controls'),('array-benchmarks','Array controls'),('math-token-benchmarks','Arithmetic token controls')]:
 s+='### '+title+'\n\n| Case | Parent ms | Trial ms | Change |\n| --- | ---: | ---: | ---: |\n'
 for c in read(key)['cases']:
  name=c.get('case',c.get('name',c.get('operation')))
  if key=='array-benchmarks':name+=f" / size {c['size']} / iterations {c['iterations']}"
  if key=='math-token-benchmarks':name=f"{c['expression']} / {c['mode']}"
  o,n=c['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% |\n'
 s+='\n'
s+='''The arithmetic controls include interpreter dispatch in warm repeat batches of
30,000 literal evaluations, excluding function definition and warmup. Ordinary
18-digit literals take about 9% less time, while the 19-digit fallback takes
8–9.5% more and the `1.25` control takes about 10–11% more. This supports rejecting
the general fast path; it does not isolate the cause of each customer regression.

### Hardware controls

Counters cover user-space exec through exit, setup and inherited tasks, a
different scope from warm timers. Every event is fully scheduled.

| Case | Parent cycles | Trial cycles | Parent instructions | Trial instructions |
| --- | ---: | ---: | ---: | ---: |
'''
for c in read('hardware')['cases']:
 a,b=c['median_scaled_events'];s+=f"| {c['case']} | {a['cycles']:,.0f} | {b['cycles']:,.0f} | {a['instructions']:,.0f} | {b['instructions']:,.0f} |\n"
s+='''
### Interrupted first pass

The first installed timing batch ended with SIGTERM (status 143) after completing
customer and library groups, during the parser stage. The cause was not
established; the logs report no failed state comparison. Every completed JSON,
partial log and command receipt is retained in
[interrupted-timing](results/round30/interrupted-timing/). Its Endgame median is
44.902 → 44.100 ms, chat paste 217.545 → 224.607 ms, and JSON encoding
208.802 → 212.573 ms. These values are not mixed into the final complete groups.
The rerun streams child progress and completes all nine groups successfully.

## Native arithmetic coverage and validation

The committed native fixture calls `matheval()` and the existing internal
`mathevalarg()` with exact allocations at offsets zero/three and selected
terminators directly before inaccessible pages. It checks unchanged input,
compares numeric types and bits, argument endpoints, error state, errno,
floating-point exceptions, lastbase, outputradix, outputunderscore and lastmathval.
It tests four rounding modes, eight FORCEFLOAT/OCTALZEROES/CPRECEDENCES
combinations and five live character-table configurations. ASCII successors,
embedded NULs and fixed expressions exercise ordinary integers, floats, bases,
underscores, format controls, short circuiting and long-number fallback.
Normal single-digit results also have independent expected-value assertions.
The fixture restores its modified interpreter state; its internal declarations
are test-only and do not create a supported native API.

There are 1,677,760 counted API observations per host/locale. The final candidate
matrix passes **16,777,600 checks across ten Memcheck processes**: pristine/GCC
in C and UTF-8; Clang old/new in UTF-8; pristine/DEBUG in UTF-8; and exact installed
old/new in UTF-8. These repeat the matrix rather than representing sixteen million
distinct expressions. Leak checks are disabled; memory errors are zero.
The restored pristine/DEBUG comparison passes another 3,355,520 checks separately.
Pilot receipts remain separate and bind their own fixture fingerprints.

Candidate validation also passes:

- GCC release: 63 upstream scripts, zero failures, two skips. Clang parent and
  trial each pass 63/0/2. DEBUG developer passes 62/0/3, with PCRE absent in its
  default configuration. The restored developer build passes 62/0/3 again.
- Eleven differential groups: arrays 5,192; search 193,236; patterns 159,600;
  scalars 704,585 across five encodings; substitution 2,640; combined arithmetic
  syntax/operators 180,960 across five locales; native floating-point 200,832
  scenarios under Memcheck; accessor 20; PTY completion 36; emulation frontend
  512; and customer correctness including 24 kernel/locale pairs and five
  original project suites.
- Seven inactive-package suites, including all 190 zdraw tests, rebuilt native
  components, installed core/login/startup checks and 24 genuine interactive
  Oh My Zsh sessions with re5et, git and syntax highlighting.
- Release identity, matching source inputs, fallback reconstruction, unchanged
  declarations and dynamic exports. All 1,847 pristine release files are verified.

The initial fixture used DEBUG headers for a release host and failed module
loading due to the DEBUG-only `queue_in` reference. The driver now builds a
fixture against each host's matching SDK. An initial Mario profile used two steps
and tripped the reference workload's speed invariant; the final profile uses its
authored 120-step case. An evidence move temporarily hid the local previous-release
snapshot; it was restored before repeating that check. Logs remain under
`setup-failures/`. These were harness/setup failures, not discovered C semantic
regressions; no correctness check was removed to adopt a change.

These results cover exercised cases, not all shell behavior. No fresh
non-multibyte or other-operating-system certification was performed. The structural
index had partial coverage; focused source reads and byte comparisons support the
source claims. The complete source audit remains unfinished.

## Restored state

'''
r=read('restoration');assert r['passed'] and r['no_activation_performed']
s+=f"Active prefix: `{r['active_prefix']}`.\n\nActive ELF SHA-256: `{r['active_sha256']}`.\n\nAll {r['active_source_inputs_match']:,} current packaged inputs match the accepted\nrelease. The restored developer SHA-256 is `{r['development_sha256']}`.\n\n"
s+='''The normal-user package verifier passes again with a fresh 24-session interactive
OMZ gate. Historical seven-suite receipts are reused only for the unchanged
accepted artifacts; they are not seven newly rerun suites. The three transient
Vendor module outputs were restored from the exact previously tested active
payload before verification, preserving trial bytes in the inactive prefix.
Neither installed release was modified and no verifier was weakened.

'''
s+=f"All {r['active_release_entries_unchanged']:,} active-release entries and\n{r['protected_stable_entries_unchanged']:,} protected stable-Zsh/startup entries remain\nunchanged. `/etc/shells`, account login shell, personal startup files and framework\nsources are untouched. Package `latest.json` points to the accepted active build.\nThe inactive trial `{Path(r['inactive_trial_prefix']).name}` remains available\nlocally with ELF SHA-256 `{r['inactive_trial_sha256']}`.\n\n"
s+='''The project stays `1.0.0-rc0`. The private repository, original rc0 tag, draft and
seven historical assets remain unchanged. No new accepted source patch or release
archive is created. The [evidence index](results/round30/README.md) distinguishes
inactive-proposal receipts from restored-state proof and retains slower controls,
unsuccessful prototypes and the interrupted timing pass. Local private snapshots
and previous-release manifests are excluded.
'''
(root/'Perf/round30.md').write_text(s)
