# Terminal-star matching — 2026-11-06

These measurements compare the **seventh psh** (`.work/round7/psh`) with the
eighth candidate. Both contain the preceding seven optimizations; ratios
isolate this revision rather than the cumulative changes against pristine Zsh.

## Change and compatibility boundary

The matcher allocates and fills a byte-indexed character-start bitmap to support
backtracking through a star. When its next instruction is `P_END`, the existing
code already returns success after consuming the input. The new path handles
that case before allocating the unused bitmap or counting backtracking steps.

Multibyte mode still traverses every character with the original conversion
routine for non-ASCII bytes. ASCII advances by one, matching that routine's
state-free fast case. This preserves conversion state, including invalid and
incomplete-character handling. Byte mode advances directly to the same end
pointer. Neither path advances an input pointer already at or past the end.
Other closures and stars followed by more matching instructions retain their
original backtracking path. A standalone `*` already has a separate `PAT_ANY`
shortcut and is not the target of this change.

**Heap-allocation builds require signals already queued for the fast path.**
`zhalloc()` queues and unqueues signals, which can dispatch pending signals if
called at queue level zero. Unqueued calls therefore keep the original
allocation, traversal and terminal return. With a positive queue level the
allocation would restore that positive level without dispatching signals.
Stack-allocation builds have no heap-allocator dispatch boundary. Existing
matcher signal checks remain in place. This is a focused checkpoint review,
not a proof of every possible asynchronous signal interaction.

Return values, end pointers, match lengths, captures, flag handling and public
interfaces retain their existing rules. Eligible matches avoid the temporary
bitmap whose requested size was the remaining input's byte length. No persistent
cache or representation change is introduced.

The [incremental source/test patch](0008-terminal-star-matching.patch) applies
after the seventh patch. It reproduces the candidate source/tests when applied
to a temporary copy of the seventh snapshot. `pattern.c` and `C02cond.ztst` were
previously unchanged from pristine Zsh and are saved alongside that snapshot.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2 in C.UTF-8. Setup/loading and warm-up precede timing. Builds,
tests and profilers from this work were idle during the completed timing runs.
Each batch must produce an explicit expected index or string.

Milliseconds per complete batch:

| Search | Characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Tiny ASCII, first match | 16 | 5,000 | 4.319 | 4.262 | 1.01x |
| ASCII, first match | 100,000 | 100 | 13.474 | 2.448 | 5.50x |
| Unicode filler, first match | 100,000 | 100 | 120.458 | 118.617 | 1.02x |
| NUL filler, first match | 100,000 | 100 | 31.908 | 19.487 | 1.64x |
| Invalid-byte filler, first match | 100,000 | 100 | 124.748 | 128.259 | 0.97x |
| ASCII, byte mode, first match | 100,000 | 100 | 15.269 | 0.306 | 49.90x |
| ASCII, middle match | 2,000 | 5 | 0.192 | 0.186 | 1.03x |
| ASCII, last match | 2,000 | 5 | 0.320 | 0.319 | 1.00x |
| ASCII, missing match | 2,000 | 5 | 0.321 | 0.320 | 1.00x |
| First match, paired `(r)` range | 100,000 | 100 | 13.429 | 2.608 | 5.15x |
| Explicit start zero | 100,000 | 100 | 13.249 | 2.455 | 5.40x |
| Start at middle match | 100,000 | 100 | 31.071 | 25.680 | 1.21x |
| Start beyond end | 100,000 | 100 | 23.478 | 23.461 | 1.00x |
| Negative start, late match | 100,000 | 100 | 42.648 | 42.586 | 1.00x |
| Backward, late match | 2,000 | 5 | 0.340 | 0.325 | 1.05x |

