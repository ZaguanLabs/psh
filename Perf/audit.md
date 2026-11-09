# Source-review map

This is the starting map for psh, not a completed source audit. Review coverage
below describes focused paths only; no complete file or subsystem is certified.

| Area | Sources | Status / next evidence |
| --- | --- | --- |
| Indexed arrays | `Src/params.c`, array helpers in `Src/utils.c` | First candidate: short-prefix replacement. Fourth candidate reuses the old length within ordinary whole-array list append; custom accessors retain the old path. Fifth candidate avoids a full length scan before forward pattern searches with nonnegative starts. Repeated append remains quadratic and scalar append still scans twice. Round twenty-two caches eligible confirmed read bounds, resumes larger probes at the validated boundary, and preserves scanning for mutable native loans and unqueued calls. Thirteenth candidate groups full and bounded pointer scans without changing representation or unsigned boundary behavior; native exact-allocation checks pass. |
| Expansion and scalar traversal | `Src/subst.c`, `Src/params.c` | Second candidate bounds scalar copying. Third candidate inlines the conversion routine's existing fast widths during positive/negative scalar index traversal. Fifth candidate avoids counting arrays before eligible forward searches. Sixth candidate skips the full scalar character count for forward pattern searches from the beginning. Tenth candidate uses byte-set scanning for inert spans in both passes of `stringsubst()`, retaining process/substitution handlers and assignment-marker order. Other starts and backward scalar searches retain their count. Sixteenth candidate groups numeric scalar traversal into guarded eight-character ASCII steps, resuming after Unicode/Meta characters and preserving the final character width. Scalar traversal and uncached positive array prefix validation remain linear. |
| Pattern compilation and matching | `Src/pattern.c`, matching in `Src/glob.c`, `ztrsub()` in `Src/utils.c` | Seventh candidate skips Meta-free prefixes in the byte-length helper. Eighth candidate omits unused terminal-star boundary storage, preserves conversion state, and retains unqueued heap calls on the original path. Focused native offset/cache tests and five-locale pattern comparisons pass. Ninth candidate scans terminal-star ASCII runs with bounded word loads; allocation-boundary and scalar-fallback checks pass. Eleventh candidate skips long inert prefixes in `remnulargs()` with a fresh classification set and length gate. Native full-buffer tests include changed `INULL` flags; PTY completion cases match pristine Zsh. Twelfth candidate adds token-free prefix scanning to `untokenize()`, preserves live mappings and classifications, and groups both probes without unchecked word loads. Native full-buffer/mapping tests and extended PTY buffers pass. Other backtracking paths, non-ASCII conversion and general search remain profiling targets. |
| Character classification | `itype_end()` and `mb_metacharlenconv()` in `Src/utils.c` | Fourteenth candidate bypasses the converter for its existing ASCII width, retaining token precedence, live flags and initial state reset. Original-scanner native comparisons pass across five encodings and changed word/separator sets. Customer input, simulation and binning profiles guide the change. Other classification helpers remain unreviewed. |
| Character and display-width counts | `mb_metastrlenend()` in `Src/utils.c` | Seventeenth candidate scans nonzero ASCII at complete-character boundaries, preserving width quirks, conversion state and the original Meta/incomplete paths. Pristine-reference native checks cover widths, endpoints, buffer bytes and state continuations across five encodings. Traversal remains linear; ASCII after a decoded NUL retains the old loop until multibyte handling completes. Other counting and display-width helpers remain unreviewed. |
| Hash-table traversal | `scanmatchtable()` and `scanhashtable()` in `Src/hashtable.c` | Round eighteen investigated unfiltered dispatch in the generic matcher and its simpler wrapper. Both variants reduced scanner instructions but were rejected after mixed customer wall-time results. Public-API fixtures cover callback traces/counts, additions/removals/replacements, flags, sorting, generated-table delegation and queue nesting. The original core implementation is retained; no table representation or mutation protocol change is adopted. |
| Arithmetic | `Src/math.c`, `execarith()` in `Src/exec.c`, `Src/loop.c` | Round nineteen traces execution into repeated runtime parsing, the private math stack, parameter-value allocations and recursive state saves. An accepted private C-locale conversion helper avoids repeated global locale switching for ordinary floating literals, with declaration/link probing and legacy fallback for private thread locales, unusual prefixes, API absence and allocation failure. Native rounding/errno/state and high-level emulation/callback comparisons pass. Endgame spends 48.6% of baseline self instructions in math.c; syntax/value caches are research only because lookup, callbacks, options, errors and floating state are dynamic. Round twenty adds an inline hint to the existing per-token operand/operator checker, keeping its complete body and signal/evaluation boundaries. Expanded syntax comparisons check malformed input, diagnostics and emulation; two extracted error-handler variants were rejected after project/control measurements. |
| Function execution / local parameters | `Src/exec.c`, `Src/params.c` | Round eighteen traced full parameter-table walks and `scanendscope()` callbacks. A standalone regression checks restoration of 129 shadowed/unset locals, arrays, hashes and exports through nested scopes. The original lifecycle implementation is retained. Other function execution remains unreviewed beyond initial orientation. |
| Metafied byte counts | `ztrlen()` in `Src/utils.c` | Fifteenth candidate skips the prefix before the first Meta escape, retaining the original pair loop and debug diagnostic. Matching-header native tests cover multibyte/no-multibyte builds, exact ends, byte-mode wrappers and known raw lengths. URL encoding improves; a slower Unicode scalar control is retained and actual wide editor layout remains close. Repeated caller scans remain quadratic. |
| Allocation / internal containers | `Src/mem.c`, `Src/hashtable.c`, `Src/linklist.c`, `Src/string.c` | Round nineteen reads the zhalloc arena/queue/accounting path and math operand allocations. zhalloc accounts for about 3–4.9% of baseline self instructions in five customer/library profiles. Round nineteen adopts no allocator, ownership, representation or public ABI change. Round twenty-two separately adds private bounds metadata and an explicit native ownership contract, without changing structure layout. Other container/allocation paths remain unreviewed. |
| Parsing / wordcode | `Src/lex.c`, `Src/parse.c`, `Src/text.c` | Unreviewed. Separate cold parsing from repeated execution. |
| Builtins, filesystem and process I/O | `Src/builtin.c`, `Src/utils.c`, `Src/glob.c`, `Src/input.c` | Unreviewed outside cited helpers. Separate syscall and interpreter cost. |
| Signals, jobs, initialization, options | `Src/signals.c`, `Src/jobs.c`, `Src/init.c`, `Src/options.c` | Eighth-round review covers the heap allocator's queue/unqueue boundary and preserves it for unqueued terminal-star calls. Native results are checked at queued and unqueued levels. Other signal/job/initialization behavior remains unreviewed beyond upstream checks; no exhaustive asynchronous trap audit is claimed. |
| Editor / completion / history / prompt | `Src/Zle/`, `Src/hist.c`, `Src/prompt.c` | Focused shared-helper coverage for `ztrsub()` and `remnulargs()`, including native allocation checks, upstream PTY completion scripts and 24 long-prefix quoted/unquoted completion buffers. Other editor behavior remains unreviewed; no editor-specific optimization yet. |
| Native modules | `Src/Modules/` | Broad module audit remains open. Round twenty-two checks public mutable getter loans and the bundled native sources for raw array-field access; matching-SDK builds and project suites accompany the documented ownership contract. Measure other module boundary costs separately. |
| Shipped shell systems | `Functions/`, `Completion/`, `StartupFiles/` | Unreviewed. Include in eventual source-wide review. |

