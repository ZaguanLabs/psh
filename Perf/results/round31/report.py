from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round31';read=lambda n:json.loads((l/(n+'.json')).read_text())
s='''# Round 31: arithmetic descriptor lifetimes and inlining, not adopted

**All three private trials are rejected.** Production C source is restored to
parent `a6e92b6f195e247e7886a0a9d5c4079edbfdd22d`. The developer executable was
never rebuilt or changed. The installed daily driver remains
`1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted optimizations. No new package
was built, installed or activated; no new compatibility difference is introduced.
The current accepted optimization remains [round 28](round28.md).

## Descriptor allocation

Fresh profiles of the exact accepted release cover Endgame, chat paste, JSON
encoding and validation. Arithmetic remains Endgame's largest cost. A deferred
variable lookup in `getmathparam()` allocates a `struct value` through `zhalloc()`
before calling `getvalue()`. That descriptor supports lazy numeric retrieval and
later assignment, including cached subscript effects. Its lifetime must cover
recursive getters, callbacks and assignments; changing it is not merely removing
an allocation call.

The [first proposal](results/round31/descriptor-pool/source.patch) adds eight
private descriptors to each `mathevall()` C frame. Lookups consume them in order,
then retain the original heap allocator. Recursive evaluation saves/restores the
buffer pointer and remaining count. Slots are not reused within an evaluation.
Public structures, getters, setters, parser rules and signal boundaries retain
their original code. Eight limits the additional frame storage; it is not an
application-specific layout or a claim of an optimal buffer size. The remaining
lifetime assumptions would need further certification before adopting such a
storage change.

This saves 0.52% of Endgame instructions and 0.62% of Mario instructions, while
JSON encoding instructions increase 0.03%. Its first private-build timing pass
is mixed: Endgame takes about 0.6% less time, coder paste 1.7% more, chat paste
2.9% more and JSON encoding 3.2% more. These screening results do not justify a
full package/activation cycle. The prototype is retained locally as
`.work/round31/descriptor-pool-zsh`, with source and binary hashes in the receipts.
It was not certified under the later focused Memcheck run.

## Compiler hints

A second proposal changes only `mathparse()` from `static void` to
`static inline void`. GCC emits an identical `math.o` `.text` section, including
size and SHA-256. No speedup is claimed and no timing matrix was run for it.
The source patch and object-section identity receipt remain in
[inline-parser](results/round31/inline-parser/). This comparison covers that
object section, not every byte of differently configured final executables.

The third proposal changes only `getmathparam()` from `static mnumber` to
`static inline mnumber`; its complete body is unchanged. The separate function
is absent from the trial's symbol table and its logic moves into callers.
`math.o` text grows from 15,291 to 17,915 bytes, a 2,624-byte increase. This is
object code size, not the installed stripped binary or process memory usage.

Endgame's combined self instructions in `mathparse()`, `op()` and
`getmathparam()` rise from 368,496,512 to 373,780,846. That increase accounts for
essentially the entire process-level increase. Removing the call does not make
the generated code cheaper. Register allocation and code layout are possible
contributors; this round does not isolate their individual effects.
The [unapplied accessor patch](results/round31/source.patch) and private ELF
`.work/round31/inline-accessor-zsh` remain available for reconstruction.

## Matched instruction profiles

Each pair uses matched release-profile private builds and identical application
source and resulting-state fingerprints. Positive percentages mean more work.

| Trial | Kernel | Parent instructions | Trial instructions | Change |
| --- | --- | ---: | ---: | ---: |
'''
for path,label in [('descriptor-pool/matched-profiles','Descriptor buffer'),('matched-profiles','Accessor inline')]:
 rows=read(path)
 for a in rows[:3]:
  b=next(x for x in rows if x['name']==a['name'].replace('previous-','candidate-'));assert a['source_sha256']==b['source_sha256'] and a['output_state_sha256']==b['output_state_sha256'];u,v=a['instructions'],b['instructions'];s+=f"| {label} | {a['name'].removeprefix('previous-')} | {u:,} | {v:,} | {(v/u-1)*100:+.2f}% |\n"
