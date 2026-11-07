# Grouped pointer-array scans — 2026-11-07

This revision compares the **twelfth psh** (`.work/round12/psh`, preceding
commit `1c43296`) with the thirteenth candidate. Both include the separately
backported maintainer fix for scalar-search terminator reads. Ratios isolate
this revision; they are not cumulative comparisons against pristine Zsh.

## Change and compatibility boundary

Profiles of real zjson calls identified array-length scans as a remaining
cost: `arrlen()` and the bounded length predicates account for about 14% of
parsing instructions and 16% of encoding instructions before this change.
Repeated indexed access checks whether the requested element exists; copying
or appending arrays also needs their lengths.

`arrlen()` now checks pointers in groups of four. `arrlen_ge()` handles full
groups of four, then retains its original remainder loop. **Every slot is
checked before the next slot is read.** No padding after the NULL terminator
is required, and element data is never dereferenced. Empty strings are still
non-NULL elements. The `gt`, `lt` and `le` wrappers remain unchanged, including
their existing unsigned wrap at `UINT_MAX`. Zero-bound `ge`/`lt` and
`UINT_MAX`-bound `gt`/`le` still do not read the vector at all.

This is loop unrolling with ordinary C pointer loads: no vector loads,
alignment assumptions, cache, representation change, additional accessors or
allocation. Public signatures and symbols, getter/setter behavior and signal
queue boundaries remain unchanged. Scans remain linear; repeated append and
repeated distant access can still be quadratic. Four is a measured unrolling
factor on this compiler and machine, not an array-layout or safety limit.

The [incremental source/test patch](0013-grouped-array-scans.patch) applies
after round twelve.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Construction, loading and warm-up precede timing;
each sample checks expected values. The three final timing drivers ran
sequentially with this work's builds, tests and profilers idle.

Milliseconds per complete array-access batch:

| Operation | Elements | Index | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| read | 0 | 1 | 5,000 | 2.685 | 2.674 | 1.00x |
| length | 0 | 0 | 5,000 | 1.324 | 1.333 | 0.99x |
| read | 8 | 1 | 5,000 | 2.812 | 2.824 | 1.00x |
| read | 8 | 4 | 5,000 | 2.832 | 2.832 | 1.00x |
| read | 8 | 8 | 5,000 | 2.846 | 2.845 | 1.00x |
| read | 8 | 9 | 5,000 | 2.711 | 2.710 | 1.00x |
| read | 8 | -1 | 5,000 | 2.862 | 2.838 | 1.01x |
| slice | 8 | 7 | 5,000 | 6.231 | 6.280 | 0.99x |
| length | 8 | 0 | 5,000 | 1.380 | 1.388 | 0.99x |
| read | 1,000 | 1 | 3,000 | 1.728 | 1.697 | 1.02x |
| read | 1,000 | 500 | 3,000 | 2.390 | 2.170 | 1.10x |
| read | 1,000 | 1,000 | 3,000 | 3.016 | 2.603 | 1.16x |
| read | 1,000 | 1,001 | 3,000 | 2.313 | 2.059 | 1.12x |
| read | 1,000 | -1 | 3,000 | 3.044 | 2.644 | 1.15x |
| slice | 1,000 | 999 | 3,000 | 4.408 | 4.201 | 1.05x |
| length | 1,000 | 0 | 3,000 | 1.488 | 1.479 | 1.01x |
| read | 100,000 | 1 | 200 | 0.124 | 0.124 | 1.00x |
| read | 100,000 | 50,000 | 200 | 4.495 | 3.104 | 1.45x |
| read | 100,000 | 100,000 | 200 | 8.931 | 6.129 | 1.46x |
| read | 100,000 | 100,001 | 200 | 4.601 | 3.196 | 1.44x |
| read | 100,000 | -1 | 200 | 8.938 | 6.464 | 1.38x |
| slice | 100,000 | 99,999 | 200 | 4.767 | 3.356 | 1.42x |
| length | 100,000 | 0 | 200 | 4.448 | 4.499 | 0.99x |