The [customer workload coverage map](customer-projects.md) records active kernels
and pending integration for all twenty projects. The listed applications supply
workload families, not interchangeable scores:

- Parsing: zjson, zoup, zhtml2md, zfetch and zbrowser.
- Streaming/UI orchestration: zchat.zsh and zcoder.zsh; zchatd is a Go service
  and is outside interpreter CPU measurements.
- Simulation: endgame, z3dfx, z3dfx.agy, z3dfx.grok and z3dfx.mario.
- Scene construction / retained rendering: zanimation, universe and
  z3dfx.drawing; native/GPU/terminal time needs separate attribution.
- Native module boundaries: zcurl, zdraw and zmdown.
- zdist is a separate compiler/runtime experiment; its design may inform
  research but does not establish behavior-preserving interpreter changes.

For each future candidate: reproduce the cost, inspect ownership and semantics,
make a bounded change, compare against pristine behavior, classify any deliberate
divergence under the current compatibility policy, run relevant upstream and
application checks and the required unchanged-OMZ gate, then measure gains and
control cases on idle builds. Full Zsh equivalence is no longer mandatory;
known Oh My Zsh regressions still block adoption.

[Round twenty-one](round21.md) establishes the required interactive Oh My Zsh
gate and refreshes five customer/library instruction profiles on the actual
release build. Array-existence scans, arithmetic parsing and scope-table walks
remain concrete targets. These profiles are not new speedup measurements or
adopted representation/cache changes in that round.

