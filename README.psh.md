# psh — Performance SHell

The `rc1` development branch adds compiler optimization experiments, full scene
construction benchmarks, stateful differential coverage and safe completion
directory permissions under a group-writable umask. The latest [native-library audit](Perf/round40.md) withdraws a float-formatting
experiment whose module guard missed libc plugins. **rc1 publication remains on hold.** Published rc0 is
retained unchanged. See [the packaging guide](Packaging/README.md) for optional
PGO builds and [the performance workflow](Perf/README.md) for the new checks.

For the public rc0 introduction and quick start, see the
[project overview](.github/README.md) and [release notes](Releases/1.0.0-rc0.md).
This file retains the detailed development history.

psh 1.0.0-rc0 pursues meaningful performance gains on Zsh 5.9.2 while preserving
existing behavior by default. Limited, deliberate differences need substantial
measured benefit, understood consequences and a documented migration or fallback.
**Oh My Zsh must work unchanged**, including
the user's theme, plugins and interactive behavior. See [the compatibility
policy](COMPATIBILITY.md) and [the mandatory terminal gate](Perf/round21.md).
Unexpected differences, memory corruption and unsafe ownership remain bugs.
Native API/ABI changes require matching SDKs and rebuilt modules. Test results
are evidence of the covered behavior, not a universal compatibility certificate.

The local executable is `./psh`. Upstream build targets, `ZSH_VERSION`, module
names (`zsh/*`) and personal startup filenames retain their Zsh identities.
`--version` reports the psh project version and the underlying Zsh version. The executable's invocation name naturally appears as `psh`.
The original upstream README and licence are retained.

```sh
python3 Perf/build.py
./psh -dfc 'print -r -- "$ZSH_VERSION"'
```

This builds inside `.work/` and publishes `./psh`; it does not install a system
shell. In a clean clone, the build script restores `.work/pristine` from the
`upstream/zsh-5.9.2` tag and checks every source file against the committed
`Perf/upstream-sha256.json` manifest. Existing snapshots are verified against
the same manifest. The baseline is never constructed from the optimized HEAD.
Shallow clones may need `git fetch origin tag upstream/zsh-5.9.2` first.

For an installed daily-driver executable, use the separate
[private installation and bundled-package workflow](Packaging/README.md).
The [current rc0 iteration](Releases/rc0-release-profile.md) uses a release
profile without debug assertions; the development build above retains them.
It retains Zsh module names and personal startup filenames while moving all
installed psh files and global configuration to private psh directories.

See [the performance workflow](Perf/README.md),
[the source-review map](Perf/audit.md), and
[the first source/test patch](Perf/0001-short-prefix-array-replacement.patch).
The [second experiment](Perf/round2.md) covers bounded scalar copying;
its [patch](Perf/0002-bounded-scalar-copy.patch) applies after the first.
The [third experiment](Perf/round3.md) accelerates scalar index traversal;
its [patch](Perf/0003-scalar-index-widths.patch) applies after the second.
The [fourth experiment](Perf/round4.md) reuses an array append's known length;
its [patch](Perf/0004-array-append-length.patch) applies after the third.
The [fifth experiment](Perf/round5.md) avoids a full length scan before forward
array pattern searches; its [patch](Perf/0005-forward-array-search.patch) applies
after the fourth.
The [sixth experiment](Perf/round6.md) skips an unnecessary character count for
scalar pattern searches from the beginning; its
[patch](Perf/0006-scalar-search-length.patch) applies after the fifth.
The [seventh experiment](Perf/round7.md) skips Meta-free prefixes while counting
metafied byte spans; its [patch](Perf/0007-metafied-length-prefix.patch) applies
after the sixth.
The [eighth experiment](Perf/round8.md) removes unused backtracking storage for
eligible terminal stars; its [patch](Perf/0008-terminal-star-matching.patch)
applies after the seventh.
The [ninth experiment](Perf/round9.md) skips ASCII runs with bounded word loads
inside eligible terminal stars; its
[patch](Perf/0009-terminal-star-ascii-words.patch) applies after the eighth.
The [tenth experiment](Perf/round10.md) skips inert literal spans during
substitution; its [patch](Perf/0010-literal-substitution-spans.patch) changes
only the substitution routine and its regression case.
The [eleventh experiment](Perf/round11.md) skips long inert prefixes while
removing null markers; its [patch](Perf/0011-null-marker-prefix.patch) applies
after the tenth.
The [twelfth experiment](Perf/round12.md) adds grouped token-prefix scanning
and refines the null-marker probe; its
[patch](Perf/0012-grouped-token-prefix.patch) applies after the eleventh.

