# Metafied byte-length prefix scanning — 2026-11-06

Measurements compare the **sixth psh** (`.work/round6/psh`) with the seventh
candidate. Both contain the preceding six optimizations. Ratios isolate this
revision rather than the cumulative changes against pristine Zsh.

## Change and compatibility boundary

`ztrsub(t, s)` counts decoded bytes in a bounded metafied span. Previously it
visited every byte, subtracting one for each internal Meta escape pair. The new
path uses bounded `memchr()` to locate the first Meta. If none exists, the raw
pointer difference is already the answer. Otherwise it keeps that initial
length and enters the original loop at the first Meta. No skipped prefix byte
can affect the answer or produce a Meta diagnostic.

The existing pair handling and debug diagnostics remain in place. This is a
byte count, independent of locale or Unicode character width. The function
does not allocate or retain state. The span need not contain a NUL terminator,
and the search is bounded by `t - s`. No threshold or storage assumption is
introduced. The public signature and exported symbol remain unchanged.

Callers include pattern string preparation and editor incremental search and
completion. The shared helper therefore receives direct boundary tests as well
as shell-level matching/substitution comparisons. The matcher, converter state,
capture updates and signal handling code have not changed.

The [incremental source/test patch](0007-metafied-length-prefix.patch) was
applied to a temporary copy of the sixth revision and reproduced the candidate
exactly. `utils.c` was unchanged from pristine Zsh before this revision and is
preserved alongside the sixth snapshot.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2, in C.UTF-8. Other builds, tests and profilers from this work
were idle during the completed timing runs. Setup/loading and warm-up are
excluded; each batch must match an explicit expected index or string.

Milliseconds per complete batch:

| Search | Characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII, first match | 16 | 5,000 | 4.355 | 4.309 | 1.01x |
| ASCII, first match | 100,000 | 100 | 15.125 | 13.113 | 1.15x |
| Unicode filler, first match | 100,000 | 100 | 122.372 | 118.151 | 1.04x |
| NUL filler, first match | 100,000 | 100 | 31.770 | 31.746 | 1.00x |
| Invalid-byte filler, first match | 100,000 | 100 | 126.109 | 126.061 | 1.00x |
| ASCII, byte mode, first match | 100,000 | 100 | 17.209 | 15.254 | 1.13x |
| ASCII, middle match | 2,000 | 5 | 1.756 | 0.203 | 8.65x |
| ASCII, last match | 2,000 | 5 | 2.422 | 0.330 | 7.34x |
| ASCII, missing match | 2,000 | 5 | 2.416 | 0.321 | 7.53x |
| First match, paired `(r)` range | 100,000 | 100 | 15.351 | 13.348 | 1.15x |
| Explicit start zero | 100,000 | 100 | 15.181 | 13.172 | 1.15x |
| Start at middle match | 100,000 | 100 | 31.955 | 30.976 | 1.03x |
| Start beyond end | 100,000 | 100 | 23.430 | 23.455 | 1.00x |
| Negative start, late match | 100,000 | 100 | 42.330 | 42.289 | 1.00x |
| Backward, late match | 2,000 | 5 | 2.429 | 0.339 | 7.17x |

Late and failed scalar searches repeatedly prepare suffixes for matching, so
the helper's cheaper scans accumulate. Search complexity remains unchanged;
these gains do not make arbitrary scalar search constant-time. Tiny and
Meta-dense controls remain close to the previous build. Raw samples and all
parameters are in [`scalar-search-benchmarks.json`](results/round7/scalar-search-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 180.499 | 178.642 |
| zhtml2md: 100 KiB complete prose | 137.288 | 137.219 |
| zjson: repair 100,000 bytes with one invalid byte | 22.660 | 22.507 |
| zoup: clean 128 HTML sections | 106.742 | 106.048 |
| zjson: parse a 2,000-number array | 106.683 | 104.711 |
| zjson: encode 4,000 already decoded strings | 224.556 | 223.128 |
| zjson: validate a 2,000-number array | 100.803 | 100.170 |
| z3dfx navigation rebuild | 2.384 | 2.374 |

Application shifts are all below 2% in this run and do not establish a broad
application gain. Result bytes or state hashes match across builds; comment,
repair and encoding also match explicit expected output. See
[`parser-benchmarks.json`](results/round7/parser-benchmarks.json) and
[`application-benchmarks.json`](results/round7/application-benchmarks.json) for
source/input/output hashes and every sample. No network/GPU/terminal rendering
is included.

Callgrind on 1,000 early searches in a 100,000-character ASCII scalar records
**2,234,029,499 vs 1,643,985,914 instructions**, a 26.4% reduction, including
startup and fixture construction. `ztrsub()` accounted for 26.86% of the
previous profile. Remaining cost is dominated by `patmatch()` and `charnext()`.
Instruction counts are not wall-time ratios.

Early validation attempts were interrupted by heavy machine I/O stalls: an
untouched-baseline comparison timed out, as did one native Memcheck launch.
Those attempts and pilot timings are retained under `.work/logs/round7/` and
are excluded from the completed results. Checks were rerun successfully after
the stalls, and the native fixture allows a longer timeout. No Memcheck error
was suppressed to obtain the passing helper results.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM), with capability-dependent individual skips in the log.
- The new subscript regression covers captures and indices after a long
  Meta-free prefix and in a dense-NUL string. The updated script also passes
  with untouched Zsh.
- **193,236 search comparisons**, **14,364 conditional/substitution checks**,
  **5,192 array comparisons** and **28,394 scalar read/write comparisons**
  match pristine Zsh. Raw stdout, diagnostics, exit status and match state are
  compared; completion markers guard against aborted matrices.
- A fixture compiled against pristine headers checks **132,615 bounded spans
  per run**, on pristine and candidate in both C and C.UTF-8. Every logical
  start/end byte boundary is checked in four 256-byte payloads: all byte values,
  plain ASCII, all NUL, and alternating ASCII/Meta. Additional cases cover a
  large non-NUL-delimited span, a Meta outside the requested range and an empty
  span at the allocation boundary. All four runs pass Memcheck with zero errors
  and successful module unload. The fixture is not installed into the runtime.
- A no-multibyte candidate passes eight substitution scripts with the UTF-8
  script skipped. Another 193,236 search and 14,364 pattern comparisons match
  the pristine no-multibyte build.
- All 20 existing native append/API/array-search checks still match pristine
  expected results and callback counts.
- In both C and C.UTF-8, suite output/status matches the sixth psh: 14,237
  zjson checks, 101 zoup cleaner checks, nine stream checks and 86 game-engine
  checks. All 307 zhtml2md checks pass on the candidate.
- Exported symbols and generated public declarations for both parameter and
  utility functions are byte-identical to pristine Zsh. The 1,847-file pristine
  source manifest verifies unchanged. The published executable matches the
  tested candidate byte-for-byte.

The separate **existing scalar-search terminator read remains reproducible**:
both pristine and candidate print `2`, and the candidate still reports the
known invalid read under Memcheck. This is not a claim of a clean whole-shell
memory audit. The [standalone bug report](bugs/scalar-search-terminator/report.txt)
and [attachment bundle](bugs/scalar-search-terminator-report.tar.gz) are ready
for `zsh-workers@zsh.org`, verified against the official documentation. Nothing
has been sent upstream.

Evidence, logs and hashes are retained under [`results/round7/`](results/round7/).
This is focused local Linux compatibility evidence, not a completed source
audit or proof of equivalence on every platform.