[Round twenty-two](round22.md) follows `arrlen_ge()` through ordinary read and
slice bounds, rather than assuming its cost comes only from `[[ -v ]]`. It
caches confirmed positive prefixes for ordinary owned arrays and invalidates
them on setters/destruction. Mutable native getter loans opt the allocation
out; persistent loan state survives cache eviction and in-place realloc.
The initial full-length-counting prototype is retained with its shallow-query
regression. The final prefix cache never counts beyond the query's bound.
This adds private metadata and a parameter flag; native modules must follow
the documented getter/setter ownership contract. It does not make append,
negative-index reads, length expansion or general array processing constant time.

[Round twenty-three](round23.md) profiles the current release again and finds
the arithmetic operand-pop helper accounting for 4.05% of Endgame instructions.
An inline hint preserves its full body while removing the separate call in the
measured GCC build. Expanded differential checks cover valid operators, lazy
lvalue reads, parameter replacement/retyping, recursive callbacks, short-circuit
side effects and stack boundaries. Endgame improves; slower JSON controls and
an initial run affected by external compilation remain in the evidence.

[Round twenty-four](round24.md) follows a line-level JSON profile into repeated
walks to forward array-search starts. It reuses already confirmed prefixes,
then validates any remaining pointers once, stopping at the terminator. Pattern
matching and callbacks retain their order. The existing ownership and queued
signal requirements apply; custom snapshots and mutable native loans keep the
original path. Large-start, mutation, native-loan and unqueued-search checks
extend coverage; this does not make all pattern matching constant-time.

Round-six Memcheck coverage also found an [existing scalar-search terminator
read](upstream-terminator-read.md), reproduced in pristine Zsh. Mikael Magnusson’s two bounds guards have since been backported in a separate
correctness commit; the saved Memcheck corpus now reports zero errors.

Round nineteen adds [a deeper profile and research map](round19.md), including
user-space hardware counters and five complete instruction profiles. These
measurements identify costs in actual project kernels; they do not establish
that every array walk or allocation is redundant. The small zjson scaling probe
is approximately linear over its measured range, so it does not substantiate
a general quadratic-runtime claim.

[Round twenty-five](round25.md) revisits the multibyte `itype_end()` loop using
fresh release profiles. Its ASCII and internal-token branches have identical
width and live-classification work; merging them lets ASCII avoid the token
flag check. Conversion initialization, non-ASCII processing, byte mode and
signal boundaries remain unchanged. Native coverage adds combined class masks,
more prefix lengths and non-boolean `once` values, checked against the original
release implementation and subsequent converter state.

[Round twenty-six](round26.md) follows integer-conversion cost into
`zstrtol_underscore()`. A word-size-bounded decimal prefix avoids general sign,
base and overflow work; continuations seed the original loop rather than
restarting. The original input pointer and zero sign are restored for identical
truncation checks and diagnostics. A direct public-API oracle covers values,
consumed bytes, errno, error flags, exact diagnostic bytes and input integrity,
including changed leading-blank classification. Two restarting prototypes and
their long/underscore costs remain in the evidence.

[Round twenty-seven](round27.md) moves necessary option-selection conditions
into the existing hash scanner at the `installemulation()` call site. Option-name
aliases never need the setter; partial emulation additionally requires
`OPT_EMULATE`. The original callback still handles all selection rules because
generated scanners ignore masks. Scanner code, live bucket order, callback
mutation bookkeeping and signal boundaries remain unchanged. A queued-only
unchecked-setter trial did not enter its fast path in customer profiles and is
retained. Native output-alias/live-flag tests and frontend scope/trace/sticky
autoload comparisons extend the focused coverage.
