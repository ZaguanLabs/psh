# Round 31: arithmetic descriptor lifetimes and inlining, not adopted

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
| Descriptor buffer | endgame | 1,144,450,113 | 1,138,525,805 | -0.52% |
| Descriptor buffer | mario | 430,983,212 | 428,311,836 | -0.62% |
| Descriptor buffer | json-encode | 2,653,577,764 | 2,654,265,912 | +0.03% |
| Accessor inline | endgame | 1,144,450,115 | 1,149,734,613 | +0.46% |
| Accessor inline | mario | 430,983,246 | 431,341,364 | +0.08% |
| Accessor inline | json-encode | 2,653,577,764 | 2,653,729,716 | +0.01% |

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

### Customer kernels

| Case | Buffer parent ms | Buffer trial ms | Change | Inline parent ms | Inline trial ms | Change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 120.112 | 122.199 | +1.7% | 120.985 | 125.249 | +3.5% |
| zcoder.zsh/coder-layout | 5.779 | 5.779 | +0.0% | 5.814 | 5.858 | +0.8% |
| zcoder.zsh/coder-wide-layout | 66.171 | 65.912 | -0.4% | 66.208 | 66.939 | +1.1% |
| zchat.zsh/chat-paste | 215.345 | 221.690 | +2.9% | 218.403 | 226.005 | +3.5% |
| zchat.zsh/chat-layout | 5.781 | 5.783 | +0.0% | 5.791 | 5.841 | +0.9% |
| zchat.zsh/chat-wide-layout | 66.543 | 66.228 | -0.5% | 66.083 | 66.692 | +0.9% |
| endgame/endgame-world | 44.721 | 44.447 | -0.6% | 44.614 | 44.982 | +0.8% |
| z3dfx.mario/mario-race | 20.708 | 20.619 | -0.4% | 20.653 | 21.348 | +3.4% |
| z3dfx/shooter-step | 12.215 | 12.063 | -1.2% | 12.201 | 12.806 | +5.0% |
| z3dfx.agy/shooter-step | 12.122 | 12.016 | -0.9% | 12.109 | 12.667 | +4.6% |
| z3dfx.grok/shooter-step | 12.223 | 12.040 | -1.5% | 12.144 | 12.717 | +4.7% |
| zfetch/fetch-encode | 13.773 | 13.906 | +1.0% | 13.855 | 14.118 | +1.9% |
| z3dfx.drawing/drawing-binning | 13.115 | 12.797 | -2.4% | 13.053 | 13.096 | +0.3% |

### Library controls

| Case | Buffer parent ms | Buffer trial ms | Change | Inline parent ms | Inline trial ms | Change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zjson-array | 94.138 | 96.488 | +2.5% | 94.660 | 100.876 | +6.6% |
| zjson-encode-array | 206.358 | 212.985 | +3.2% | 211.184 | 218.336 | +3.4% |
| zjson | 92.004 | 94.274 | +2.5% | 94.270 | 99.876 | +5.9% |
| navigation | 1.946 | 1.986 | +2.0% | 1.965 | 2.135 | +8.6% |

The accessor hint takes about 3.5% more time in coder/chat paste, 3.4% more in
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

Active release: `1.0.0-rc0-56f97a85e8cb`.

Active ELF SHA-256: `9981ba37c0d6b467e11cb7ce8aacd10a89f95133b7958c7e3aad654cb47e0b72`.

Developer ELF SHA-256: `86c7153edc3e45bf994bc02236213dab83a836f00028392c1cbc9bcc8c4acae6`.

All 1,853 canonical package inputs match the accepted
release, all 1,603 active-release entries and
11,828 protected stable-Zsh/startup entries are unchanged.

The normal-user verifier passes with a fresh 24-session interactive Oh My Zsh
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
