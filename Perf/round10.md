# Literal spans during substitution — 2026-11-06

These measurements compare the corrected ninth psh (`.work/terminator-fixed/psh`)
with the tenth candidate. **Both timing builds contain Mikael Magnusson's
scalar-search bounds fix**, committed separately as `bc90a74`. Ratios isolate
this performance revision rather than cumulative gains against pristine Zsh.

## Change and compatibility boundary

`stringsubst()` makes two passes. The first recognizes process substitution;
the second handles parameter, arithmetic and command substitution, and marks
assignment-like arguments for single-word treatment. Most bytes in expanded
values do not trigger any of those handlers.

After the existing handling of the current byte, `strcspn()` skips the following
literal span. The first pass stops at `Inang`, `OutangProc` or `Equals`. The
second stops at `String`, `Qstring`, `Tick` or `Qtick`, and also literal `=` and
`Equals` when assignment-like argument handling is enabled. These sets follow
the routine's explicit comparisons, not character classification tables.

The existing handlers, node replacement, continuation pointers, option flags,
evaluation order and allocation calls are retained. Strings are still
NUL-terminated and metafied; user NUL bytes remain represented internally by
Meta escapes. Scanning compares bytes and does not interpret the locale.
No new cache, public symbol, representation or bytecode format is introduced.

Error state is still checked by the next loop header before another handler,
and on return. The scan performs fewer checks within an inert span. No
allocator or signal-queue dispatch boundary is removed. Upstream trap tests
pass; this is not an exhaustive asynchronous-signal audit.

The [incremental patch](0010-literal-substitution-spans.patch) reproduces the
source and regression when applied to the preceding snapshot. Its files are
independent of the separate bounds-fix patch.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Setup/loading and warm-up precede timing. Builds,
tests and profilers from this work were idle during final measurements; the
three benchmark drivers ran sequentially. Each batch checks an independently
constructed expected value before and after timing.

Milliseconds per complete batch, including the source reset before each write:

| Workload | Initial characters | Replacement characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII replacement | 16 | 8 | 5,000 | 4.239 | 4.200 | 1.01x |
| Large ASCII replacement | 16 | 1,000,000 | 100 | 207.580 | 125.620 | 1.65x |
| Large replacement, longer source | 100,000 | 1,000,000 | 100 | 239.791 | 150.350 | 1.59x |
| Unicode replacement | 16 | 100,000 | 200 | 79.658 | 47.182 | 1.69x |
| NUL replacement | 16 | 100,000 | 200 | 79.585 | 47.151 | 1.69x |
| Invalid-byte replacement | 16 | 100,000 | 200 | 38.900 | 22.585 | 1.72x |
| ASCII replacement, byte mode | 16 | 1,000,000 | 100 | 222.646 | 133.027 | 1.67x |
| Append | 1,000,000 | 32 | 100 | 187.378 | 102.781 | 1.82x |
| Prepend | 1,000,000 | 32 | 100 | 183.228 | 100.204 | 1.83x |
| Delete first character | 1,000,000 | 0 | 100 | 182.549 | 100.193 | 1.82x |
| Same-size replacement | 1,000,000 | 1 | 100 | 180.394 | 99.182 | 1.82x |
| Whole assignment | 16 | 1,000,000 | 100 | 179.205 | 97.812 | 1.83x |

