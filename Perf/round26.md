# Round twenty-six: decimal prefixes without restarting conversion

The twenty-fourth accepted optimization accelerates ordinary positive decimal
conversion in `zstrtol_underscore()`. A complete bounded decimal returns directly;
a continuation seeds the original conversion loop with the validated prefix.
It does not restart that loop from the beginning.

The [incremental patch](0026-decimal-prefix-conversion.patch) applies after
`402746ade22e5a9e8fc80702d4bce53455a62d06`. Version **1.0.0-rc0**, public
interfaces, structures, array ownership and intended language behavior remain
unchanged. The original truncation rules and diagnostic bytes are preserved.

## Profile and invariant

Fresh profiles use the actual installed `1.0.0-rc0-d9a609a3adc3` and the author's
projects. Endgame spends **59,648,781 self instructions**, about **5.2%**, in
integer conversion. Most of the function supports signs, base selection,
underscores and truncation; ordinary short positive decimals need less work.

The new path requires **explicit base 10** and a first byte that the live public
classification table does not consider a leading blank. It reads literal decimal
digits, bounded at **18 on 64-bit-or-wider `zlong`, nine on 32 bits**. Even the
largest prefix fits the signed type, including intermediate arithmetic. The
bound comes from integer capacity, not storage layout or a cache assumption.
A non-decimal continuation returns the value/end pointer directly unless an
underscore is enabled and needs further parsing.

Otherwise a nonempty prefix transfers four values into the original loop:
`calc` is its accumulated value, `inp` is the original input pointer, `s` is the
first unprocessed byte and `neg` is zero. The prefix contains no sign or skipped
leading blank and cannot have truncated. These are exactly the states the
original loop would have reached there. Its digit/underscore processing,
unsigned overflow behavior, signed-range correction and warning emission remain
in place. Keeping `inp` is essential for identical warning digit counts/text.

Signs, whitespace, automatic/other bases and nonnumeric starts keep general
parsing. The raw digit checks retain base-10 semantics even if a native module
changes digit flags; the leading-blank guard retains that public customization.
No syntax/value cache, allocation, wider load, getter omission or signal queue
boundary is added. The caller retains its arithmetic and floating-conversion
behavior. The 32-bit bound is a range argument; a 32-bit build is not newly
certified by this round.

## Rejected restart variants

Both earlier variants remain in the evidence, with their sources and all timing
samples. A fixed nine-digit prototype improves short API calls but slows the
18-digit control about **11.8%** and underscores about **14.5%** in its run.
Its customer timings vary substantially: Endgame is **42.709 → 42.717 ms** in
the first run and **79.048 → 81.722 ms** on repeat; the first array-parser
medians also nearly double relative to later runs. No external cause was
isolated, and these runs are not substituted for the final measurements.

The next prototype uses the word-size bound but still restarts on continuations.
It passes full compatibility/package checks, including 24 OMZ sessions, as an
inactive private package. Nevertheless, the added **19-digit** timing control
reveals a regression: **15.461 → 28.960 ms per million API calls**, about **87%
slower**. Underscores are about **10–14% slower** in its two control runs.
That version is not activated. Resuming from the validated state removes the
repeat scan. All final tables below measure the selected implementation against
its own paired baseline; timings from different variants are not pooled.

## Timing conditions

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0, release assertions disabled,
`-O2 -g`, explicit `LDFLAGS=-g`, multibyte/PCRE enabled. The immutable preceding
source and selected source use the same configuration with private runtimes.
The final measured candidate is `.work/round26/resume/Src/zsh`; its canonical
sources match the selected checkout. Installed and debug builds have their own
paths/configurations and separate verification.

Nine alternating fresh-process samples per binary per run, CPU 2, C.UTF-8.
Own builds, tests and profilers finish before timing. Counter/fixture launchers
compile before their respective timers, between sequential measurement phases.
External activity is not exhaustively audited; the earlier restart trials show
why small timings need caution. Outputs/states match in every final comparison.
Loading, construction and warm-up precede warm application timers; reset costs
retain the existing workload definitions. These are offline kernels, not UI
startup, terminal frame rate, GPU rendering or network measurements.

### Customer kernels

