# Scalar pattern search length counting — 2026-11-06

These timings compare the **fifth psh** (`.work/round5/psh`) with the sixth
candidate. Both include the preceding five optimizations; results isolate this
revision rather than comparing cumulative changes against pristine Zsh.

## Change and compatibility boundary

Scalar pattern searches previously counted every character before matching.
A forward search with normalized start zero only needs to establish that the
string is nonempty, which the preceding check has already done. `getarg()` now
uses a one-character lower bound for this case. Other starts and backward
searches retain their full character count. Direction is resolved after the
occurrence flag, so negative occurrence counts retain their existing behavior.

The raw byte-length calculation, conversion-state initialization, matcher
calls, capture updates, byte-offset calculation and conversion back to character
indices remain in place. The omitted character-count routine's conversion state
was reset immediately afterward; that initialization remains. First and second
range subscripts retain their respective matching rules. No getter/setter call,
representation, allocation ownership or public interface changes.

This removes a scan; it does **not** make early scalar searches independent of
suffix length. The existing matcher still traverses the suffix. The previous
profile attributes substantial remaining work to `patmatch()`, `charnext()`
and `ztrsub()`, which have not been changed in this revision.

The [incremental source/test patch](0006-scalar-search-length.patch) applies
after the fifth patch. Applying it to a temporary copy of the fifth revision
reproduced the candidate source and tests exactly.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2, in C.UTF-8. Other builds, tests and profilers from this work
were idle during the final timing runs. String construction and warm-up precede
timing, and each batch must produce an explicit expected index or string.

Milliseconds per complete batch. Strings contain one `target` or none; filler
is `x`, `é`, NUL or byte `0xff`, as specified:

| Search | Characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII, first match | 16 | 5,000 | 4.488 | 4.413 | 1.02x |
| ASCII, first match | 100,000 | 100 | 21.671 | 15.292 | 1.42x |
| Unicode filler, first match | 100,000 | 100 | 364.587 | 122.661 | 2.97x |
| NUL filler, first match | 100,000 | 100 | 39.537 | 31.849 | 1.24x |
| Invalid-byte filler, first match | 100,000 | 100 | 248.241 | 126.365 | 1.96x |
| ASCII, byte mode, first match | 100,000 | 100 | 19.756 | 17.715 | 1.12x |
| ASCII, middle match | 2,000 | 5 | 1.785 | 1.770 | 1.01x |
| ASCII, last match | 2,000 | 5 | 2.458 | 2.453 | 1.00x |
| ASCII, missing match | 2,000 | 5 | 2.458 | 2.435 | 1.01x |
| First match, paired `(r)` range | 100,000 | 100 | 31.108 | 15.689 | 1.98x |
| Explicit start zero | 100,000 | 100 | 22.018 | 15.369 | 1.43x |
| Start at middle match | 100,000 | 100 | 32.553 | 32.562 | 1.00x |
| Start beyond end | 100,000 | 100 | 25.650 | 23.445 | 1.09x |
| Negative start, late match | 100,000 | 100 | 42.493 | 42.531 | 1.00x |
| Backward, late match | 2,000 | 5 | 2.453 | 2.442 | 1.00x |

Offset and backward controls retain their full character count. The 9% shift in
the beyond-end control has not been attributed to the optimization; this
revision does not remove its scan. Small control differences are not evidence
of systematic improvement or regression. All samples and exact case parameters
are in [`scalar-search-benchmarks.json`](results/round6/scalar-search-benchmarks.json).

An exploratory 100,000-character late-search batch was expensive and was
stopped. Final late/missing/backward controls use 2,000 characters and shorter
batches. Interrupted/pilot samples are not included in the final measurements;
they remain under `.work/logs/round6/` for local inspection.

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 214.542 | 182.400 |
| zhtml2md: 100 KiB complete prose | 136.988 | 138.589 |
| zjson: repair 100,000 bytes with one invalid UTF-8 byte | 24.420 | 22.804 |
| zoup: clean 128 HTML sections | 106.439 | 106.968 |
| zjson: parse a 2,000-number array | 104.734 | 106.292 |
| zjson: encode 4,000 already decoded strings | 228.401 | 230.208 |
| zjson: validate a 2,000-number array | 103.152 | 104.051 |
| z3dfx navigation rebuild | 2.372 | 2.441 |

