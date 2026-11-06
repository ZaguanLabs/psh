# Long inert prefixes in null-marker removal — 2026-11-06

These measurements compare the **tenth psh** (`.work/round10/psh`) with the
eleventh candidate. Both contain Mikael Magnusson's separately backported
scalar-search bounds fix. Ratios isolate this revision, not the cumulative
changes against pristine Zsh. The preceding Git commit is `196d8ac`.

## Change and compatibility boundary

After round ten, `remnulargs()` accounted for 44.9% of the profiled assignment
workload's instructions. It scans for removable internal markers, preserving
`Bnullkeep` before the first removal and converting later occurrences to a
backslash. Its empty-result rule retains a `Nularg` marker.

A bounded scalar probe consumes at most **64 inert bytes**. If it completes,
`strlen()` checks whether at least **512 bytes remain**. Shorter tails keep
the original scalar scan. Longer tails use a 256-byte temporary set built from
the current `INULL` flags for byte values 1–255, excluding `Bnullkeep`.
`strcspn()` skips to the first removable marker or the string terminator.

The original start pointer and removal loop remain unchanged, including the
before/after distinction for `Bnullkeep`, tail writes and collapsed-empty
behavior. Input is still a NUL-terminated metafied string; scanning is bytewise.
The set is reconstructed per eligible call, with no persistent classification
or length cache. Native modules' changes to the exported classification table
remain observable. No heap allocation, public signature, exported symbol,
representation or signal-queue dispatch boundary is changed.

The extra length scan remains linear. These heuristics amortize the byte-set
construction; they are not cache-line/header boundaries or established global
optima. The original first candidate built the set immediately after 64 bytes.
A three-sample boundary pilot measured the 65-byte case about **38% slower**,
so that version was rejected. The length gate removes that large cliff, though
final small-input controls still include slower medians. The
[rejected patch](results/round11/rejected-first-cutoff.patch) and
[pilot samples](results/round11/first-cutoff-benchmarks.json) are retained.

The [incremental source/test patch](0011-null-marker-prefix.patch) applies
after the tenth patch and reproduces the current source and regression case.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Input construction, loading and warm-up precede
timing. The three final drivers ran sequentially with this work's builds,
tests and profilers idle. Each sample checks independently constructed expected
values. Source resets before each assignment are included in timing.

Milliseconds per complete batch:

| Workload | Initial characters | Replacement characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII replacement | 16 | 8 | 5,000 | 4.180 | 4.255 | 0.98x |
| Large ASCII replacement | 16 | 1,000,000 | 100 | 130.945 | 89.471 | 1.46x |
| Large replacement, longer source | 100,000 | 1,000,000 | 100 | 150.342 | 108.460 | 1.39x |
| Unicode replacement | 16 | 100,000 | 200 | 47.188 | 32.155 | 1.47x |
| NUL replacement | 16 | 100,000 | 200 | 47.120 | 32.217 | 1.46x |
| Invalid-byte replacement | 16 | 100,000 | 200 | 22.591 | 15.037 | 1.50x |
| ASCII replacement, byte mode | 16 | 1,000,000 | 100 | 127.076 | 88.373 | 1.44x |
| Append | 1,000,000 | 32 | 100 | 100.180 | 61.485 | 1.63x |
| Prepend | 1,000,000 | 32 | 100 | 100.200 | 62.108 | 1.61x |
| Delete first character | 1,000,000 | 0 | 100 | 100.188 | 62.142 | 1.61x |
| Same-size replacement | 1,000,000 | 1 | 100 | 99.223 | 59.882 | 1.66x |
| Whole assignment | 16 | 1,000,000 | 100 | 98.370 | 58.993 | 1.67x |

Large assignment batches improve by roughly **1.4–1.7x**. This is shell workload
timing, not an isolated helper-call ratio. The tiny replacement measured
**1.8% slower**. Whole assignment and same-size replacement retain their original
setter paths but can benefit from the shared marker-removal helper.

Short and medium ASCII controls, 5,000 whole assignments per batch:

| Replacement characters | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| 31 | 2.044 | 2.078 | 0.98x |
| 32 | 2.104 | 2.128 | 0.99x |
| 63 | 2.280 | 2.292 | 0.99x |
| 64 | 2.273 | 2.362 | 0.96x |
| 65 | 2.273 | 2.342 | 0.97x |
| 127 | 2.615 | 2.684 | 0.97x |
| 128 | 2.623 | 2.672 | 0.98x |
| 255 | 3.215 | 3.312 | 0.97x |
| 256 | 3.237 | 3.337 | 0.97x |
| 512 | 4.399 | 4.508 | 0.98x |
| 575 | 4.671 | 4.768 | 0.98x |
| 576 | 4.686 | 4.714 | 0.99x |
| 577 | 4.709 | 4.719 | 1.00x |
| 1,024 | 6.744 | 5.897 | 1.14x |
| 4,096 | 20.884 | 14.313 | 1.46x |

