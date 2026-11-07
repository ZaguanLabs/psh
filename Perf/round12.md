# Grouped token-prefix scanning — 2026-11-07

These measurements compare the **eleventh psh** (`.work/round11/psh`) with the
twelfth candidate. Both contain the separately backported maintainer fix for
scalar-search terminator reads. Ratios isolate this revision; they are not
cumulative comparisons against pristine Zsh. The preceding commit is `9cd33bb`.

## Change and compatibility boundary

`untokenize()` accounted for 73.2% of the preceding assignment profile. Its
ordinary-byte scan still visited every byte. The public helper now probes at
most 64 bytes, in sixteen groups of four individually checked byte steps.
A terminator returns immediately. An early token transfers to a private tail
worker containing the original conversion loop. After a complete probe, that
worker may use the long-prefix scanner if at least 1,024 bytes remain.

The scanner builds small reject sets from the **current `ITOK` flags** for
nonzero bytes, with at most 15 members plus a terminator per set. The minimum
library-scan offset across those sets is the first token in their union.
An empty classification skips to the known string terminator; a zero offset
can end further scans. The default 30 token bytes require two sets. Token
conversion, `Nularg` removal and live reads of the exported `ztokens` mapping
remain in the original loop, moved intact into the tail worker.

`remnulargs()` also uses four guarded byte steps per group. Its 64-byte probe,
512-byte remaining-length gate, fresh classification set and removal behavior
from round eleven remain intact. Neither helper performs unchecked word loads.
Strings remain NUL-terminated and metafied, and no persistent cache is added.
No heap allocation, public signature, exported symbol, representation or
signal-queue dispatch boundary changes.

GNU-family builds use a guarded no-inline hint for the tail worker, keeping
setup out of the public short-string path. Other builds retain ordinary C
code. A separate binary with that hint omitted passes native and substitution
checks on the same compiler; this is not a different-compiler/platform claim.
Private generated prototypes change, while public declarations and exports
remain identical. The byte-set sizes and length gates are measured performance
choices, not safety assumptions or guaranteed optima on other C libraries.

The [incremental patch](0012-grouped-token-prefix.patch) applies after round
eleven and reproduces the current source and regression case.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Construction, loading and warm-up precede timing;
source resets before assignments are included. The three final drivers ran
sequentially with this work's builds, test suites and profilers idle. Each
sample checks independently constructed expected values.

Milliseconds per complete batch:

| Workload | Initial characters | Replacement characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII replacement | 16 | 8 | 5,000 | 4.365 | 4.421 | 0.99x |
| Large ASCII replacement | 16 | 1,000,000 | 100 | 86.926 | 53.354 | 1.63x |
| Large replacement, longer source | 100,000 | 1,000,000 | 100 | 108.189 | 70.472 | 1.54x |
| Unicode replacement | 16 | 100,000 | 200 | 32.256 | 18.707 | 1.72x |
| NUL replacement | 16 | 100,000 | 200 | 32.204 | 18.771 | 1.72x |
| Invalid-byte replacement | 16 | 100,000 | 200 | 15.028 | 8.282 | 1.81x |
| ASCII replacement, byte mode | 16 | 1,000,000 | 100 | 87.359 | 53.174 | 1.64x |
| Append | 1,000,000 | 32 | 100 | 61.421 | 28.193 | 2.18x |
| Prepend | 1,000,000 | 32 | 100 | 61.855 | 28.286 | 2.19x |
| Delete first character | 1,000,000 | 0 | 100 | 61.517 | 28.151 | 2.19x |
| Same-size replacement | 1,000,000 | 1 | 100 | 59.822 | 26.467 | 2.26x |
| Whole assignment | 16 | 1,000,000 | 100 | 59.012 | 25.737 | 2.29x |

Large assignment loops improve by roughly **1.5–2.3x**, including expansion and
reset costs. The tiny replacement measured **1.3% slower**. Whole assignment
and same-size replacement retain their original setter paths; their gains
come from shared expansion helpers.

Short/medium ASCII controls, 5,000 whole assignments per batch:

| Replacement characters | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| 31 | 2.112 | 2.152 | 0.98x |
| 32 | 2.107 | 2.172 | 0.97x |
| 63 | 2.290 | 2.274 | 1.01x |
| 64 | 2.345 | 2.274 | 1.03x |
| 65 | 2.339 | 2.325 | 1.01x |
| 127 | 2.667 | 2.650 | 1.01x |
| 128 | 2.701 | 2.683 | 1.01x |
| 255 | 3.311 | 3.385 | 0.98x |
| 256 | 6.538 | 6.190 | 1.06x |
| 512 | 4.507 | 4.521 | 1.00x |
| 575 | 4.779 | 4.778 | 1.00x |
| 576 | 4.746 | 4.774 | 0.99x |
| 577 | 4.741 | 4.674 | 1.01x |
| 1,024 | 5.912 | 5.918 | 1.00x |
| 1,087 | 6.310 | 6.304 | 1.00x |
| 1,088 | 6.406 | 5.047 | 1.27x |
| 1,089 | 6.386 | 5.020 | 1.27x |
| 2,048 | 8.887 | 6.045 | 1.47x |
| 4,096 | 14.286 | 7.983 | 1.79x |

