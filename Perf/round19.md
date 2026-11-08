# Round nineteen: arithmetic locale conversion and a deeper review

The broader investigation found a surprisingly large cost outside Zsh's own
parser: every floating literal queried, copied, changed and restored the global
numeric locale. In the accepted round-seventeen Mario profile, 34,424 floating
conversions caused 103,272 `setlocale()` calls. Their inclusive instruction
cost was 238,180,394, about **34.0% of the complete process**. Copying the saved
locale name added another 3,140,328 instructions. Most of this was libc locale
lookup and reconstruction, not decimal conversion.

The [accepted patch](0019-numeric-locale-conversion.patch) uses an immutable
private C locale for eligible floating conversions. It is the **eighteenth
accepted optimization**: round eighteen's hash-scan variants remain rejected.
The incremental patch applies to `104846b`, after the round-seventeen core and
the round-eighteen test/documentation changes.

## Source review and boundaries

`execarith()` retrieves the expression from wordcode and calls `matheval()` on
every execution. It duplicates token-containing strings when required; it does
not unconditionally copy every expression. `mathevall()` maintains a private
100-element math-value stack and saves/restores parsing state for recursive
calls. Parameter lookup can invoke getters and math functions; those callbacks
can change parameters, options, locales and subsequent evaluation. A persistent
syntax or value cache therefore needs much more than a string-key lookup.

`lexconstant()` formerly changed `LC_NUMERIC` to POSIX for every floating
literal and then restored it. The new private `math_strtod()` helper:

- Uses `strtod_l()` with a lazily created immutable C locale when the input
  starts with an ASCII digit or dot and the current thread uses the global locale.
- Preserves the original conversion sequence for a private thread locale,
  an unusual public character classification, unavailable APIs or failed locale
  creation. In particular, a private comma-decimal locale keeps the release's
  existing evaluation errors; it is not silently changed to C semantics.
- Preserves incoming errno around locale discovery/creation, then returns the
  conversion's errno and floating exceptions normally. Rounding mode remains
  the caller's. The cached locale lives for the process lifetime and contains
  no parsed expressions, parameter values or shell-option state.
- Keeps underscore normalization, constant recognition, parser precedence,
  error checks and callbacks on their existing paths. GNU-family builds use
  a guarded no-inline hint to keep locale setup out of the integer lexer.

Configure requires declarations and linking for the complete locale-object
API, including `locale_t`, category masks and the global-thread sentinel.
`xlocale.h` is included only when available. The probe is link-only and does
not require target execution when cross-compiling. `zsh_cv_math_strtod_l=no`
selects the original conversion sequence. Builds without `setlocale()` retain
the original plain `strtod()` behavior.

The release's tracked configure was generated with Autoconf 2.73, while this
host provides 2.72. Only the newly generated probe was inserted into that
release script, avoiding an unrelated full-script downgrade. `configure.ac`
and `config.h.in` are updated too. The development build tests the narrow
release-script update; packaging regenerates configure with 2.72 in its private
copy and tests that route independently.

This changes no public structures, exported names, module identities or numeric
syntax. It does not implement an arithmetic compiler, change array storage or
replace the allocator.

## Measurements

Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, debug assertions and
multibyte support. Nine alternating fresh-process samples per build, CPU 2,
C.UTF-8, own builds/tests/profilers idle during timing. All final timing tables
use the same accepted development binary against the saved round-seventeen
executable. Library loading, construction and warm-up precede the warm timers;
workload resets/preparation retain the existing benchmark definitions. Checked
outputs/states match. Every sample and source/binary/worker hash is retained in
[the results](results/round19/).

Customer kernels, milliseconds per complete batch:

| Kernel | Previous psh | Candidate | Ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 119.654 | 113.368 | 1.06x |
| zcoder.zsh/coder-layout | 5.764 | 5.771 | 1.00x |
| zcoder.zsh/coder-wide-layout | 95.084 | 94.879 | 1.00x |
| zchat.zsh/chat-paste | 212.810 | 206.538 | 1.03x |
| zchat.zsh/chat-layout | 5.795 | 5.776 | 1.00x |
| zchat.zsh/chat-wide-layout | 95.558 | 95.488 | 1.00x |
| endgame/endgame-world | 47.834 | 47.601 | 1.00x |
| z3dfx.mario/mario-race | 29.372 | 20.201 | 1.45x |
| z3dfx/shooter-step | 14.982 | 11.998 | 1.25x |
| z3dfx.agy/shooter-step | 14.958 | 11.908 | 1.26x |
| z3dfx.grok/shooter-step | 14.978 | 12.015 | 1.25x |
| zfetch/fetch-encode | 13.349 | 13.290 | 1.00x |
| z3dfx.drawing/drawing-binning | 14.599 | 14.549 | 1.00x |

