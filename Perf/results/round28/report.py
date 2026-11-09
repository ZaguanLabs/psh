from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round28';read=lambda n:json.loads((l/(n+'.json')).read_text());b=json.loads((root/'.work/package/latest.json').read_text());identity=read('identity');activation=read('activation')
assert activation['passed'] and read('native-validation')['passed'] and read('source-checks')['passed']
reports=[read(n) for n in ['append-prefix-native','clang-prefix','development-prefix','installed-prefix']];assert sum(d['checks'] for d in reports)==21930 and all(d['passed'] for d in reports)
s='''# Round 28: confirmed prefixes before array append

This accepts optimization 26 relative to parent
`b9ab35d3627c00568b893498e5a540cac4201175`. The project remains
`psh 1.0.0-rc0 (zsh 5.9.2)`. JSON array encoding takes 2.7% and 3.7% less time
in the two paired measurement groups. A 16,000-append control improves from
28.068 ms to 7.741 ms, about 3.63× faster. Other customer results are smaller
or mixed. No new language, ABI or ownership difference is intended; existing
native-array contract differences remain in [COMPATIBILITY.md](../COMPATIBILITY.md).

## Why this path

Fresh instruction profiles use the actual installed round-27 release and the
customer's Endgame, chat, JSON encoding and JSON validation kernels. In JSON
encoding, nearly all `arrlen()` instructions come from `assignaparam()`: 16,000
calls account for 160,084,000 instructions, about 5.7% of the whole profile.
They count the old array before whole-array append. The earlier optimization
already avoids recounting it inside the setter, but each subsequent append
still starts the next count from the beginning.

Matched parent/candidate release profiles have identical customer source and
resulting-state fingerprints. JSON encoding falls from 2,812,486,410 to
2,653,577,696 instructions, a 5.65% reduction. Total `arrlen()` instructions
fall from 160,832,580 to 822,660. Chat paste stays essentially flat:
2,363,618,238 to 2,363,622,274 instructions, with the same 404,974 instructions
in `arrlen()`. These are instrumented instruction totals, separate from timers.
[Profile receipts](results/round28/matched-profiles.json) and raw compressed
profiles retain the exact commands, hashes and complete output summaries.

## Implementation and invariants

`assignaparam()` now completes an eligible whole-array append count after an
already confirmed prefix. It still checks the remaining pointers through the
terminator; the prefix is not an assertion that the array ends there. After an
eligible assignment constructs or preserves an array of at least 64 elements,
`setarrvalue_len()` records the resulting prefix in the existing 64-entry cache.
No exact-length flag, larger cache, new allocation, public symbol or structure
layout is introduced. New helper `array_length_full()` is private.

Eligibility is established before reading the value: standard array GSU,
ordinary named parameter, no special/tied/hash-element state, no environment
tie, and no mutable native getter loan. The read also requires queued signals,
the current vector identity, matching parameter/vector cache identities and a
prefix representable as an `int`. Otherwise it counts from the beginning.
Only the existing callback-free setter path can publish a constructed prefix,
with signals already queued and uniqueness disabled. Unique arrays can shrink
when the setter removes duplicates, so they never publish the precomputed count.
Custom getters retain their original snapshots, callback counts and setter path.

Setters and destructors retain their original invalidation. Public mutable
getters still disable cache use through `PM_ARRAY_EXPOSED`, including persistent
loans across cache churn and in-place realloc. The existing raw-field bypass
migration remains necessary; this round adds no separate supported way to mutate
an array without that protocol. Signal delivery boundaries are unchanged.

This removes repeated prefix traversal from eligible append counting. It does
not promise constant-time allocation, capacity growth or all forms of array
processing: realloc can still move/copy a vector, incoming values must be
processed, cache collisions can require a fresh count, and ownership fallbacks
continue scanning.

The five-file [incremental patch](0028-append-confirmed-prefix.patch) reconstructs
exactly against the parent. [Source checks](results/round28/source-checks.json)
verify 1,847 pristine files and 1,853 package inputs, unchanged ownership/getter/
setter/destructor functions, public headers and exported parameter declarations.
Removing the private helper and restoring just `setarrvalue_len()` and
`assignaparam()` recreates the parent's entire `Src/params.c` byte-for-byte.

## Scanner revisit: rejected

The new release profile still puts substantial cost in `scanmatchtable()`.
A prototype hoisted the no-pattern/no-mask decision outside its unsorted inner
loop, retaining its live cursor and callback handling. Reviewing the prior work
showed that round eighteen had already rejected this idea under the then-current
DEBUG build. It was checked once against today's release build and changed
emulation workload, rather than assuming an instruction reduction would help.

The results remain mixed: coder paste takes 1.7% more time, chat paste 0.8% more,
JSON array parsing 1.0% more and encoding 0.4% more. Some individual layout
medians improve, including a 19.2% coder-layout outlier, but the broader customer
results do not justify adoption. Complete paired samples, build commands and
source diff remain under [scan-revisit](results/round28/scan-revisit/).
No new correctness or compatibility certification is claimed for that rejected
prototype. The generic scanner is restored byte-for-byte to the parent before
the selected array change is built and tested.

## Wall-time measurements

Matched GCC release builds use `-O2 -g`, explicit `LDFLAGS=-g`, dynamic modules,
multibyte/PCRE support and DEBUG off, with separate runtime directories.
Nine alternating fresh-process samples per pair run on CPU 2. Customer,
library, parser, search and hardware groups use `C.UTF-8`; the array control
driver uses `C`. Own builds, tests and profilers were idle throughout these
timing groups. Unrelated system activity was not continuously audited. Warm
operation timers exclude setup/warmup. Output/state checks matched.
Positive percentage changes below mean more time. Small or mixed differences
are not presented as established improvements or regressions.

'''
for base,rep,title in [('customer-benchmarks','customer-repeat','Customer kernels'),('library-benchmarks','library-repeat','Library operations')]:
 s+='### '+title+'\n\n| Case | Parent ms | Candidate ms | Change | Repeat parent | Repeat candidate | Repeat change |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n'
 a=read(base)['cases'];r=read(rep)['cases'];assert len(a)==len(r)
 for x,y in zip(a,r):
  name=x.get('case',x.get('operation'));assert name==y.get('case',y.get('operation'));o,n=x['median_ms'];u,v=y['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% | {u:.3f} | {v:.3f} | {(v/u-1)*100:+.1f}% |\n'
 s+='\n'
for key,title in [('parser-benchmarks','Parser controls'),('search-benchmarks','Search controls'),('array-benchmarks','Array controls')]:
 s+='### '+title+'\n\n| Case | Parent ms | Candidate ms | Change |\n| --- | ---: | ---: | ---: |\n'
 for c in read(key)['cases']:
  name=c.get('case',c.get('name',c.get('operation')))
  if key=='array-benchmarks':name+=f" / size {c['size']} / iterations {c['iterations']}"
  o,n=c['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% |\n'
 s+='\n'
s+='''URL encoding takes 0.7% and 0.8% more time in its two groups. Chat paste is
0.8% slower in the first group and 1.5% faster in the repeat. Endgame also has
mixed small changes. Search middle and start-beyond medians are 1.3% slower.
Every control and sample remains in the evidence. These are offline kernels,
not whole-application startup, terminal frame latency or a universal shell score.

### Hardware controls

The scope is user-space exec through exit, including setup and inherited tasks,
which differs from warm operation timers. All counters were fully scheduled.

| Case | Parent cycles | Candidate cycles | Parent instructions | Candidate instructions |
| --- | ---: | ---: | ---: | ---: |
'''
for c in read('hardware')['cases']:
 a,d=c['median_scaled_events'];s+=f"| {c['case']} | {a['cycles']:,.0f} | {d['cycles']:,.0f} | {a['instructions']:,.0f} | {d['instructions']:,.0f} |\n"
s+='''
## Validation

- GCC release candidate: 63 upstream scripts passed, zero failures, two skips.
  Clang parent and candidate: each 63 passed, zero failures, two skips.
  Refreshed DEBUG developer build: 62 passed, zero failures, three skips
  (default developer configuration lacks PCRE).
- New append-prefix fixture: 21,930 counted state snapshots across 30 Memcheck
  processes, plus readonly/tied/special/unique and native-loan output checks.
  Each process tests 17 initial lengths and 14 mutation actions in native, ksh
  or sh emulation. Primary pristine/GCC checks run in C and UTF-8; Clang,
  pristine/DEBUG and exact previous/new installed releases run in UTF-8.
  This repeats one matrix across hosts/modes/locales; it is not 21,930 distinct
  source programs. Zero Memcheck errors, leak checks disabled.
- Three public mutable getter loans (`getaparam`, direct getter and
  `getarrvalue`) truncate a previously cached large vector before further
  appends; the final seven elements must match. The native fixture's added
  `trim` operation frees removed strings and uses public getter-loan semantics.
- Existing cache lifetime/mutation checks pass under ordinary malloc and
  Memcheck, including in-place/moved realloc, scope destruction, uniqueness,
  setters, cache churn and loans. Unqueued search probes leave metadata
  unchanged, as verified with GDB. Native array-length and custom accessor
  fixtures also pass, preserving self-replacing getter behavior.
- Eleven broad groups pass: arrays 5,192; search 193,236; patterns 159,600;
  scalar cases 704,585 across five encodings; substitution 2,640; arithmetic
  syntax 110,100; native floating-point 200,832 scenarios under Memcheck;
  accessor 20; PTY completion 36; 512 emulation frontend cases; and customer
  correctness. Customer checks include 24 kernel/locale pairs and five original
  project suites. Commands and exact per-group receipts remain in the evidence.
- Seven installed package suites pass, including all 190 zdraw tests and native
  modules rebuilt against this SDK. Normal-user package verification passes
  before activation, including 24 genuine interactive Oh My Zsh sessions with
  re5et, git, syntax highlighting, completion, history, prompts and async work.
  This establishes the exercised configuration, not every possible OMZ setup.

An initial automated source edit used an incorrect indentation needle and
stopped on an assertion before writing `params.c`. The successful edit driver
is retained. The first source reconstruction check mistakenly stopped removal
of the helper at its first blank line; correcting the checker to use the whole
function made the byte comparison pass. Neither setup issue changed production
semantics or hid a failing shell test. The initial pilot fixture was subsequently
extended to warm the readonly parameter before refusing its write; final native
runs bind the final source fingerprint.

## Installed checkpoint and limits

'''
prefix=Path(b['prefix']);s+=f"Active release: `{b['prefix']}`.\n\nInstalled ELF SHA-256: `{b['installed_shell_sha256']}`.\n\nThe stripped executable is {identity['bytes'][str(prefix/'bin/psh')]:,} bytes, versus\n{identity['bytes'][str(Path(activation['previous_prefix'])/'bin/psh')]:,} previously, with the same {identity['dynamic_exports_unchanged']:,} dynamic\nexport names/types. The installed release keeps DEBUG off and separate symbols;\nthe refreshed developer build keeps DEBUG on.\n\n"
s+=f"Post-activation checks preserve all {activation['previous_release_entries_unchanged']:,} entries in previous release\n`{Path(activation['previous_prefix']).name}` for rollback, along with\n{activation['stable_zsh_startup_entries_unchanged']:,} protected stable-Zsh/startup entries. `/etc/shells` and the account\nlogin shell are unchanged. Personal startup files and framework sources were\nnot edited. The exact installed ELF passes release identity and native checks.\n\n"
s+='''The repository remains private. The original rc0 tag, draft and seven historical
assets are unchanged; this iteration is identified by its commit/build digest
and binary hash. No new source archive is presented as the original tag.

This is a focused append/cache investigation, not a completed interpreter audit.
The structural index reported partial coverage; exact source reads and byte
comparisons underpin the source claims. Other operating systems and a new
non-multibyte build were not certified here. Existing native-array differences
and migration remain documented separately.

[Evidence index](results/round28/README.md) describes final receipts, the rejected
scanner branch and compressed profiles. Its manifest hashes archived files
except itself. Local-only startup snapshots and the private previous-release
manifest are excluded from the repository archive.
'''
(root/'Perf/round28.md').write_text(s)