The invalid-byte control measured **2.8% slower**. Its cause has not been
isolated. Non-ASCII matching retains conversion work, so the large ASCII/byte
ratios must not be extrapolated to every string. Raw samples and parameters are
in [`scalar-search-benchmarks.json`](results/round8/scalar-search-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zhtml2md: 1 MiB comment plus retained paragraph | 179.042 | 185.003 |
| zhtml2md: 100 KiB complete prose | 137.225 | 136.008 |
| zjson: repair 100,000 bytes with one invalid byte | 22.795 | 22.538 |
| zoup: clean 128 HTML sections | 106.975 | 106.300 |
| zjson: parse a 2,000-number array | 107.188 | 105.613 |
| zjson: encode 4,000 already decoded strings | 228.236 | 228.153 |
| zjson: validate a 2,000-number array | 100.142 | 99.507 |
| z3dfx navigation rebuild | 2.420 | 2.369 |

Comment conversion measured **3.3% slower**. Other application shifts range from
essentially unchanged to 2.1% faster. These results do not establish a general
application gain; causes of the small shifts have not been isolated. Result
bytes or state hashes match throughout; comment conversion, repair and encoding
also match explicit expected output. See
[`parser-benchmarks.json`](results/round8/parser-benchmarks.json) and
[`application-benchmarks.json`](results/round8/application-benchmarks.json) for
all samples and source/input/output hashes. No network, GPU or terminal
rendering is included.

Callgrind on 1,000 early searches in a 100,000-character ASCII scalar records
**1,643,985,914 vs 644,202,692 instructions**, a 60.8% reduction including
startup and fixture construction. Instruction counts are not wall-time ratios.

Exploratory timings before the signal guard, and an initial run with substantial
sample variation, remain under `.work/logs/round8/`; they are excluded from the
final tables. The final timings use the guarded, tested candidate. Two concurrent
no-multibyte `make check` jobs initially interfered with shared test files and
module links. Both were rerun successfully in sequence. No production behavior
was changed to accommodate those harness failures.

## Validation

- **62 upstream scripts passed, zero failures, three skipped** (privileged,
  PCRE, GDBM), with capability-dependent individual skips retained in the log.
- Three new upstream-format cases cover terminal-star captures, empty suffixes,
  star chains, byte overrides, approximations, exclusions, Unicode and incomplete
  characters. Both modified scripts also pass with untouched Zsh. Whole-match
  indices under byte overrides retain pristine Zsh's character-index behavior.
- **193,236 search comparisons**, **5,192 array comparisons** and **28,394
  scalar read/write comparisons** match pristine Zsh.
- **109,200 conditional/substitution comparisons** match pristine Zsh across
  C, C.UTF-8, EUC-JP, GB18030 and EUC-TW, with native/ksh/sh and multibyte on/off.
  Extended cases include approximation, exclusions, star chains, nested captures,
  whole-match state and per-pattern encoding flags. Locale charmaps are verified
  and recorded; completion markers guard against aborted matrices.
- A pristine-header native module makes **196 API checks per run**, split
  between explicit queued and unqueued contexts. Eight runs cover both builds,
  C/C.UTF-8 and multibyte on/off, with zero Memcheck errors. Cases exercise
  `pattryrefs()`, `pattrylen()`, forced-unmetafication caches, guarded bounded
  spans, NUL, invalid/incomplete UTF-8, captures before/around stars, offsets,
  lengths, unchanged shell capture parameters and module unload.
- A no-multibyte candidate passes eight substitution scripts (UTF-8 skipped)
  and the conditional script, run sequentially. Another 193,236 search and
  109,200 five-locale pattern comparisons match the pristine no-multibyte build.
- The stack-allocation branch compiles as a separate object. A complete
  alternate stack-allocation runtime build is not claimed.
- All 20 existing native append/API/array-search checks pass. In C and C.UTF-8,
  application suite output/status matches the seventh psh: 14,237 zjson checks,
  101 zoup cleaner checks, nine stream checks and 86 game-engine checks. All
  307 zhtml2md checks pass on the candidate.
- The 84 scalar Memcheck matrices produce the same output bytes, per-matrix
  errors and function stacks as the recorded unchanged pristine executable:
  **520 pre-existing terminator reads across 36 matrices**. No additional error
  context was observed. The shell is not Memcheck-clean; leak checking was
  disabled. See [`memcheck-comparison.json`](results/round8/memcheck-comparison.json)
  and the [existing upstream issue](upstream-terminator-read.md).
- Public exported symbols and generated parameter/utility/pattern declarations
  remain byte-identical to pristine Zsh. The 1,847-file pristine manifest verifies
  unchanged, and the published executable matches the tested binary exactly.

Evidence and hashes are retained under [`results/round8/`](results/round8/).
This is focused local Linux compatibility evidence, not a complete source or
signal audit, nor proof of equivalence on every platform.