Mario improves **1.45x**, the three shooter kernels **1.25–1.26x**.
The zcoder paste median is **5.3% lower**, zchat paste **2.9% lower**. Endgame,
drawing, URL encoding and ordinary/wide editor layout remain close; ordinary
zcoder layout is about 0.1% slower. These are offline kernels, not application
startup, terminal frame rate or complete-session measurements.

Warm library calls, milliseconds per call:

| Operation | Previous psh | Candidate | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 100.310 | 100.044 | 1.00x |
| zjson-encode-array | 217.165 | 214.032 | 1.01x |
| zjson | 97.117 | 96.280 | 1.01x |
| navigation | 2.246 | 1.999 | 1.12x |
| html-comment-1m | 131.064 | 129.917 | 1.01x |
| html-prose-100k | 128.893 | 128.036 | 1.01x |
| json-repair-100k | 19.467 | 19.689 | 0.99x |
| html-clean-128 | 101.462 | 99.964 | 1.01x |

JSON repair is **1.1% slower**. The complete scalar controls also retain slower
medians: mixed-text suffix **1.232 → 1.464 ms per 20 calls**, an **18.8%** increase;
full 10,000-character slicing **18.390 → 19.432 ms**, a **5.7%** increase. Some
short ASCII controls are around 3–5% slower. Long ASCII and Unicode character
counts remain close. These costs are part of the adoption tradeoff, not omitted
as noise. No aggregate score is used.

An earlier inline implementation retained the main simulation gains but made
URL encoding about 4.6% slower and JSON repair about 8.7% slower in its own
paired run. It was rejected. Extracting the locale helper brought these controls
closer to their previous timings; code layout and integer-lexer register
pressure are plausible factors, not established causal explanations. All four
inline timing matrices, hardware samples, exact source diff and hashes remain
under `results/round19/inline-*`. Pilot results are separate from final tables.

## Hardware evidence and instruction profiles

The new Linux diagnostic launcher uses unprivileged `perf_event_open()` for
user-space cycles, instructions, branches and branch misses. It changes no
system settings. A deterministic self-test checks child inheritance, combined
work, output and nonzero command status. Raw event values and enabled/running
times are retained; the driver rejects less than 95% scheduled time. These
runs used fully scheduled events.

Median user-space cycles **from exec through exit**, including inherited tasks:

| Kernel | Previous cycles | Candidate cycles | Reduction |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 751,837,446 | 722,278,268 | 3.93% |
| endgame/endgame-world | 459,348,132 | 454,688,229 | 1.01% |
| z3dfx.mario/mario-race | 288,483,995 | 194,002,418 | 32.75% |
| z3dfx.drawing/drawing-binning | 195,432,120 | 193,803,595 | 0.83% |

These counters include startup, loading, construction and warm-up; the worker's
warm-batch timer has a different scope. Mario's instruction median falls from
698,649,148 to 460,989,696. zcoder instructions are almost unchanged even though
its cycles and warm time improve, so its gain is not attributed to removed
locale work. Branch misses also fall in that kernel. Counts alone do not prove
a microarchitectural cause. Rusage and wall time are recorded separately.

Matched Callgrind instruction totals, also including startup and warm-up:

| Kernel | Previous instructions | Candidate instructions | Reduction |
| --- | ---: | ---: | ---: |
| mario | 701,490,283 | 461,517,574 | 34.21% |
| shooter | 443,029,440 | 370,726,472 | 16.32% |
| endgame | 1,277,024,605 | 1,277,039,540 | -0.0012% |
| coder | 1,440,165,818 | 1,439,684,349 | 0.03% |

The tiny negative Endgame percentage represents an increase of 14,935
instructions, about 0.0012%; it is not a meaningful instruction reduction.
Flat reports and compressed raw profiles are retained. The original Mario
source annotation uses the saved original `math.c`, rather than attributing
old line numbers to the modified source.

## Larger opportunities still open

Five baseline whole-process profiles identify these focused costs. Percentages
are **self instructions**, summed without inclusive-call double counting:

| Workload | Observed cost | Next research / compatibility constraint |
| --- | --- | --- |
| Endgame | `math.c` 48.6%; integer conversion another 4.7% | Repeated arithmetic lexing/parsing is a major target. Any private compiled form must preserve dynamic lookup, lvalue evaluation, recursive callbacks, option changes, diagnostics/error ordering and floating state. No cache is adopted. |
| Drawing binning | Array-length helpers 14.2%; `math.c` 22.9% | Repeated prefix validation is significant. Public null-terminated pointer arrays and custom/module accessors prevent casually attaching persistent length metadata. |
| zjson array encoding | Array-length helpers 11.4%; generic hash scanning 8.7% | Trace repeated callers and ownership before changing containers or scope bookkeeping. Round eighteen already rejected two narrower scanner variants on customer timings. |
| zjson validation | `getarg()` 12.5%; array lengths 8.2%; hash scanning 6.8% | Subscript normalization, range flags, encodings and getter effects need separate profiles and bounded proposals. |
| All five profiles | `zhalloc()` 3.0–4.9% | Pool allocation, signal queueing, arena lifetime and math operand `Value` allocation merit investigation. Embedding values enlarges the automatic math stack; no allocator or stack-layout change is adopted. |