Comment conversion measured **15.0% less time (1.18x)** and repair **6.6% less
time (1.07x)**. Prose conversion measured **1.2% slower**, cleaning 0.5% slower,
array parsing 1.5% slower, encoding 0.8% slower, validation 0.9% slower and
navigation 2.9% slower. Causes of the small application shifts have not been
isolated. These results do not establish a general application speedup.

All output bytes or resulting state hashes match across samples. Comment
conversion, repair and encoding also match explicit expected output. Prose is
constructed from complete authored seed units, avoiding a truncated fixture.
Inputs, project source hashes and samples are retained in
[`parser-benchmarks.json`](results/round6/parser-benchmarks.json) and
[`application-benchmarks.json`](results/round6/application-benchmarks.json).
These are offline library calls, without network, GPU or terminal rendering.

Callgrind on 1,000 early searches in a 100,000-character ASCII scalar recorded
**4,134,090,486 vs 2,234,029,499 instructions**, including startup and fixture
construction. `mb_metastrlenend()` accounts for 1,900,039,151 instructions
(45.96%) in the previous profile. Instruction totals are not wall-time ratios.
The command and profile summaries are retained with the results.

## Validation

- Final candidate: **62 upstream scripts passed, zero failures, three skipped**
  (privileged, PCRE, GDBM), plus capability-dependent individual skips recorded
  in the complete log.
- Two new upstream-format cases cover byte/NUL/capture/empty boundaries and
  Unicode indices with an incomplete trailing character. Both updated
  substitution scripts also pass using the untouched baseline executable.
- **193,236 pattern-search comparisons** match both pristine Zsh and the fifth
  psh across C/C.UTF-8, native/ksh/sh and multibyte on/off. The 124,056 added
  scalar checks cover directions, occurrence and start bounds, paired ranges,
  captures, Unicode/NUL/malformed text and formatted parameters. The original
  array, diagnostic, arithmetic and scalar/hash controls remain included.
  Completion markers guard against aborted matrices.
- The existing **5,192 array** and **28,394 scalar read/write** comparisons
  still match pristine Zsh.
- A `--disable-multibyte` candidate passes eight substitution scripts, with
  the UTF-8 script skipped. Another **193,236 search comparisons** match the
  pristine no-multibyte build.
- The existing pristine-header native module passes all 20 append/API/array
  search cases, guarding the preceding optimizations' callback behavior and
  module cleanup. The new scalar change does not alter accessor dispatch.
- In both C and C.UTF-8, suite output/status matches the fifth psh: 14,237
  zjson checks, 101 zoup cleaner checks, nine stream checks and 86 game-engine
  checks. All 307 zhtml2md checks pass on the candidate.
- Memcheck exposed a **pre-existing terminator read** in pristine Zsh as well
  as the candidate. Both complete all 84 scalar search/range matrices with
  identical output, error counts per matrix and function stacks: 520 invalid
  reads across 36 matrices. Neither build is Memcheck-clean. No additional
  error context was observed in this comparison. Leak checking was disabled.
  See the [minimal reproducer and analysis](upstream-terminator-read.md) and
  [`memcheck-comparison.json`](results/round6/memcheck-comparison.json).
- The 1,847-file pristine manifest verifies unchanged. Public exports and
  generated parameter declarations remain byte-identical to pristine Zsh.
  The final local executable is byte-identical to the tested candidate.

This is focused local Linux evidence of compatibility, not a proof of complete
equivalence or a finished source audit. Reviewable logs, hashes and comparison
reports are retained under [`results/round6/`](results/round6/).