Late reads and short end slices of a 100,000-element array improve by roughly
**1.38–1.46x**. Corresponding 1,000-element cases improve by 1.05–1.16x.
Small arrays and first-element reads remain close; full-length queries show
no useful improvement, including a 1.1% slower large-array median. The largest
slower small-array median is 0.8%, on a two-element slice. These tiny timing
shifts do not establish broad gains or regressions.

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zjson: parse 2,000 numbers | 104.722 | 104.185 | 1.01x |
| zjson: encode 4,000 strings | 229.066 | 226.579 | 1.01x |
| zjson: validate 2,000 numbers | 98.552 | 98.840 | 1.00x |
| z3dfx: navigation rebuild | 2.351 | 2.368 | 0.99x |
| zhtml2md: 1 MiB comment and retained paragraph | 165.918 | 166.790 | 0.99x |
| zhtml2md: 100 KiB complete prose | 132.332 | 133.569 | 0.99x |
| zjson: repair 100,000 bytes | 21.793 | 21.741 | 1.00x |
| zoup: clean 128 HTML sections | 108.514 | 109.475 | 0.99x |

Application medians range from **1.1% faster to 0.9% slower**. These results
support a targeted array-access improvement, not a demonstrated overall JSON
or parser speedup. Output bytes or state hashes match. Explicit expectations
also check comment conversion, repair and encoding. Network, GPU and terminal
rendering are excluded. All samples and source hashes are retained in the
[array](results/round13/array-benchmarks.json),
[application](results/round13/application-benchmarks.json) and
[parser](results/round13/parser-benchmarks.json) records.

Callgrind records **1,652,947,053 → 1,548,982,976** instructions for JSON
parsing and **3,421,968,162 → 3,198,435,997** for encoding, about **6.3% and
6.5% fewer**. These include startup, construction and warm-up, unlike wall
timings. Both use `Perf/application-workload.zsh` with one measured call and
the same minimal environment. Profiling commands and binary hashes are
retained. Executed instructions are not CPU cycles or wall time; function
self-cost attribution also depends on compiler inlining.

Initial discovery profiles inherited the invoking environment. They are kept
separately, with the older binary hash identified, and are excluded from the
matched instruction-count comparison above.

## Validation

- A pristine-header native module performs **125,660 checks per run** on
  pristine Zsh and the candidate in C and C.UTF-8, all four runs under Memcheck
  with **zero errors**. It covers 139 lengths, eight pointer-slot offsets,
  four-slot boundaries, exact allocations ending at the NULL slot, empty
  element strings and valid non-NULL pointers whose data must never be read.
  All five public helpers are checked against known lengths, with ordinary,
  near-length and wrapped unsigned bounds. NULL and one-past vectors exercise
  no-read bounds. Complete allocations are unchanged afterward. Leak checking
  is disabled; this is focused corpus evidence.
- The added upstream-format case checks native and zero-based indexing,
  lengths, negative indices, missing elements and slices crossing the end.
  Its expected behavior also passes on the pristine release.
- **5,192 array**, **28,394 scalar read/write**, **193,236 search**,
  **2,640 substitution** and **159,600 five-encoding pattern comparisons**
  match pristine Zsh in output bytes, diagnostics and status.
- Twenty native append/accessor/API/search cases and **36 actual PTY
  completion buffers** match pristine Zsh.
- A no-multibyte build passes eight substitution scripts (one UTF-8 skip)
  and then the conditional script, sequentially; **2,640 substitution
  comparisons** match the pristine no-multibyte build.
- Application status/output matches round twelve in C and C.UTF-8: **14,237
  zjson checks, 101 zoup cleaner checks, nine stream checks and 86 game-engine
  checks**. All **307 zhtml2md checks** pass with the child-shell override
  explicitly set to the candidate.
- **62 upstream scripts pass, zero failures, three skipped** (privileged,
  PCRE and GDBM); capability-dependent individual skips remain in the log.
  Upstream PTY completion and ZLE scripts pass.
- Public exports, dynamic exported names/types and generated public declarations
  match pristine Zsh. Its **1,847-file manifest** and the previous snapshot
  verify unchanged. The incremental patch reproduces both changed files.
  The published `psh` matches the tested and timed candidate.

Evidence, commands and hashes: [results/round13/](results/round13/).
This is local Linux/compiler evidence and focused source review. Most source
areas remain unreviewed; other compilers and C libraries may differ in speed.
