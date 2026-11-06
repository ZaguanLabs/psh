# Scalar index widths — 2026-11-06

This revision is preserved as `.work/round3/psh`. The current executable also
includes [array append length reuse](round4.md), measured separately.

These timings compare the **second psh**, preserved as `.work/round2/psh`, with
the third candidate. Both contain the array replacement and bounded-copy
changes. Ratios here are incremental, not comparisons against pristine Zsh.

## Change and equivalence

`getarg()` locates scalar indices by walking characters. It formerly called
`MB_METACHARLEN()` at each step. In a multibyte-enabled build this calls the
general conversion function even for byte-mode and ASCII reads.

The new positive- and negative-index loops inline only that routine's existing
fast widths, with a null wide-character result pointer:

- A literal internal ASCII byte has width one in either mode.
- With multibyte disabled, a Meta escape has width two; other bytes width one.
- Other multibyte characters still use the existing conversion routine.

The skipped calls do not change conversion state. State initialization, index
arithmetic, out-of-range remainders and previous/next-character widths retain
their existing order and semantics. Three new regression cases cover Meta
boundaries in reads/writes, mixed ASCII/Unicode replacement offsets, and changing
the multibyte option between accesses. The new tests also pass on pristine Zsh.

No thresholds, caches, public types, signatures or module interfaces changed.
Traversal remains linear in the requested index; this reduces its per-character
cost. The [incremental patch](0003-scalar-index-widths.patch) recreates the source
and tests exactly when applied to the second revision; this was checked locally.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2, with other builds/tests/profilers from this work idle during
measurement. Fixture creation, loading and warm-up are excluded.

Scalar times are milliseconds per batch. Most ASCII cases explicitly disable
multibyte processing, as the byte-oriented parser workloads do. Controls also
cover multibyte mode, Unicode, Meta-encoded NULs, and negative indices.

| Read | Input characters | Calls | Previous psh ms | New psh ms | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| First 8 ASCII characters | 1,000,000 | 2,000 | 20.172 | 20.124 | 1.00x |
| Middle 8 ASCII characters | 1,000,000 | 20 | 33.881 | 8.713 | 3.89x |
| Last 8 ASCII characters | 1,000,000 | 20 | 67.706 | 17.218 | 3.93x |
| Last 8 ASCII characters, multibyte on | 1,000,000 | 20 | 68.567 | 17.445 | 3.93x |
| Last 8 characters using negative indices | 1,000,000 | 20 | 85.045 | 25.826 | 3.29x |
| Last 8 mixed ASCII/Unicode characters | 10,000 | 20 | 1.707 | 1.286 | 1.33x |
| Last 8 all-non-ASCII characters | 10,000 | 20 | 10.118 | 10.396 | 0.97x |
| Last 8 NUL characters, byte mode | 10,000 | 20 | 0.698 | 0.692 | 1.01x |
| Full ASCII slice | 1,000,000 | 20 | 73.348 | 47.753 | 1.54x |

The all-non-ASCII control measured **2.7% slower** in this run. This is a
tradeoff to retain explicitly; it is not evidence that every workload improves.
Early reads, dense-NUL controls and empty ranges stayed close to baseline.
All cases and raw samples are in
[`slice-benchmarks.json`](results/round3/slice-benchmarks.json).

Complete warm offline calls, milliseconds per call:

| Workload | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zhtml2md: 1 MiB comment followed by retained paragraph | 553.444 | 208.339 | 2.66x |
| zhtml2md: 100 KiB prose | 137.932 | 139.590 | 0.99x |
| zjson: quote/repair 100,000 bytes with one invalid UTF-8 byte | 43.041 | 24.738 | 1.74x |
| zoup: clean 128 authored sections | 106.742 | 107.976 | 0.99x |

Every measured output matched across builds byte-for-byte. Comment and repair
results additionally match explicit expected bytes. Converter timings include
warm file input/output; JSON and cleaner inputs are in memory. Small differences
around 1% in prose/cleaner controls do not establish improvements or regressions.
These synthetic workload families are not full application sessions, network
latencies or visible frame rates. Input/output/source/binary hashes and every
sample are in [`parser-benchmarks.json`](results/round3/parser-benchmarks.json).

Callgrind on 100 late eight-character reads from a 10,000-byte scalar recorded
46,084,204 vs 22,092,500 instructions. The general conversion function accounted
for 52.7% of the preceding profile. Instruction ratios are not wall-time ratios.

## Validation

- Final multibyte-enabled candidate: 62 upstream scripts passed, zero failures,
  three skipped (privileged, PCRE, GDBM), with capability-dependent individual
  skips as recorded in the logs.
- 28,394 scalar read/write comparisons match both pristine Zsh and the second
  psh, including native/ksh/sh emulation, C/C.UTF-8, multibyte on/off, all byte
  values, invalid bytes, NULs, negative/zero/out-of-range indices, formatting and
  arithmetic effects. Potentially invalid mutations are isolated and their
  exit statuses and diagnostics are compared.
- The existing 4,200 array cases still match pristine Zsh.
- Separate pristine/candidate builds with `--disable-multibyte`: eight available
  substitution scripts passed, zero failures, UTF-8 script skipped in each;
  another 12,266 scalar-read comparisons match across these builds.
- zhtml2md: all 307 checks passed on the candidate. Selected suites match the
  preceding psh exactly: 14,237 zjson checks, 101 zoup cleaner checks, nine stream
  checks and 86 game-engine checks.
- Valgrind Memcheck reports zero errors in mixed-byte/Unicode read, assignment
  and late-index workloads, with C.UTF-8 explicitly selected.

This is local Linux evidence, not a complete cross-platform certification or
proof of language equivalence. Public module structures and exported conversion
functions are unchanged. No third-party rendering module was exercised.

## Exploratory variants

A split byte/multibyte loop improved byte-mode late reads by about 1.16x while
the ASCII fast case improved multibyte-enabled ASCII reads by 3.9x. Unifying the
ASCII case made the byte-oriented path faster too. An ASCII-only version left
extra conversion calls on dense escaped bytes; the retained version mirrors
both original fast cases. Exploratory datasets are retained under
[`experiments/`](results/round3/experiments/); source/binary snapshots are local
under `.work/logs/round3/`. Only the final candidate has the complete validation
and measurement record above.

Full length scans, array-prefix validation and repeated append scans remain
open profiling targets in the [source-review map](audit.md).
