# First psh experiment — 2026-11-06

These measurements describe the first psh revision, preserved as
`.work/round1/psh`. The current executable also includes the scalar-copy change
measured separately in [the second experiment](round2.md).

Environment: AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`,
multibyte support and Zsh debug assertions. Baseline and candidate use the same
configuration. Timings are pinned to CPU 2, with no concurrent builds, profilers
or test suites from this work. Each build gets nine fresh-process samples,
alternating order, with fixture setup and warm-up outside timing.

## Retained optimization

Size-preserving replacements whose exclusive slice end is at most 32 can avoid
walking the rest of an ordinary indexed array. The fast path preserves the
existing exclusions for special, unique and tied parameters and pattern-derived
indices. Negative indices retain the existing path. No public data structures,
function signatures or array representation changed.

Array times below are milliseconds for 20,000 replacements; append uses 16,000
single-element appends to an initially empty array. These are operation-specific
microbenchmarks, not overall shell speedups.

| Operation | Array elements | Baseline ms | psh ms | Baseline / psh |
| --- | ---: | ---: | ---: | ---: |
| Replace element 1 | 1,000 | 15.343 | 10.595 | 1.45x |
| Replace element 1 | 10,000 | 53.946 | 10.374 | 5.20x |
| Replace element 1 | 100,000 | 462.903 | 10.354 | 44.71x |
| Replace elements 1–2 | 100,000 | 476.325 | 17.001 | 28.02x |
| Replace element 32 | 100,000 | 461.307 | 10.651 | 43.31x |
| Replace element 33 | 100,000 | 471.070 | 470.379 | 1.00x |
| Replace middle element | 100,000 | 460.840 | 463.725 | 0.99x |
| Replace last element | 100,000 | 458.040 | 461.864 | 0.99x |
| Append | 0 initially | 63.754 | 63.337 | 1.01x |

The unchanged scalar-replacement control measured 9.543 vs 9.872 ms (psh 3.4%
slower); tiny-array results also vary by a few percent. Small differences cannot
be treated as proven gains or dismissed as impossible regressions. No claim is
made that every workload improves. All samples and controls are in
[`results/array-benchmarks.json`](results/array-benchmarks.json).

## Application kernels

Milliseconds per complete offline call, with byte-identical resulting shell
state in every sample:

| Kernel | Baseline | psh |
| --- | ---: | ---: |
| zjson validation: array of 2,000 numbers | 106.139 | 105.309 |
| z3dfx navigation rebuild | 2.374 | 2.392 |

These results do not establish an application-level speedup. They exclude
networking, UI rendering and terminal painting. Exact source hashes, resulting
state hashes and raw samples are in
[`results/application-benchmarks.json`](results/application-benchmarks.json).

## Validation

- Untouched baseline and final candidate: 62 upstream test scripts successful,
  zero failures, three skipped (privileged, PCRE and GDBM). Individual tests also
  skip capability-dependent terminal-color and MONITOR checks in this context.
- Six added upstream-format regression cases cover literal/empty values,
  extension/deletion, ksh indexing, negative/pattern indices, unique/tied arrays
  and the prefix boundary. They also pass on the untouched baseline executable.
- 4,200 isolated differential cases: identical stdout bytes, stderr bytes and
  exit status across C/C.UTF-8 and native/ksh/sh modes.
- Both executables pass the selected application suites with identical output:
  zjson's 14,237 checks, zoup's 101 cleaner and nine stream checks, and z3dfx's
  86 engine checks.
- Valgrind Memcheck reports zero errors for repeated replacement, boundary,
  deletion, extension, negative-index, append, unique and tied-array operations.
  This was an invalid-access check, not a full leak audit.

These checks are local Linux evidence, not proof of complete language
equivalence or cross-platform/module compatibility. No third-party native
rendering modules were loaded by the application kernels.

## Rejected variants and remaining work

An unrestricted bounded scan improved early writes but made last-element writes
on a 100,000-element array about 1.9x slower and append about 1.45x slower. That
version was rejected; the 32-element cap preserves the original distant-index
scan. See [`results/rejected-unbounded-scan.json`](results/rejected-unbounded-scan.json).

An initial ordering of eligibility checks also measured slower on navigation.
Longer confirmation batches measured 2.375 vs 2.444 ms/call. Checking the prefix
limit first reduced work for ordinary distant-index assignments: a subsequent
longer run measured 2.410 vs 2.356 ms/call. The final nine-sample run above was
close to baseline. Both confirmation datasets are retained alongside the final
results; these small timing differences are not presented as navigation gains.

Repeated append scaling remains unresolved. The next investigation should
measure scalar slice copying and array-index validation against the parsers,
rather than extrapolating this microbenchmark to those applications. The
[source-review map](audit.md) records the wider audit's outstanding areas.
