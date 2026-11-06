# Terminal-star ASCII scanning — 2026-11-06

These measurements compare the **eighth psh** (`.work/round8/psh`) with the
ninth candidate. They isolate this revision; they are not cumulative ratios
against pristine Zsh. The Git baseline is `f82d388`.

## Change and compatibility boundary

The terminal-star path from round eight still visits every remaining byte in
multibyte mode to preserve conversion state. This revision skips runs of bytes
whose high bits are clear, eight at a time. Each skipped byte has the existing
converter's state-free ASCII width, including embedded NUL in bounded input.
Non-ASCII bytes retain `CHARINC()` and the original conversion state, invalid
byte handling and incomplete-character handling.

The word loop requires `UINT64_MAX` and eight-bit bytes. It uses `memcpy()` into
an exact-width unsigned integer, avoiding alignment and aliasing assumptions.
The repeated high-bit mask works in either byte order. Every load is bounded
by `patinend`; neither a NUL terminator nor padding beyond that pointer is
required. Without the compile-time guard the scalar loop remains.

Single ASCII bytes are consumed before considering a word load. A first
prototype loaded a word for every ASCII run and measured about 7% slower on
alternating ASCII/Unicode input. That prototype was revised before the final
nine-sample measurements; the final mixed-input median is 1.5% faster.
Exploratory results remain in `.work/logs/round9/` and are excluded below.

The existing terminal-star eligibility and signal-queue guard are unchanged.
Unqueued heap-allocation calls retain the original bitmap allocation and its
signal boundary. Other backtracking paths, byte mode, captures, match lengths,
end pointers and public declarations retain their existing rules. This is a
focused review, not an exhaustive audit of asynchronous signal behavior.

The [incremental source/test patch](0009-terminal-star-ascii-words.patch)
applies after round eight and reproduces the current files in a temporary copy.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2 in C.UTF-8. Setup and warm-up precede timing. Builds, tests and
profilers from this work were idle during timing. Every batch checks an explicit
expected index or string. Milliseconds per complete batch:

| Search | Characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII, first match | 16 | 5,000 | 4.150 | 4.124 | 1.01x |
| ASCII, first match | 100,000 | 100 | 2.414 | 0.827 | 2.92x |
| Unicode filler, first match | 100,000 | 100 | 117.783 | 116.262 | 1.01x |
| NUL filler, first match | 100,000 | 100 | 19.447 | 17.846 | 1.09x |
| Invalid-byte filler, first match | 100,000 | 100 | 127.090 | 125.901 | 1.01x |
| ASCII, byte mode, first match | 100,000 | 100 | 0.298 | 0.295 | 1.01x |
| ASCII, middle match | 2,000 | 5 | 0.180 | 0.186 | 0.97x |
| ASCII, last match | 2,000 | 5 | 0.324 | 0.355 | 0.91x |
| ASCII, missing match | 2,000 | 5 | 0.319 | 0.327 | 0.98x |
| First match, paired `(r)` range | 100,000 | 100 | 2.596 | 1.015 | 2.56x |
| Explicit start zero | 100,000 | 100 | 2.468 | 0.857 | 2.88x |
| Start at middle match | 100,000 | 100 | 25.568 | 24.824 | 1.03x |
| Start beyond end | 100,000 | 100 | 23.445 | 23.410 | 1.00x |
| Negative start, late match | 100,000 | 100 | 42.244 | 42.275 | 1.00x |
| Backward, late match | 2,000 | 5 | 0.323 | 0.330 | 0.98x |
| Alternating ASCII/Unicode, first match | 100,000 | 100 | 60.152 | 59.262 | 1.02x |
| Long ASCII run following Unicode | 100,000 | 100 | 2.427 | 0.851 | 2.85x |