These are complete shell assignment loops, including expansion and reset
costs. Whole assignment and same-size replacement are controls for assignment
copying, but still benefit from the changed expansion path. They do not isolate
`assignstrvalue()` copy speed. Tiny assignment is essentially unchanged. Raw
samples and input parameters are retained in
[scalar-write-benchmarks.json](results/round10/scalar-write-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 179.355 | 169.823 | 1.06x |
| zhtml2md: 100 KiB complete prose | 137.572 | 132.297 | 1.04x |
| zjson: repair 100,000 bytes with one invalid byte | 22.651 | 22.176 | 1.02x |
| zoup: clean 128 HTML sections | 107.359 | 105.569 | 1.02x |
| zjson: parse a 2,000-number array | 104.981 | 103.523 | 1.01x |
| zjson: encode 4,000 already decoded strings | 222.208 | 220.159 | 1.01x |
| zjson: validate a 2,000-number array | 99.658 | 98.739 | 1.01x |
| z3dfx navigation rebuild | 2.389 | 2.384 | 1.00x |

The comment workload measured **5.3% faster**, prose conversion **3.8% faster**,
and the remaining application medians range from 0.2% to 2.1% lower. The small
shifts do not by themselves establish improvements. These complete-call gains
are much smaller than the large assignment-loop ratios. Result bytes/state
hashes match throughout, with explicit expected outputs for comment conversion,
repair and encoding. See [parser-benchmarks.json](results/round10/parser-benchmarks.json)
and [application-benchmarks.json](results/round10/application-benchmarks.json).
No network, GPU or terminal rendering is included.

Callgrind on the same 100-call large-replacement workload, including warm-up,
startup and input construction, records **8,248,523,396 vs 3,719,003,305
instructions**, a **54.9% reduction**. The original profile attributed 56.6%
to `stringsubst()`, 20.3% to `remnulargs()` and 19.8% to `untokenize()`.
Instruction counts are not wall-time ratios. The latter helpers remain useful
profiling targets; this revision does not change them.

A copy-only candidate replacing three string-copy calls in `assignstrvalue()`
with already-known lengths was rejected. Its three-sample pilot showed only
small shifts, including slower tiny assignments; expansion dominated. The
[rejected patch](results/round10/rejected-copy.patch) and
[pilot samples](results/round10/rejected-copy-benchmarks.json) are retained as
negative evidence. That change is absent from the published source. Other
exploratory pilots are excluded from final tables.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM), retaining capability-dependent individual skips in the log.
- The new upstream-format case covers a long literal prefix around expansions,
  arithmetic evaluation order, assignment-like arguments under word splitting,
  and command-substitution NUL/Unicode output. It passes with pristine Zsh too.
- **2,640 new substitution programs** match pristine Zsh across C/C.UTF-8,
  native/ksh/sh and multibyte on/off. Cases cover all substitution forms,
  splitting and quoting, assignment markers, long spans, Unicode, NUL and all
  byte values. Raw output, diagnostics, status and completion markers are checked.
- Existing **193,236 search**, **5,192 array**, **28,394 scalar read/write**
  and **159,600 five-encoding pattern comparisons** also match pristine Zsh.
- A no-multibyte build passes eight substitution scripts (UTF-8 skipped), then
  the conditional script, run sequentially. All 2,640 new substitution programs
  match the pristine no-multibyte build.
- A **440-matrix** substitution subset reports zero Memcheck errors across all
  process summaries, including command/process-substitution children. Output
  and diagnostics match the corrected ninth psh. Completion/status markers
  verify that every matrix ran. Leak checking was disabled.
- All **84 saved scalar-search Memcheck matrices** remain clean with the
  maintainer fix; their output matches the fix-only snapshot. The historic
  520 terminator reads remain recorded under earlier rounds. Clean results
  cover these corpora, not every possible shell workload.
- In C and C.UTF-8, application suite status/output matches the corrected ninth
  psh: 14,237 zjson checks, 101 zoup cleaner checks, nine stream checks and
  86 game-engine checks. All 307 zhtml2md checks pass with its child-shell
  override explicitly set to the candidate executable.
- Public exports and generated substitution/parameter/utility/pattern
  declarations remain byte-identical to pristine Zsh. The original 1,847-file
  manifest and fixed comparator snapshot verify unchanged. The published `psh`
  matches the tested and timed candidate binary.

Evidence and hashes: [results/round10/](results/round10/). This is focused local
Linux compatibility evidence. Most of the source remains unreviewed; see the
[source-review map](audit.md). Standard-library performance can differ on other
platforms, and test success does not prove complete equivalence.