The [thirteenth experiment](Perf/round13.md) groups pointer-array scans; its
[patch](Perf/0013-grouped-array-scans.patch) applies after the twelfth.

The [fourteenth experiment](Perf/round14.md) avoids general conversion for ASCII
classification, guided by the expanded [customer workloads](Perf/customer-projects.md);
its [patch](Perf/0014-ascii-classification.patch) applies after the thirteenth.

The [fifteenth experiment](Perf/round15.md) skips plain prefixes in whole
metafied byte counts; its [patch](Perf/0015-byte-length-prefix.patch) applies
after the fourteenth.

The [sixteenth experiment](Perf/round16.md) advances numeric scalar indices
through guarded groups of eight ASCII characters, including runs following
Unicode or Meta escapes. Its [patch](Perf/0016-scalar-ascii-blocks.patch) applies
after the fifteenth.

The [seventeenth experiment](Perf/round17.md) counts complete-boundary ASCII
runs in the multibyte length/width helper. Its
[patch](Perf/0017-character-count-ascii.patch) applies after the sixteenth;
Unicode conversion and Meta handling retain their original loops.

The [eighteenth investigation](Perf/round18.md) tests two unfiltered hash-scan
specializations. Both were rejected after mixed customer timings;
new native callback tests and a scope-restoration regression are retained.

The [nineteenth investigation](Perf/round19.md) examines arithmetic evaluation,
locale conversion, array walks, allocation and scope scanning. Its accepted
[patch](Perf/0019-numeric-locale-conversion.patch) avoids process-locale changes
for ordinary floating literals when the complete locale-object API is available.
The development source now includes twenty-eight accepted optimizations.

The [twentieth investigation](Perf/round20.md) follows per-token arithmetic
validation. Its accepted [patch](Perf/0020-arithmetic-token-check-inline.patch)
adds an inline hint to the existing checker, keeping its complete function body.
Two extracted diagnostic-handler variants were rejected on project controls.