s+='''
The initial descriptor trial's reference raw profiles were overwritten when
work paths were reused for the accessor trial. Its original counts and hashes
remain in its JSON receipts; its candidate raw profiles survive. Root reference
raw profiles belong to the accessor run and must not be relabeled as the first
run. The separate fresh accepted-release profiles survive in `descriptor-pool/`.
This limitation does not affect the saved timing samples or state comparisons.

## Private-build screening timings

Nine alternating fresh-process samples per pair, CPU 13, C.UTF-8. Both builds
use dynamic modules, multibyte/PCRE, DEBUG off, `-O2 -g` and explicit `LDFLAGS=-g`.
Own builds, tests and profilers finish before each timing pass. External activity
is not continuously audited. Warm timers exclude startup, loading and fixture
construction; resulting states match. Each prototype has one customer group and
one library group. These are screening runs, not repeated installed-release
certifications or general speed guarantees. Small differences are not assigned
a causal story. Positive percentages mean more time.

'''
for old,new,title in [('descriptor-pool/customer-pilot','customer-inline','Customer kernels'),('descriptor-pool/library-pilot','library-inline','Library controls')]:
 s+='### '+title+'\n\n| Case | Buffer parent ms | Buffer trial ms | Change | Inline parent ms | Inline trial ms | Change |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n'
 for a,b in zip(read(old)['cases'],read(new)['cases']):
  name=a.get('case',a.get('operation'));assert name==b.get('case',b.get('operation'));u,v=a['median_ms'];x,y=b['median_ms'];s+=f'| {name} | {u:.3f} | {v:.3f} | {(v/u-1)*100:+.1f}% | {x:.3f} | {y:.3f} | {(y/x-1)*100:+.1f}% |\n'
 s+='\n'
s+='''The accessor hint takes about 3.5% more time in coder/chat paste, 3.4% more in
JSON encoding and 0.8% more in Endgame. Together with its instruction increase,
this fails screening. No package build or broad certification was pursued for
these rejected trials. Their private-build results are not substituted for an
exact installed-binary performance comparison.

## Expanded regression coverage

`math-compare.py --descriptors` adds repeated scalar/integer/array/hash lookups,
side-effecting subscripts, callback-driven deletion/retyping, recursive arithmetic,
short circuiting and nested lvalue assignments. Counts span 1/2/7/8/9/15/16/17/
32/64/96/128 lookups and nested lvalue cases through 96. Tests compare values,
variable state, callback traces, diagnostics, statuses and every completion marker
across native/ksh/sh modes and four option configurations. Buffer exhaustion and
recursive restoration are exercised; matching outputs alone do not prove all
native lifetime assumptions safe.

Both the buffer and accessor trials pass the full combined syntax/operator/
descriptor corpus: **38,472 comparisons per locale, 192,360 across five locales**
each. The accessor GCC build passes **63 upstream scripts, zero failures, two
skips**. The normal pristine/restored comparison passes 5,352 cases in UTF-8;
the final focused pristine/restored comparison passes 2,292. The focused corpus
contains 191 expressions, while the combined corpus deduplicates overlaps with
its existing cases.

`--descriptors-only --memcheck --timeout 600` passes **2,292 comparisons** between
the reference and accessor hosts, including their forked subshells. Leak checks
are disabled. Quiet Memcheck logs are empty and the complete output/status
comparisons pass. This is a focused memory check, not a fresh certification of
every previously tested native API. The first broader instrumented attempt hit
its 300-second per-host timeout on the reference host. No memory error was
reported before stopping, but that incomplete attempt is explicitly not counted
as passed. Its driver, log and status remain under `memory-timeout/`.

The driver now supports focused cases, Memcheck and an explicit positive timeout,
and checks that its own source stays unchanged during a run. Different driver
versions are preserved and bound to their receipts by `validation.json`; older
receipts must not be claimed to fingerprint the final driver. The ordinary
expanded comparisons and the focused instrumented run retain their distinct scopes.

Source checks replay all three proposals against the parent, verify all 1,847
pristine files, check unchanged public headers and the same 1,056 dynamic exported
names/types. There is no new native ABI. Other compilers, fresh non-multibyte
builds and other operating systems were not certified for these rejected trials.
The structural index had partial C coverage and eight failed files; focused
source reads and byte comparisons support the claims, not an exhaustive audit.

## Restored state

'''
r=read('restoration');assert r['passed']
s+=f"Active release: `{Path(r['active_prefix']).name}`.\n\nActive ELF SHA-256: `{r['active_sha256']}`.\n\nDeveloper ELF SHA-256: `{r['development_sha256']}`.\n\n"
s+=f"All {r['active_source_inputs_match']:,} canonical package inputs match the accepted\nrelease, all {r['active_release_entries_unchanged']:,} active-release entries and\n{r['protected_stable_entries_unchanged']:,} protected stable-Zsh/startup entries are unchanged.\n\n"
s+='''The normal-user verifier passes with a fresh 24-session interactive Oh My Zsh
gate using the actual re5et/git/syntax-highlighter setup. Its historical seven-suite
receipts apply to unchanged accepted artifacts; they are not seven freshly rerun
trial suites. Package `latest.json`, active links, stable Zsh, `/etc/shells`, account
login shell and personal startup files remain unchanged. No Vendor native output
restoration or privileged installer operation was needed this round.

The version stays `1.0.0-rc0`. The repository remains private and the original rc0
tag, draft and seven assets are preserved. There is no accepted source patch or
new release archive. [The evidence index](results/round31/README.md) distinguishes
private experiments, the incomplete memory attempt and current-state proof.
The complete source audit remains unfinished.
'''
(root/'Perf/round31.md').write_text(s)
