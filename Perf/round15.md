# Whole metafied byte-length prefixes — 2026-11-07

This revision compares the **fourteenth psh** (`.work/round14/psh`, preceding
commit `764270e`) with the fifteenth candidate. Both include the separate
maintainer fix for scalar-search terminator reads. Ratios isolate this change;
they are not cumulative comparisons against pristine Zsh.

## Customer profile and change

URL encoding was largely unchanged last round. Its zfetch profile spends about
35% of instructions in the byte-length path, attributed to `mb_metastrlenend()`
because the compiler inlines `ztrlen()` there, and another 23% in scalar index
traversal. The project repeatedly measures a byte-mode string in its loop.

`ztrlen()` now finds the first internal Meta escape with standard `strchr()`.
If none exists, `strlen()` gives the decoded byte count directly. Otherwise,
the prefix's pointer difference initializes the count and the **original
escape-pair loop** starts at that first escape. Its diagnostics and malformed
trailing-Meta handling in debug builds remain unchanged.

This helper counts decoded **bytes**, rather than Unicode characters or display
cells. The prefix can contain arbitrary non-Meta bytes. No representation,
accessor, public signature, symbol, allocation or signal queue/dispatch boundary
changes. No cache, length gate, unchecked word load or padding requirement is
introduced. Library implementations supply their own string scans; performance
can differ across platforms. Scans remain linear, and repeated length/index
operations in the URL encoder can still be quadratic.

The [incremental source/test patch](0015-byte-length-prefix.patch) applies
after round fourteen.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Loading, construction, warm-up and simulation reset
precede timing; paste reset and binning preparation remain measured. Each
sample checks expected results and matches resulting state or bytes. This
work's builds, tests and profilers were idle during all accepted timings.

Customer kernels, milliseconds per complete batch:

| Project / operation | Batch | Previous psh | New psh | Ratio |
| --- | --- | ---: | ---: | ---: |
| zcoder: bracketed paste | 10,000 characters | 124.902 | 119.506 | 1.05x |
| zcoder: ASCII layout | 2 × 10,000 characters | 5.833 | 5.770 | 1.01x |
| zcoder: wide UTF-8 layout | 2 × 10,000 界 characters | 94.802 | 94.882 | 1.00x |
| zchat: bracketed paste | 10,000 characters | 221.259 | 212.340 | 1.04x |
| zchat: ASCII layout | 2 × 10,000 characters | 5.838 | 5.792 | 1.01x |
| zchat: wide UTF-8 layout | 2 × 10,000 界 characters | 95.479 | 95.963 | 0.99x |
| Endgame: world generation | 2 × 72×38 maps | 47.765 | 48.084 | 0.99x |
| Mario: race simulation | 120 steps | 29.330 | 28.882 | 1.02x |
| z3dfx: simulation | 60 steps | 15.031 | 14.703 | 1.02x |
| z3dfx.agy: simulation | 60 steps | 15.030 | 14.702 | 1.02x |
| z3dfx.grok: simulation | 60 steps | 15.052 | 14.803 | 1.02x |
| zfetch: URL encoding | 3 × 2 KiB prefix + UTF-8 | 16.526 | 13.890 | 1.19x |
| drawing: geometry binning | 3 × 122 triangles | 14.834 | 14.768 | 1.00x |

URL encoding improves by **1.19x**. Paste medians are about **1.04–1.05x**
faster; other project medians remain close. The paired paste instruction counts
are essentially unchanged, so its wall-time shift is not explained by removing
substantial counting work, and no separate mechanism was isolated. Acceptance
is grounded in the URL workload, rather than a claim that every kernel improved.
Wide layout measures **0.1% slower in zcoder and 0.5% slower in zchat**.

These are real project functions in offline kernels, not complete interactive
applications, network round trips, rendered frames or terminal painting. The
[coverage map](customer-projects.md) still records twelve projects with kernels
and eight pending integration.

Existing warm application/library calls, milliseconds per call:

| Workload | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zjson: parse 2,000 numbers | 101.798 | 97.948 | 1.04x |
| zjson: encode 4,000 strings | 219.242 | 213.530 | 1.03x |
| zjson: validate 2,000 numbers | 98.165 | 95.480 | 1.03x |
| z3dfx: navigation rebuild | 2.249 | 2.175 | 1.03x |
| zhtml2md: 1 MiB comment and paragraph | 163.046 | 159.783 | 1.02x |
| zhtml2md: 100 KiB complete prose | 132.418 | 128.348 | 1.03x |
| zjson: repair 100,000 bytes | 21.123 | 21.107 | 1.00x |
| zoup: clean 128 HTML sections | 101.793 | 98.712 | 1.03x |

Most medians here are about 2–4% lower; JSON repair is essentially unchanged.
Small shifts remain local measurements rather than established general gains.
Output bytes/state hashes match, including explicit expectations for comment
conversion, repair and JSON encoding.

Scalar read controls, milliseconds per complete batch:

| Operation | Input characters | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| prefix | 32 | 2,000 | 1.222 | 1.212 | 1.01x |
| full | 10,000 | 2,000 | 21.026 | 21.519 | 0.98x |
| full | 1,000,000 | 20 | 15.800 | 14.833 | 1.07x |
| mb-suffix | 1,000,000 | 20 | 13.182 | 13.136 | 1.00x |
| late-unicode | 10,000 | 20 | 10.225 | 10.640 | 0.96x |
| nul-suffix | 10,000 | 20 | 0.685 | 0.695 | 0.99x |
| negative | 1,000,000 | 20 | 25.695 | 18.213 | 1.41x |