The [twenty-second investigation](Perf/round22.md) caches confirmed bounds for
ordinary interpreter-owned arrays. It targets repeated indexed reads in the
author's editor/chat layout and drawing code. Native mutable getters disable
the cache for the loaned allocation; the [native ownership contract](COMPATIBILITY.md#native-array-ownership)
is explicit. The cache does not count a whole array for a shallow query.

The first change accelerates size-preserving replacements within the first
32 elements of ordinary indexed arrays. It introduces no array-length cache or
storage-format change. Array append scaling remains an open investigation.

The second change copies only the selected scalar bytes after Zsh's existing
index normalization, instead of copying the remaining suffix and truncating it.
Measurements for the second
compare against the preserved first psh executable, not pristine Zsh.

The third change avoids general conversion calls for ASCII and byte-mode
characters while locating scalar indices. The conversion-state and offset rules
remain the same. The third
experiment compares against the preserved second psh executable.

The fourth change removes a redundant length scan within ordinary whole-array
list append. It introduces no persistent cache and leaves special/custom/tied
arrays on the original path. Repeated append remains quadratic. The current
development source includes all twenty-eight changes; the fourth experiment compares against
the preserved third executable. Its application controls include small measured
slowdowns as well as the targeted append gains; see the complete report.

The fifth change walks directly to a nonnegative search start, stopping at an
early match or deriving the missing index from the array terminator. Negative
starts, backward searches, scalar and associative searches retain their existing
paths. The fifth experiment compares against the preserved fourth executable.

The sixth change uses the existing nonempty-string check to establish the start
bound for a forward scalar pattern search from the beginning. Other starts and
backward searches retain their full character count. Matching and byte-offset
conversion still perform their existing work. Its measurements compare against
the preserved fifth executable.

The seventh change uses a bounded standard-library search for the first
internal Meta escape, retaining the original escape-pair handling afterward.
It is shared by matching and editor callers. Its measurements compare against
the preserved sixth executable. The existing scalar-search memory issue has a
[ready-to-send upstream report](Perf/bugs/scalar-search-terminator/report.txt)
and [attachment bundle](Perf/bugs/scalar-search-terminator-report.tar.gz).

The eighth change handles a star followed immediately by the matcher's end
marker without a character-boundary buffer. Multibyte traversal preserves its
conversion state; byte mode advances directly to the end. On heap-allocation
builds, unqueued calls retain the original path and its signal boundary.
Measurements compare against the seventh executable and include small measured
slowdowns alongside the targeted gains.

The ninth change skips groups of eight bytes whose high bits are all clear,
using bounded unaligned-safe loads. Non-ASCII bytes retain the existing converter
and its state; embedded NUL remains a byte in bounded matcher input. Platforms
without an exact 64-bit unsigned type and eight-bit bytes use scalar traversal.
Measurements compare against the eighth executable and include unchanged
application controls and a slower short late-match benchmark.

Mikael Magnusson's [scalar-search bounds fix](Perf/upstream-terminator-read.md)
is backported in a separate correctness commit. The original release baseline
and historical diagnostic logs remain intact.

The tenth change uses standard-library byte-set scanning between existing
substitution handlers. It retains process-substitution tokens and the extra
assignment markers required for assignment-like arguments. It introduces no
new cache, allocation, public symbol or string representation. Its measurements
compare against the ninth executable with the maintainer's bounds fix applied
to both builds.

The eleventh change keeps short and medium inputs on scalar traversal, while
long inert prefixes use a temporary byte set built from the current character
classification table. It preserves backslash-marker handling and the original
removal loop. Native checks include modified classification flags and full
allocation bytes; actual completion buffers also match pristine Zsh. Its
measurements compare against the preserved tenth executable.

The twelfth change handles long token-free prefixes through a private scanner
using small, freshly constructed classification sets. It retains the original
conversion loop and live token mappings. Both marker helpers now probe in
four guarded byte steps per group. GNU-family builds use a guarded no-inline
hint for the tail worker; correctness also passes with that hint omitted.
Its measurements compare against the preserved eleventh executable and retain
short-input and complete-application controls.

The thirteenth change unrolls full and bounded array-length scans into four
individually checked pointer steps. It requires no padding, keeps existing
unsigned-bound behavior, and changes no array representation or public API.
Late reads and slices improve on large arrays; complete application timings
remain close. Measurements compare against the preserved twelfth executable.

The fourteenth change applies the converter's existing ASCII width directly in
`itype_end()`, retaining live character classification, token precedence and
conversion state. Measurements now include actual input, world generation,
race simulation and geometry binning functions from the customer's projects.
Native checks compare with the original scanner across five encodings.

The fifteenth change finds the first Meta escape before entering the original
byte-count loop, or uses the standard byte length when there is no escape.
It improves the measured URL-encoding workload and retains diagnostic behavior.
Wide editor layout joins the customer controls; a slower Unicode scalar slice
is reported alongside the gains.

The sixteenth change groups character traversal while preserving conversion,
callback and allocation boundaries. Its project gains include URL encoding,
large HTML comment conversion and malformed-UTF-8 repair; slower controls are
retained. The accepted source is also packaged with matching native modules
for the installed daily driver.

The seventeenth change reduces character-count bookkeeping on raw ASCII runs,
resuming after completed multibyte handling. Long ASCII counts improve while
Unicode, Meta/NUL, explicit endpoints and conversion-state behavior are checked
against the original release implementation. Customer paste gains are smaller;
slower synthetic and application controls remain in the report.

The eighteenth accepted change uses an immutable private C locale for eligible
floating conversions, with the released conversion sequence as fallback.
Private thread locales and unusual character classifications retain that
fallback; failed locale creation preserves errno and also falls back. Native
checks compare value bits, rounding, floating exceptions, errno, global/thread
locale state and input bytes. The measured Mario and shooter kernels improve;
slower small scalar controls are retained in the full report.

The nineteenth accepted change lets the compiler inline the operand/operator
check performed after arithmetic tokens. The measured GCC build removes the
repeated call; other compilers may choose differently. Endgame uses fewer
instructions and CPU cycles, while project wall-time results and slower library
controls are retained, including a noisy first editor timing run and its repeat.
Expanded syntax comparisons check diagnostics and complete-case execution.

The twentieth accepted change remembers a validated array prefix in a small
private cache, so later in-range reads can avoid scanning that prefix again.
Setters and parameter destruction invalidate it; native mutable loans remain
on the scan path, including through cache eviction and in-place reallocation.
Special/custom/tied arrays and temporary anonymous arrays retain the original
path. No parameter layout or intended shell-language change is introduced.
Raw native field aliases must follow the documented ownership contract.
Unqueued calls use the original scan; no signal queue boundary is added.

The twenty-first accepted change adds an inline hint to the arithmetic operand
pop helper, keeping its complete body. The measured GCC build removes repeated
helper calls and combines stack bookkeeping in its caller. Endgame improves
about 4.5% in two idle runs; JSON array encoding is about 3% slower. The full
[round-twenty-three report](Perf/round23.md) retains both controls and an earlier
noisy run, plus operator/lvalue/callback/stack-limit comparisons and native
floating-state checks. No new language or native-interface difference is intended.

The twenty-second accepted change reuses confirmed array prefixes when seeking
the start of a forward pattern search. Matching and captures still run normally;
custom/special/tied arrays, mutable native loans and unqueued calls retain the
old walk. JSON parsing improves about 8–9% and validation about 10% in the
measured workloads. Slightly slower simulation/drawing controls are retained in
the [round-twenty-four report](Perf/round24.md). The existing native ownership
contract and signal boundaries remain unchanged.

The twenty-third accepted change merges the ASCII and internal-token branches
of the multibyte character classifier. ASCII reaches the same live class test
without first testing its token flag; conversion state and non-ASCII handling
remain unchanged. Endgame takes about 2% less time and Mario about 1–2% less in
two runs. Library controls are mixed; the [round-twenty-five report](Perf/round25.md)
retains all samples and the expanded native classification checks.

The twenty-fourth accepted change accelerates ordinary short decimal conversion
and hands longer/underscore continuations to the existing parser without
rescanning their validated prefix. Values, end pointers, errno and diagnostics
are compared with the original implementation. Coder paste takes about 1.3–1.4%
less time, chat paste about 1.7–2.6%, in the paired runs. The
[round-twenty-six report](Perf/round26.md) retains all controls and two rejected
restart variants, including a severe long-number slowdown caught by the API
benchmark. No new language or native-interface difference is intended.

The twenty-fifth accepted change prefilters option-default scans during
emulation, avoiding private setter calls for entries that cannot change.
The original setter still checks generated entries; all scanner bookkeeping
and signal boundaries remain. Chat paste takes about 4.6–4.9% less time and
JSON array parsing about 3–4.6% less in paired runs. The
[round-twenty-seven report](Perf/round27.md) retains slower controls, including
wide coder layout, and generated/native table and frontend coverage.
No new language or native-interface difference is intended.

The twenty-sixth accepted change reuses confirmed array prefixes before ordinary
whole-array append. Eligible assignments publish the prefix they constructed;
setters, destruction and mutable native getter loans retain their existing
invalidation/ownership rules. JSON array encoding takes about 2.7–3.7% less time
in paired runs. The [round-twenty-eight report](Perf/round28.md) includes all
controls, native loan/mutation checks and the rejected scanner revisit.
There is no new intended language or native-interface difference.

The [twenty-ninth investigation](Perf/round29.md) tests grouped unsigned string
hashing. It preserves hash values and reduces native hashing costs, but actual
installed-release customer timings are mixed. Both prototypes remain unadopted;
the executable retains twenty-six optimizations and its original hash function.
The investigation adds a pristine-source oracle, exact-size allocation and
protected-boundary checks, plus native key-length controls.

The [thirtieth investigation](Perf/round30.md) tests fused decimal token parsing.
Endgame improves, but repeated installed-build measurements show slower coder
paste, chat paste and JSON encoding. The prototype is not adopted; the active
release retains twenty-six optimizations. New native arithmetic boundary and
state checks remain available for future work.

The [thirty-first investigation](Perf/round31.md) tests arithmetic descriptor
allocation and compiler inlining. The descriptor buffer has mixed customer
results, the parser hint produces identical object code, and the accessor hint
increases Endgame instructions. These private trials are not adopted. Expanded
recursive lookup and lvalue tests remain available for future work.

The [thirty-second investigation](Perf/round32.md) measures structural costs:
function-return cleanup walks all parameter-table entries and buckets, while
integer powers multiply once per exponent step. Adding 512 unrelated globals
slows existing editor paste kernels substantially in controlled child processes.
The report prioritizes scope bookkeeping, arithmetic execution plans, option
defaults and container growth. These are research findings; the installed
executable still contains twenty-six accepted optimizations.

The [thirty-third investigation](Perf/round33.md) implements logarithmic integer
powers and checks arithmetic results, native state and unchanged Oh My Zsh.
Large powers improve dramatically, but repeated installed comparisons show
slower coder/chat paste and JSON kernels. The candidate and an exploratory
alignment variant are shelved. The active release and developer executable are
restored unchanged; new native power checks and the full evidence remain.

The [thirty-fourth investigation](Perf/round34.md) filters scope cleanup by each
parameter's live level before calling the original restoration callback. Private
profiles and dense-namespace controls improve, but installed paste gains do not
persist and JSON kernels slow down. The candidate is shelved; callback mutation
tests, paired scope benchmarks and all results remain. The active release still
contains twenty-six accepted optimizations.

The [twenty-seventh accepted change](Perf/round35.md) indexes buckets that may
contain local parameters. Repeated installed measurements show coder/chat paste
taking about 8% less time, simulation kernels about 4% less, and JSON kernels
3–6% less. Existing native modules retain legacy scope scanning; audited modules
opt in explicitly. The new private rc0 iteration is active, with all seven
package suites and 24 unchanged Oh My Zsh sessions passing. URL encoding has
a retained roughly 1% slowdown. No Zsh language divergence is intended.

The [round-thirty-six investigation](Perf/round36.md) tests fusing option-default
traversal with its writes. Lower instruction counts do not yield useful customer
timings, so both proposals remain shelved. Native regression coverage now also
checks recursive generated option providers. The active build still contains
27 accepted optimizations.

The [round-thirty-seven maintenance iteration](Perf/round37.md) pairs arithmetic
state saves/restores, documents ownership and shared results, and adds recursive
state/error-recovery tests. The development builder now isolates pristine native
modules from psh's modules. The new private rc0 iteration is active after seven
package suites and 24 unchanged OMZ sessions. Core machine code and all 40 native
module text sections remain identical; this adds no new speedup to the count of
27 optimizations.

The [thirty-ninth investigation](Perf/round39.md) measured an additional
thread-locale float-formatting optimization. The [fortieth investigation](Perf/round40.md)
withdraws it after reproducing changed native callback behavior through libc
conversion plugins and explicit ELF preloading. The original output converter is
restored; five optional SDK exports remain inert for binary compatibility.
That withdrawal returns the core optimization count to 27. A mandatory native-library gate
now complements the unchanged OMZ gate. Publication and activation remain held.

The [twenty-eighth accepted change](Perf/round44.md) releases temporary shell-code
glob programs after each evaluation, adapting an upstream lifetime improvement.
Legacy native parsers retain their signatures and arena-backed ownership.
Repeated 10,000-file long-qualifier measurements use about 19% less peak resident
memory and take 17–19% less time; customer kernels remain effectively flat.
Escaping functions/traps and old-header native callers pass focused checks,
alongside the package, OMZ and native-library gates. The candidate is inactive.