The 64-character control measured **3.9% slower**, the largest slower median in
this table: 0.089 ms across 5,000 calls. Other 31–575-character controls range
from about 0.5% to 3.1% slower; 576/577 are near unchanged. These regressions
are part of the tradeoff, and the smaller differences may include timing
variation. Raw samples and parameters are retained in
[scalar-write-benchmarks.json](results/round11/scalar-write-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 173.601 | 170.431 |
| zhtml2md: 100 KiB complete prose | 135.314 | 134.422 |
| zjson: repair 100,000 bytes with one invalid byte | 22.783 | 22.587 |
| zoup: clean 128 HTML sections | 107.375 | 107.316 |
| zjson: parse a 2,000-number array | 103.623 | 103.118 |
| zjson: encode 4,000 already decoded strings | 223.466 | 224.987 |
| zjson: validate a 2,000-number array | 99.577 | 99.194 |
| z3dfx navigation rebuild | 2.398 | 2.391 |

Application medians range from **1.8% faster to 0.7% slower**. Array encoding
measured 0.7% slower; the remaining medians were lower, often by less than 1%.
These small shifts do not establish a general application improvement. Output
bytes/state hashes match; comment conversion, repair and encoding also match
explicit expected outputs. See the [parser](results/round11/parser-benchmarks.json)
and [application](results/round11/application-benchmarks.json) records. No
network, GPU or terminal rendering is included in these timings.

Callgrind on the same 100-call large-replacement fixture, including warm-up,
startup and input construction, records **3,719,003,305 vs 2,229,293,659
instructions**, a **40.1% reduction**. The previous count is reused from round
ten's verified identical command and worker. Instruction counts are not wall
time. `untokenize()` is unchanged and remains the next major profile target.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM), with capability-dependent individual skips retained in the log.
  This includes upstream PTY completion/ZLE checks.
- The new upstream-format case covers long prefixes around empty arguments,
  quote removal, an escaped pattern that must match a literal star and reject
  ordinary suffixes, and embedded NUL. Its final strengthened form passes with
  pristine, candidate and no-multibyte candidate executables in separate reruns.
- A pristine-header native module performs **30,203 checks per run** on each
  shell in C and C.UTF-8, all under Memcheck with zero errors. Complete allocation
  bytes match, including bytes beyond the resulting terminator. Cases cover
  every nonzero byte; early/late markers; exact allocation boundaries; eight
  alignments; 1 MiB input; and default, added, cleared, empty and full `INULL`
  classifications. The fixture restores table state before returning.
- A separate PTY driver uses upstream `Test/comptest` to compare **24 actual
  completion buffers**: eight prefix lengths around both cutoffs, each with
  unquoted, single-quoted and double-quoted input. Completed text and buffer
  state match pristine Zsh. The child binary path is passed explicitly; an
  initial harness attempt incorrectly used the script-valued `ZSH_ARGZERO` and
  was corrected before these checks. The production code needed no workaround.
- **2,640 substitution**, **193,236 search**, **5,192 array**, **28,394 scalar
  read/write** and **159,600 five-encoding pattern comparisons** match pristine
  Zsh. Output bytes, diagnostics, status and completion markers are checked.
- A no-multibyte build passes eight substitution scripts (UTF-8 skipped), then
  the conditional script, run sequentially. Its 2,640 substitution programs
  match the pristine no-multibyte build.
- The **84 scalar-search** and **440 substitution** Memcheck matrices report
  zero errors across all process summaries, including substitution children.
  Output bytes and diagnostics match the tenth psh. Leak checking was disabled;
  these corpus results are not a claim that every workload is Memcheck-clean.
- In C and C.UTF-8, application suite output/status matches the tenth psh:
  14,237 zjson checks, 101 zoup cleaner checks, nine stream checks and 86
  game-engine checks. All 307 zhtml2md checks pass with its child-shell override
  explicitly set to the candidate executable.
- Public exports and generated glob/parameter/utility/pattern/substitution
  declarations remain byte-identical to pristine Zsh. The original 1,847-file
  manifest and the previous snapshot verify unchanged. The published `psh`
  matches the tested and timed candidate binary.

Evidence and hashes: [results/round11/](results/round11/). This is local Linux
compatibility evidence, not a complete source or asynchronous-signal audit.
Other C libraries and platforms can have different performance tradeoffs.