The largest slower median is **3.1% at 32 characters**, a difference of
0.065 ms across 5,000 calls. Most other sub-1,088-character controls are close,
with both faster and slower medians. The 256-character run has a temporary
slow phase in both builds, with samples near 3.3 and 6.5 ms. Its apparent 1.06x
gain is not reliable. A separately retained nine-sample repeat measured
**3.335 vs 3.306 ms**; the original samples above are unchanged.
The cause of the temporary variation was not isolated. See
[scalar-write-benchmarks.json](results/round12/scalar-write-benchmarks.json) and
[control-repeat.json](results/round12/control-repeat.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 166.140 | 161.723 |
| zhtml2md: 100 KiB complete prose | 132.233 | 129.686 |
| zjson: repair 100,000 bytes with one invalid byte | 22.144 | 21.403 |
| zoup: clean 128 HTML sections | 106.368 | 105.324 |
| zjson: parse a 2,000-number array | 102.201 | 101.544 |
| zjson: encode 4,000 already decoded strings | 221.560 | 221.295 |
| zjson: validate a 2,000-number array | 98.039 | 96.405 |
| z3dfx navigation rebuild | 2.339 | 2.310 |

Application medians are **0.1–3.3% lower**, including 2.7% for comment conversion
and 3.3% for JSON repair. The smaller shifts do not establish improvements.
These gains are much smaller than the large scalar-loop ratios. Output bytes
or state hashes match; comment conversion, repair and encoding also match
explicit expected outputs. See the [parser](results/round12/parser-benchmarks.json)
and [application](results/round12/application-benchmarks.json) records. Network,
GPU and terminal rendering are excluded from timings.

Callgrind on the same 100-call large-replacement fixture, including warm-up,
startup and construction, records **2,229,293,659 vs 893,154,680 instructions**,
a **59.9% reduction**. The previous count is retained from round eleven's
verified identical command and worker. Instruction counts are not wall time.

## Rejected/provisional work

A length-first candidate added avoidable short-input overhead. Grouped probes
and a higher token-scan length gate reduced it. Splitting reject sets improved
the measured libc scans; this does not require SIMD instructions in psh itself.

A provisional version left length/set setup in the public helper's short path.
Its nine-sample application controls included 3.2% slower JSON parsing and
2.8% slower encoding. That prompted the tail-worker dispatch refinement.
The [provisional source patch](results/round12/pre-dispatch.patch), scalar/parser/
application samples and logs are retained under `pre-dispatch-*` for review.
Those are not the final tables. Earlier three-sample pilots remain local and
are excluded from accepted measurements. The final published binary contains
the dispatch refinement and matches all final hashes.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM), with capability-dependent individual skips in the complete log.
  Upstream PTY completion and ZLE scripts pass.
- The added upstream-format case covers a long prefix, quote/dequote roundtrips,
  NUL and escaped bytes, and literal command-substitution text that must not
  execute. It passes with pristine Zsh too.
- A pristine-header token fixture performs **78,732 checks per run** on both
  shells in C and C.UTF-8, all under Memcheck with zero errors. Complete
  allocations match, including bytes beyond the resulting terminator. Cases
  cover every nonzero byte, exact allocation boundaries, eight alignments,
  1 MiB input, valid token-classification subsets of 0/2/15/16/29/30 members,
  token groups in both orders, and changed mappings including a NUL mapping.
  Classification and mapping tables are restored before return/unload.
- The null-marker fixture retains **30,203 checks per run** across the same
  four runs, including empty/full `INULL` sets and changed flags, with zero
  Memcheck errors and matching entire allocations.
- A separate no-hint binary passes the same four token-fixture Memcheck runs
  and 2,640 substitution comparisons. Configured headers are preincluded before
  disabling the sole new GNU guard in `exec.c`; measured objects are untouched.
- **36 actual PTY completion buffers** match pristine Zsh, across twelve prefix
  lengths and unquoted, single-quoted and double-quoted input.
- **2,640 substitution**, **193,236 search**, **5,192 array**, **28,394 scalar
  read/write** and **159,600 five-encoding pattern comparisons** match pristine
  Zsh in bytes, diagnostics and status, with completion markers checked.
- A no-multibyte build passes eight substitution scripts (UTF-8 skipped), then
  the conditional script, sequentially. Its 2,640 substitution programs match
  the pristine no-multibyte build.
- The **84 scalar-search** and **440 substitution** Memcheck matrices remain
  clean, including child processes; output/diagnostics match round eleven.
  Leak checking was disabled. This is corpus evidence, not a claim that every
  shell workload is Memcheck-clean.
- Application status/output matches round eleven in C and C.UTF-8: 14,237 zjson
  checks, 101 zoup cleaner checks, nine stream checks and 86 game-engine checks.
  All 307 zhtml2md checks pass with its child-shell override explicitly set.
- Public exports and generated public declarations remain byte-identical to
  pristine Zsh. The original 1,847-file manifest and previous snapshot verify
  unchanged. The published `psh` matches the tested and timed binary.

Evidence, validation commands and hashes: [results/round12/](results/round12/).
This is local Linux evidence, not a complete source or asynchronous-signal
audit. Other compilers and C libraries can have different performance tradeoffs.