The short late-match batch measured **9.6% slower**, a difference of 0.031 ms
across five calls. Samples overlap and its cause has not been isolated. The
other middle/missing/backward controls also have small slower medians. These
results do not establish a universal improvement. Raw samples and parameters
are in [scalar-search-benchmarks.json](results/round9/scalar-search-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 182.847 | 179.777 |
| zhtml2md: 100 KiB complete prose | 136.155 | 138.126 |
| zjson: repair 100,000 bytes with one invalid byte | 22.425 | 22.622 |
| zoup: clean 128 HTML sections | 105.512 | 106.166 |
| zjson: parse a 2,000-number array | 104.353 | 104.108 |
| zjson: encode 4,000 already decoded strings | 222.741 | 223.088 |
| zjson: validate a 2,000-number array | 99.776 | 100.850 |
| z3dfx navigation rebuild | 2.432 | 2.432 |

Application shifts range from **1.7% faster to 1.4% slower**. No general
application speedup is established. Result bytes or state hashes match;
comment conversion, repair and encoding also match explicit expected output.
The [parser](results/round9/parser-benchmarks.json) and
[application](results/round9/application-benchmarks.json) records retain all
samples and input/source/output hashes. Network, GPU and terminal rendering
are outside these workloads.

Callgrind on 1,000 early searches in a 100,000-character ASCII scalar records
**644,202,692 vs 156,753,692 instructions**, a **75.7% reduction** including
startup and fixture construction. The previous count is retained from round
eight for the identical command. Instruction counts are not wall-time ratios.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM); individual capability skips are retained in the log.
- The added upstream-format case covers long ASCII runs around Unicode,
  embedded NUL and an incomplete UTF-8 tail, with whole-match state. The new
  multibyte script also passes using the pristine executable.
- **193,236 search**, **5,192 array**, **28,394 scalar read/write** and
  **159,600 conditional/substitution comparisons** match pristine Zsh.
  The pattern matrix covers C, C.UTF-8, EUC-JP, GB18030 and EUC-TW, native/ksh/sh,
  multibyte on/off, captures, approximation, exclusions and encoding overrides.
  Charmaps and completion markers are verified.
- A pristine-header native module performs **844 checks per run**, split
  between queued and unqueued calls. Eight runs cover both shells, C/C.UTF-8
  and multibyte on/off, all with zero Memcheck errors. Exact-size spans of
  lengths 1–33 and 63–65 test all eight alignments with no terminator or guard
  after the allocation. Additional cases place NUL, invalid, incomplete and
  valid multibyte sequences near word boundaries. Existing bounded API,
  capture, offset, cache and unload cases remain included.
- The scalar fallback was compiled with `UINT64_MAX` undefined in an isolated
  pattern object, linked into a separate binary, and verified absent from the
  preprocessor definitions. It passes the same 159,600 pattern comparisons and
  eight native Memcheck runs. The measured candidate binary was not replaced
  during this check. This does not establish portability to every architecture.
- A no-multibyte build passes eight substitution scripts (UTF-8 skipped), then
  the conditional script, run sequentially. Another 193,236 search and 159,600
  pattern comparisons match the pristine no-multibyte build.
- All 20 native append/API/array-search checks pass. In C and C.UTF-8,
  application status/output matches round eight: 14,237 zjson checks, 101 zoup
  cleaner checks, nine stream checks and 86 game-engine checks. All 307
  zhtml2md checks pass on the candidate.
- The 84 scalar Memcheck matrices retain the same output bytes, error counts
  and function stacks as the verified pristine reference: **520 pre-existing
  terminator reads across 36 matrices**. No additional context was observed.
  The shell is not Memcheck-clean; leak checking was disabled. See the
  [comparison](results/round9/memcheck-comparison.json) and
  [upstream report](bugs/scalar-search-terminator/report.txt).
- Public exported symbols and generated parameter/utility/pattern declarations
  remain byte-identical to pristine Zsh. All 1,847 pristine source hashes and
  the previous binary snapshot verify unchanged. The published `psh` matches
  the tested candidate binary.

Evidence and hashes are retained under [results/round9/](results/round9/).
This is local Linux compatibility evidence, not a complete source audit or
proof of equivalence on every supported Zsh platform.