| Kernel | First before → after ms | Repeat before → after ms |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 113.236 → 111.780 | 113.704 → 112.057 |
| zcoder.zsh/coder-layout | 5.431 → 5.428 | 5.500 → 5.513 |
| zcoder.zsh/coder-wide-layout | 62.346 → 61.682 | 62.307 → 61.918 |
| zchat.zsh/chat-paste | 205.095 → 201.529 | 207.204 → 201.817 |
| zchat.zsh/chat-layout | 5.427 → 5.414 | 5.409 → 5.414 |
| zchat.zsh/chat-wide-layout | 62.510 → 62.222 | 62.269 → 62.130 |
| endgame/endgame-world | 42.302 → 41.927 | 42.205 → 41.988 |
| z3dfx.mario/mario-race | 19.549 → 19.247 | 19.582 → 19.371 |
| z3dfx/shooter-step | 11.448 → 11.372 | 11.346 → 11.223 |
| z3dfx.agy/shooter-step | 11.346 → 11.236 | 11.322 → 11.233 |
| z3dfx.grok/shooter-step | 11.308 → 11.257 | 11.336 → 11.222 |
| zfetch/fetch-encode | 13.019 → 12.825 | 13.035 → 12.882 |
| z3dfx.drawing/drawing-binning | 12.384 → 12.339 | 12.334 → 12.293 |

Coder paste takes **1.3% and 1.4% less time**, chat paste **1.7% and 2.6% less**.
Mario takes **1.5% and 1.1% less**; Endgame **0.9% and 0.5% less**. URL encoding
improves about **1.5% and 1.2%**. Small ordinary editor controls remain close:
repeated coder layout is about **0.2% slower**, chat layout about **0.1% slower**.
No aggregate score or universal application speedup is claimed.

### Customer libraries

| Operation | First before → after ms/call | Repeat before → after ms/call |
| --- | ---: | ---: |
| zjson-array | 90.535 → 90.738 | 89.705 → 90.280 |
| zjson-encode-array | 207.219 → 206.334 | 203.278 → 202.321 |
| zjson | 87.278 → 86.452 | 87.208 → 86.410 |
| navigation | 1.834 → 1.816 | 1.843 → 1.803 |

Array parsing is **0.2% and 0.6% slower**. Encoding takes about **0.4–0.5% less
time**, validation about **0.9% less** in both runs. Navigation takes about
**1.0% and 2.2% less**. These small library differences are retained alongside
the stronger converter mechanism; no separate cause is assigned to each result.

### Parser/search controls

| Parser operation | Before → after ms/call |
| --- | ---: |
| html-comment-1m | 123.366 → 123.507 |
| html-prose-100k | 125.121 → 127.140 |
| json-repair-100k | 18.602 → 18.523 |
| html-clean-128 | 98.592 → 97.386 |

HTML prose conversion is **1.6% slower**; comment conversion about **0.1%
slower**. Repair stays close; cleaning takes about **1.2% less time**. These
controls preserve their algorithms, and their differences are not attributed
individually to the decimal path.

| Search case | Before → after ms/batch |
| --- | ---: |
| tiny-first | 16.031 → 16.134 |
| first | 1.622 → 1.638 |
| middle | 12.369 → 12.343 |
| last | 24.675 → 24.630 |
| missing | 24.685 → 24.630 |
| start-middle | 0.828 → 0.836 |
| start-last | 0.829 → 0.836 |
| start-beyond | 0.800 → 0.800 |
| negative-start | 17.896 → 18.575 |
| backward | 24.453 → 24.439 |

All search samples, including any slower controls, remain available.

### Direct public-API controls

| Input family | Before → after ms per million calls |
| --- | ---: |
| short | 5.364 → 3.983 |
| nine | 8.838 → 7.222 |
| ten | 9.475 → 7.698 |
| eighteen | 14.586 → 12.481 |
| signed | 8.859 → 8.335 |
| underscores | 9.991 → 9.445 |
| base16 | 15.361 → 14.545 |
| base0 | 8.442 → 7.688 |
| nondigit | 5.870 → 5.839 |
| nineteen | 15.644 → 13.377 |

One-digit through 18-digit decimal batches take **14–26% less time** (about
**1.17–1.35x**). The 19-digit continuation takes **14.5% less**, underscores
**5.5% less**, in their selected paired run. Other bases and signs also improve
in this run, but they do not use the decimal fast path and no direct mechanism
is assigned to those gains. These are repeated native API calls with a checked
unsigned digest, including the loop/call cost. Module setup is outside the native
timer; there is no separate native-loop warm-up. They are not whole-shell or
application speedup ratios. Inputs fit this 64-bit host and produce no warnings.

## Instructions and hardware counters

Matched Endgame profiles include preparation and warm-up. Source/final-state
hashes match: **1,154,944,277 → 1,144,572,425 instructions**, about
**0.90% fewer**. The original conversion self count is 59,648,781; the selected
count is recorded in the instruction summary and flat reports. Instruction
counts establish reduced work, not elapsed time by themselves.