A new baseline-only scaling probe calls the actual zjson library at
250/500/1,000/2,000/4,000 elements. Validation medians are
11.374/23.200/45.965/97.625/205.640 ms; array encoding is
12.848/25.081/50.499/103.071/216.811 ms. This range is approximately linear
with a modest increasing cost per item. It **does not establish quadratic
application runtime** or isolate array scanning as the sole scaling cause.
The original project is unchanged; each call checks its result.

This is a measured research map, not a complete source audit. Arithmetic,
array provenance, scope teardown and allocation are distinct future experiments.
The [source-review map](audit.md) records the focused coverage and remaining work.

## Compatibility evidence

- **62 upstream development scripts pass, zero failures, three expected skips.**
  The new arithmetic regression also passes on pristine Zsh, alongside the
  focused subscript/multibyte scripts.
- **15,300 high-level arithmetic comparisons** match pristine stdout, stderr
  and status across five locales, native/ksh/sh emulation, four option contexts,
  assignment/evaluation effects, math callbacks and callback locale changes.
- The native fixture passes **535,552 checks across 16 Memcheck processes** for
  normal builds, and the same total for matching-header no-multibyte builds.
  Each host/locale performs 33,472 checks using global and private French thread
  locales, all four rounding modes, FORCEFLOAT/OCTALZEROES both off or both on,
  underscore/sign forms,
  subnormal/overflow/underflow boundaries, large integer parts, exact allocation
  ends and two input alignments. It compares type/value bits, errno, floating
  exceptions, error flags, complete input bytes and global/thread locale state.
  Modified public character flags test the unusual-prefix fallback.
- Failed C-locale creation under an LD_PRELOAD interposer, forced API absence,
  and a separately configured no-`setlocale()` baseline/candidate pair each
  pass **200,832 native checks across six Memcheck processes** in C, C.UTF-8 and
  French. Forced-fallback and no-locale arithmetic corpora also match; their
  arithmetic upstream scripts pass. No-locale native oracles use the release's
  plain conversion sequence. **Zero Memcheck memory errors**, leak checks off.
- The no-multibyte build also passes its available substitution, conditional
  and arithmetic scripts, plus **281,834 scalar comparisons**. Normal builds
  match **704,585 scalar, 5,192 array, 193,236 search, 159,600 pattern and 2,640
  substitution comparisons**, 20 native accessor cases and 36 PTY completion
  buffers. These retain coverage of the preceding optimizations.
- Twenty-four customer kernel/locale comparisons match pristine state/output.
  Original zjson, zoup, shooter, Endgame and AGY/Grok suites match; all 307
  zhtml2md checks pass using its child-shell override.
- All **1,847 pristine file hashes**, the preceding round-eighteen snapshot,
  **1,055 exported names/types** and eight generated public declaration files
  match their respective references. The incremental patch reconstructs every
  changed source/configuration/regression file.

These tests provide focused evidence. They do not prove complete-shell
behavioral equivalence, certify other operating systems, or exhaust asynchronous
signal, module-threading or allocator-failure combinations.

## Daily driver

The accepted source is packaged as **`5.9.2-b674dd30e573`**, with matching native
modules and all six pinned projects. Package validation, activation and stable
installation checks are recorded in [the installation report](results/round19/installed-package.json).
The packaged core passes **63 scripts with two expected skips**, all six bundled
project suites, installed change-gutter rendering and interactive login startup.
Its native arithmetic fixture passes **200,832 checks across six Memcheck
processes** using pristine and installed hosts in three locales.

All **11,828 protected Zsh/startup entries**, `/etc/shells`, the account login
shell and the complete previous release manifest are unchanged. The old release
remains available to existing sessions and for rollback. Start a new psh process
to use the activated release. Production paths/configuration make its executable
different from the development timing binary.

Development timing SHA256:
`f7e6d87f5c5ceaad3460862dc39dc3009826ec7b258e8e8173552bb5e1b4b7ff`.
Previous timing SHA256:
`4b4ed9e3baca23c896bb76ad6f28b6c997fdf8625794a86ea75809b9e4a1bc98`.

Reproduction commands are in [the workflow](README.md#deeper-arithmetic-and-locale-review).
Private build/install logs and protected-file snapshots remain local under
`.work/logs/round19/` and `.work/package/5.9.2-b674dd30e573/`.