A negative byte-mode slice near the end of a million-byte string improves by
**1.41x**. The largest slower scalar median is **4.1%**, on a late Unicode
slice; full reads at 10,000 bytes measure **2.3% slower**. Those results are
retained. The late-Unicode case prompted the additional wide-character project
controls above, which remain close. The Unicode conversion loop itself is
unchanged, but the cause of the slower scalar result was not isolated.
All 23 scalar cases and every sample remain in
[slice-benchmarks.json](results/round15/slice-benchmarks.json).

An initial eleven-case customer run preceded the wide-character controls.
After adding them, all thirteen customer cases were measured again. The
original worker and nine-sample results remain under `pre-wide-*`; they are
excluded from the final customer table. No production binary changed between
those measurements. Other drivers have separate unchanged workers, and their
samples were retained. The initial URL ratio was 1.18x, versus 1.19x in the
expanded run. No slower scalar samples were replaced.

Paired Callgrind instruction counts, including startup, construction and
warm-up, use the final customer worker and identical minimal environments:

| Kernel | Previous instructions | New instructions |
| --- | ---: | ---: |
| zcoder paste | 1,563,749,067 | 1,563,688,640 |
| zfetch URL encoding | 514,973,063 | 341,923,713 |
| Endgame world generation | 1,277,134,237 | 1,277,134,374 |
| Mario simulation | 697,293,462 | 697,497,292 |
| Drawing binning | 525,838,368 | 525,838,428 |

URL encoding executes **33.6% fewer instructions**. Other profiles are nearly
unchanged, consistent with the focused scope of this byte-count shortcut.
Instructions are not CPU cycles or wall time; no instruction-based explanation
is claimed for all smaller timing shifts. Commands and hashes are in
[matched-profile-commands.json](results/round15/matched-profile-commands.json).


## Compatibility evidence

- **62 upstream scripts pass, zero failures, three skipped** (privileged,
  PCRE, GDBM), with capability-dependent individual skips in the complete log.
  Upstream PTY completion and ZLE scripts pass.
- The added upstream-format regression checks long-prefix byte lengths,
  slicing and substitution with NUL, Meta, invalid bytes and UTF-8 octets.
  It also passes on the untouched release.
- A pristine-header native fixture performs **434,400 checks** across eight
  runs: both shells in C/C.UTF-8, using matching multibyte and no-multibyte
  builds. All runs pass under Memcheck with **zero errors**; leak checking is
  disabled. Expected counts derive from original raw input lengths before
  metafication. Cases cover 74 lengths, six data patterns, every byte value,
  early/middle/late/dense Meta escapes, exact allocation ends and eight byte
  offsets (two at 1 MiB). Entire valid-input allocations remain unchanged.
- The fixture checks byte-mode wrappers too: width arguments, explicit-end
  counts and a no-read one-past span. It preserves the existing distinction
  between the multibyte build's byte-mode explicit-end count and the separate
  no-multibyte bounded helper. **144 expected trailing-Meta diagnostics per
  run** match exactly, including returned counts in debug builds. Those are
  deliberately malformed inputs, not Memcheck errors.
- **5,192 array**, **28,394 scalar read/write**, **193,236 search**,
  **2,640 substitution** and **159,600 five-encoding pattern comparisons**
  match pristine Zsh in output bytes, diagnostics and status. Twenty native
  accessor/API/search cases and **36 actual PTY completion buffers** match.
- The no-multibyte build also passes eight substitution scripts (one UTF-8
  skip), then the conditional script, sequentially. Its **2,640 substitution
  comparisons** match its pristine counterpart.
- The saved **84 scalar-search** and **440 substitution** Memcheck matrices
  remain clean, including their child summaries. Output and diagnostics match
  the preceding saved corpus. These are focused corpus results, rather than
  a claim that every shell workload is Memcheck-clean.
- The final thirteen project kernels match pristine Zsh in C.UTF-8; the eleven
  non-wide cases also match in C (**24 locale/case comparisons**). Independent
  expectations include text reconstruction, wide-cell geometry, simulation time
  and brute-force tile commands. Wide layout expects 271 rows, cursor column
  20 and last-row character offset 9,990, without a native drawing backend.
- Original Endgame engine/adventure/Horizon suites pass **76/96/128** checks;
  AGY/Grok engine suites each pass **86**, matching round fourteen's status,
  stdout and stderr. Existing zjson, zoup and z3dfx suites also match in both
  locales (**14,237 / 101 / 9 / 86 checks**). All **307 zhtml2md checks** pass
  with its explicit child-shell override.

- Public exports, dynamic exported names/types and generated public declarations
  match pristine Zsh. Its **1,847-file manifest** and the preceding snapshot
  verify unchanged. The incremental patch reproduces both changed source/test
  files. The published `psh` matches the tested and timed candidate.

Evidence, commands and hashes: [results/round15/](results/round15/).
This is focused local Linux/compiler evidence, not a complete source,
asynchronous-signal or cross-platform performance audit.