The Linux launcher counts user-space events from exec through exit, including
inherited tasks and preparation, unlike warm timers. All events are fully
scheduled.

| Kernel | Before → after cycles | Instruction reduction |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 712,966,426 → 710,243,547 | 0.15% |
| endgame/endgame-world | 412,265,291 → 405,243,056 | 0.91% |
| z3dfx.mario/mario-race | 190,069,951 → 187,723,006 | 0.20% |
| z3dfx.drawing/drawing-binning | 169,099,477 → 167,521,931 | 0.25% |

Cycles fall about **0.4% for coder paste, 1.7% for Endgame, 1.2% for Mario and
0.9% for drawing**. These whole-process scopes differ from warm kernel timers.

## Compatibility and memory checks

- GCC and Clang release candidates pass **63 upstream scripts**, zero
  failures, two expected skips. The refreshed debug build passes **62 scripts**,
  zero failures, three expected skips (its default configuration disables PCRE).
- The selected converter passes **33,274,560 conversion calls across 20
  Memcheck processes**, leak checks disabled, zero memory errors. GCC runs
  C/C.UTF-8; Clang, pristine-versus-debug development and the exact installed
  pair each run C.UTF-8. Each host/reference-or-actual/locale process performs
  1,663,728 calls against the original release oracle. These counts include
  oracle runs, not that many unique input strings.
- Native comparisons retain **all result and diagnostic bytes**: values,
  consumed offsets, optional/null end pointers, errno seeds, error flags and
  completion markers. Exact-ending allocations at two alignments and unchanged
  input bytes are checked. Inputs include every raw suffix byte after lengths
  8 through 19, longer runs through 128, signed/unsigned limits, eleven base
  states through INT_MIN/INT_MAX, three underscore flags including −7, literal
  signs/whitespace/Meta/high bytes, and changed public blank/digit classification.
  Large synthetic streams are represented by hashes/byte counts; Memcheck logs
  remain. The oracle body is verified against pristine 5.9.2.
- The selected arithmetic operator/callback corpus passes **72,384 comparisons**
  in C/C.UTF-8. Broad release groups also pass **110,100 arithmetic syntax**,
  **704,585 scalar**, **5,192 array/append**, **193,236 search**, **159,600
  pattern** and **2,640 substitution** comparisons, 36 PTY completion buffers,
  20 native accessor cases and **200,832 numeric/floating-state scenarios** under
  Memcheck. Twenty-four customer kernel/locale states and five original project
  suites match the preceding shell.
- All **1,056 dynamic exported names/types**, public headers and conversion
  declarations remain. Source checks verify **1,847 pristine files**, **1,848
  timed interpreter inputs**, **1,853 installed core inputs**, exact restoration
  of the original conversion body after removing the additions, and seven-file
  incremental patch reconstruction.

An initial profile-driver launch preceded creation of its generated script;
its setup failure remains in `bounded9/profile-setup-missing.log`. It was retried
before profiling/timing. No semantic or memory failure was hidden by this setup
retry; the two restarting algorithms were rejected on performance evidence.

These checks establish focused coverage, not universal equivalence for every
script, native extension, signal schedule or platform. No-multibyte compilation,
32-bit compilation and other operating systems are not newly certified here.
The source-wide audit remains incomplete.

## Installed daily driver

The isolated package **`1.0.0-rc0-1ca5fc1448c0`** is active through
`/usr/local/bin/psh`. Its stripped executable remains **846,488 bytes**, SHA-256
`971e8604a129205959c52fa22cc2bad1477e739157b9c516570424ed5f2df96a`.
The preceding `d9a609a3adc3` release remains available for rollback; the rejected
inactive `1b13e84df04d` trial is retained separately.

All seven package suites pass, including **190 zdraw tests**. Normal-user
verification passes installed component/native loading, genuine login PTY
checks and **24 unchanged Oh My Zsh sessions**, using the existing re5et theme,
git plugin and syntax highlighter. The installer consumes the matching certificate
before activation. Post-activation inventories confirm **11,828 stable Zsh/startup
entries**, **1,603 preceding-release entries**, `/etc/shells` and the account
login shell remain unchanged.

The private repository, rc0 version, original annotated tag, draft checkpoint
and seven existing release assets remain in place. No release is published.

[All evidence](results/round26/) retains final samples, slower controls, both
rejected restart trials, setup failures, source/binary hashes and exact commands.
Remaining arithmetic parsing and scope-table scans are separate profiling targets.
