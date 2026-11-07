# Source-review map

This is the starting map for psh, not a completed source audit. Review coverage
below describes focused paths only; no complete file or subsystem is certified.

| Area | Sources | Status / next evidence |
| --- | --- | --- |
| Indexed arrays | `Src/params.c`, array helpers in `Src/utils.c` | First candidate: short-prefix replacement. Fourth candidate reuses the old length within ordinary whole-array list append; custom accessors retain the old path. Fifth candidate avoids a full length scan before forward pattern searches with nonnegative starts. Repeated append remains quadratic, scalar append still scans twice, and prefix validation remains linear. Thirteenth candidate groups full and bounded pointer scans without changing representation or unsigned boundary behavior; native exact-allocation checks pass. |
| Expansion and scalar traversal | `Src/subst.c`, `Src/params.c` | Second candidate bounds scalar copying. Third candidate inlines the conversion routine's existing fast widths during positive/negative scalar index traversal. Fifth candidate avoids counting arrays before eligible forward searches. Sixth candidate skips the full scalar character count for forward pattern searches from the beginning. Tenth candidate uses byte-set scanning for inert spans in both passes of `stringsubst()`, retaining process/substitution handlers and assignment-marker order. Other starts and backward scalar searches retain their count. Sixteenth candidate groups numeric scalar traversal into guarded eight-character ASCII steps, resuming after Unicode/Meta characters and preserving the final character width. Scalar traversal and positive array prefix validation remain linear. |
| Pattern compilation and matching | `Src/pattern.c`, matching in `Src/glob.c`, `ztrsub()` in `Src/utils.c` | Seventh candidate skips Meta-free prefixes in the byte-length helper. Eighth candidate omits unused terminal-star boundary storage, preserves conversion state, and retains unqueued heap calls on the original path. Focused native offset/cache tests and five-locale pattern comparisons pass. Ninth candidate scans terminal-star ASCII runs with bounded word loads; allocation-boundary and scalar-fallback checks pass. Eleventh candidate skips long inert prefixes in `remnulargs()` with a fresh classification set and length gate. Native full-buffer tests include changed `INULL` flags; PTY completion cases match pristine Zsh. Twelfth candidate adds token-free prefix scanning to `untokenize()`, preserves live mappings and classifications, and groups both probes without unchecked word loads. Native full-buffer/mapping tests and extended PTY buffers pass. Other backtracking paths, non-ASCII conversion and general search remain profiling targets. |
| Character classification | `itype_end()` and `mb_metacharlenconv()` in `Src/utils.c` | Fourteenth candidate bypasses the converter for its existing ASCII width, retaining token precedence, live flags and initial state reset. Original-scanner native comparisons pass across five encodings and changed word/separator sets. Customer input, simulation and binning profiles guide the change. Other classification helpers remain unreviewed. |
| Character and display-width counts | `mb_metastrlenend()` in `Src/utils.c` | Seventeenth candidate scans nonzero ASCII at complete-character boundaries, preserving width quirks, conversion state and the original Meta/incomplete paths. Pristine-reference native checks cover widths, endpoints, buffer bytes and state continuations across five encodings. Traversal remains linear; ASCII after a decoded NUL retains the old loop until multibyte handling completes. Other counting and display-width helpers remain unreviewed. |
| Hash-table traversal | `scanmatchtable()` and `scanhashtable()` in `Src/hashtable.c` | Round eighteen investigated unfiltered dispatch in the generic matcher and its simpler wrapper. Both variants reduced scanner instructions but were rejected after mixed customer wall-time results. Public-API fixtures cover callback traces/counts, additions/removals/replacements, flags, sorting, generated-table delegation and queue nesting. The original core implementation is retained; no table representation or mutation protocol change is adopted. |
| Arithmetic | `Src/math.c`, `execarith()` in `Src/exec.c`, `Src/loop.c` | Initial sampling shows runtime parsing; caching is not yet proposed for implementation. Preserve dynamic lookup and evaluation effects. |
| Function execution / local parameters | `Src/exec.c`, `Src/params.c` | Round eighteen traced full parameter-table walks and `scanendscope()` callbacks. A standalone regression checks restoration of 129 shadowed/unset locals, arrays, hashes and exports through nested scopes. The original lifecycle implementation is retained. Other function execution remains unreviewed beyond initial orientation. |
| Metafied byte counts | `ztrlen()` in `Src/utils.c` | Fifteenth candidate skips the prefix before the first Meta escape, retaining the original pair loop and debug diagnostic. Matching-header native tests cover multibyte/no-multibyte builds, exact ends, byte-mode wrappers and known raw lengths. URL encoding improves; a slower Unicode scalar control is retained and actual wide editor layout remains close. Repeated caller scans remain quadratic. |
| Allocation / internal containers | `Src/mem.c`, `Src/hashtable.c`, `Src/linklist.c`, `Src/string.c` | Unreviewed outside the focused hash-scan investigation. Require profiles and clear ownership invariants. |
| Parsing / wordcode | `Src/lex.c`, `Src/parse.c`, `Src/text.c` | Unreviewed. Separate cold parsing from repeated execution. |
| Builtins, filesystem and process I/O | `Src/builtin.c`, `Src/utils.c`, `Src/glob.c`, `Src/input.c` | Unreviewed outside cited helpers. Separate syscall and interpreter cost. |
| Signals, jobs, initialization, options | `Src/signals.c`, `Src/jobs.c`, `Src/init.c`, `Src/options.c` | Eighth-round review covers the heap allocator's queue/unqueue boundary and preserves it for unqueued terminal-star calls. Native results are checked at queued and unqueued levels. Other signal/job/initialization behavior remains unreviewed beyond upstream checks; no exhaustive asynchronous trap audit is claimed. |
| Editor / completion / history / prompt | `Src/Zle/`, `Src/hist.c`, `Src/prompt.c` | Focused shared-helper coverage for `ztrsub()` and `remnulargs()`, including native allocation checks, upstream PTY completion scripts and 24 long-prefix quoted/unquoted completion buffers. Other editor behavior remains unreviewed; no editor-specific optimization yet. |
| Native modules | `Src/Modules/` | Unreviewed. Maintain module ABI and measure boundary overhead separately. |
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
make a bounded change, compare against pristine behavior, run relevant upstream
and application checks, then measure gains and control cases on idle builds.

Round-six Memcheck coverage also found an [existing scalar-search terminator
read](upstream-terminator-read.md), reproduced in pristine Zsh. Mikael Magnusson’s two bounds guards have since been backported in a separate
correctness commit; the saved Memcheck corpus now reports zero errors.
