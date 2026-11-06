# Bounded scalar copying — 2026-11-06

This revision is preserved as `.work/round2/psh`. The current executable also
includes the index-traversal change measured in [the third experiment](round3.md).

All timings here compare the **first psh executable** (`.work/round1/psh`) with
the second candidate. The indexed-array optimization is present in both; these
are incremental measurements, not comparisons against pristine Zsh.

Environment and method: AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0,
`-O2 -g`, multibyte support and Zsh debug assertions. Nine fresh processes per
build, alternating order, pinned to CPU 2, with other builds/tests/profilers
from this work idle during timing. Loading, fixture preparation and warm-up are
excluded. Raw samples, source hashes and binary hashes are retained under
[`results/round2/`](results/round2/).

## Change and invariants

After formatting and index normalization, `getstrvalue()` formerly copied the
entire scalar suffix and then inserted a terminator at the slice end. It now
handles empty/out-of-range selections and computes the selected byte length
before allocating and copying. Getter calls, formatting, normalization, negative
indices and multibyte offset handling retain their existing order and code.

No new threshold is needed for this change. It does not alter public structures,
function signatures, module interfaces, scalar encoding or array storage.
`0002-bounded-scalar-copy.patch` recreates the source and tests exactly when
applied after the first patch; this application was checked locally.

The full `strlen()` and character-to-byte offset traversal still run where they
did before. A small result does not yet imply constant-time scalar indexing.

## Measurements

Scalar times are milliseconds per batch. Large distant-index controls use
shorter batches because index traversal already dominates them.

| Scalar operation | Input characters | Calls | First psh ms | New psh ms | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| First 8 ASCII characters | 32 | 2,000 | 1.330 | 1.249 | 1.06x |
| First 8 ASCII characters | 10,000 | 2,000 | 1.539 | 1.331 | 1.16x |
| First 8 ASCII characters | 1,000,000 | 2,000 | 54.160 | 20.097 | 2.69x |
| Empty reversed range near start | 1,000,000 | 2,000 | 53.763 | 19.882 | 2.70x |
| First 8 non-ASCII characters | 100,000 | 2,000 | 11.526 | 4.749 | 2.43x |
| First 8 NUL characters | 100,000 | 2,000 | 10.389 | 4.073 | 2.55x |
| Middle 8 ASCII characters | 1,000,000 | 20 | 34.242 | 33.900 | 1.01x |
| Last 8 ASCII characters | 1,000,000 | 20 | 67.565 | 67.550 | 1.00x |
| Full ASCII slice | 1,000,000 | 20 | 73.077 | 73.145 | 1.00x |
| Beyond-end ASCII range | 1,000,000 | 20 | 67.658 | 67.591 | 1.00x |

See [`slice-benchmarks.json`](results/round2/slice-benchmarks.json) for every
case and sample. The distant-index controls show that this change removes
unnecessary copying without fixing the larger indexing traversal cost.

Complete warm parser/library calls, milliseconds per call:

| Workload | First psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zhtml2md: 1 MiB comment followed by retained paragraph | 575.332 | 552.737 | 1.04x |
| zhtml2md: 100 KiB prose from complete seed units | 138.392 | 137.363 | 1.01x |
| zjson: quote/repair 100,000 bytes with one invalid UTF-8 byte | 45.553 | 42.831 | 1.06x |
| zoup: clean 128 authored sections | 106.892 | 106.076 | 1.01x |

Every measured sample produced identical output bytes across builds. The
comment and repair workloads also have explicit expected outputs. Converter
calls include warm file input and output; JSON and cleaner inputs are held in
memory. These are offline calls, not network latency, frame rates or complete
application sessions. Small differences, especially around 1%, are not claimed
as established improvements. Raw data and input/output/source hashes are in
[`parser-benchmarks.json`](results/round2/parser-benchmarks.json).

A generated prose corpus already in the application checkout was truncated
mid-element and rejected by the preceding build. It was excluded. The retained
benchmark generates complete units from the authored seed, adds trailing-space
padding, and verifies strict conversion. No application source was changed.

Callgrind on 1,000 eight-character reads from a 100,000-byte scalar recorded
125,433,770 vs 25,396,706 instructions. Copying accounted for 79.8% of the old
profile. This instruction reduction is not a wall-time speedup claim. Valgrind's
system heap-allocation totals were essentially unchanged in this fixture,
consistent with arena reuse; no process-memory reduction is claimed.

## Compatibility evidence

- Final candidate: 62 upstream test scripts passed, zero failures, three skipped
  for privileged, PCRE and GDBM support, with the same capability-dependent
  individual skips as before.
- Three new regression cases cover scalar clamping/formatting, NUL/metafied
  bytes, and Unicode/combining characters. Both affected test scripts also pass
  using the untouched baseline executable.
- 12,266 scalar checks match both pristine Zsh and the first psh across C and
  C.UTF-8, native/ksh/sh modes, multibyte on/off, all byte values, negative and
  reversed ranges, formatting, arithmetic effects and readonly values.
- The existing 4,200 array cases still match pristine Zsh exactly.
- zhtml2md: all 307 checks pass on both first psh and the candidate. Selected
  zjson, zoup and z3dfx suites also pass with identical output: 14,237 JSON checks,
  101 cleaner checks, nine stream checks and 86 game-engine checks.
- Valgrind Memcheck reports zero errors for the profiled scalar-read workload.

These are local compatibility checks, not proof of full language equivalence or
cross-platform compatibility. The next profiling targets remain full length
scans and character/index traversal, with the same behavior-preservation rule.
