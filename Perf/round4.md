# Reusing an array append's known length — 2026-11-06

Timings compare the **third psh** (`.work/round3/psh`) with the fourth candidate.
Both contain the preceding three optimizations. These are incremental results,
not comparisons against pristine Zsh.

## Change and compatibility boundary

Whole-array list append computes the destination length to select the append
position. The assignment routine previously scanned the same array again.
`assignaparam()` can now pass that length to a private helper for arrays using
the exact standard accessors, with no special/tied flags or tied scalar name.
The length is a local argument for this operation; no parameter metadata or
cache survives it. Uniqueness handling and all existing allocation, ownership,
error and setter logic remain in place.

Eligibility is checked **before the first getter call**. A custom getter may
change its accessor table while returning a different view of the array. Such
a getter must retain the original two-read behavior. Signals are already queued
around assignment, and the ordinary getter has no intervening callbacks that
can invalidate the supplied count. Both original getter calls remain.

The public `setarrvalue(Value, char **)` entry point always supplies an unknown
length and retains its existing behavior. Scalar append, partial/indexed append,
key/value assignments, special arrays, tied arrays and custom accessors retain
their existing scans. Exported symbols and public parameter declarations were
compared against pristine Zsh and are byte-identical. The new helper is private.

The [incremental source/test patch](0004-array-append-length.patch) was applied
to a temporary copy of the third revision and reproduced the candidate exactly.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2. Other builds/tests/profilers from this work were idle during
timing. Fixture setup, loading and warm-up are excluded. Values and resulting
lengths are checked outside timing.

Times below are milliseconds per complete batch:

| Operation | Initial elements | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Single-element list append | 0 | 4,000 | 5.310 | 3.615 | 1.47x |
| Single-element list append | 0 | 16,000 | 64.787 | 37.754 | 1.72x |
| Single-element list append | 0 | 32,000 | 238.273 | 129.767 | 1.84x |
| Single-element list append | 10,000 | 4,000 | 22.664 | 12.466 | 1.82x |
| Four-element batch append | 0 | 4,000 | 16.879 | 10.035 | 1.68x |
| Scalar append control (`a+=x`) | 0 | 16,000 | 58.898 | 58.247 | 1.01x |
| Growing unique array | 0 | 1,000 | 10.123 | 10.229 | 0.99x |
| Duplicate-only unique append | 0 | 4,000 | 2.003 | 1.918 | 1.04x |
| Tied-array control | 0 | 2,000 | 1.828 | 1.830 | 1.00x |
| First-element replacement control | 10,000 | 20,000 | 7.973 | 7.964 | 1.00x |

Repeated append is **still quadratic**. This removes one redundant full scan;
it does not supply amortized constant-time growth or spare-capacity storage.
Growing unique arrays remain dominated by uniqueness work. All samples, including
a tiny-array case not used for the headline ratios, are in
[`append-benchmarks.json`](results/round4/append-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zjson: parse a 2,000-number array | 105.069 | 107.469 |
| zjson: encode 4,000 already decoded strings | 230.158 | 226.950 |
| zjson: validate a 2,000-number array | 100.442 | 103.211 |
| z3dfx navigation rebuild | 2.395 | 2.420 |

Parsing and validation measured **2.3% and 2.8% slower** in this run. Encoding
measured 1.4% faster, and navigation 1.1% slower. These results do not establish
an application-level gain from this change; the large append microbenchmark
ratios must not be extrapolated to complete parsers or games. Causes of the
small application shifts were not isolated. All resulting state matched across
builds, and encoding matched an explicit expected JSON string. Raw samples,
state and source hashes are in
[`application-benchmarks.json`](results/round4/application-benchmarks.json).

Callgrind on 4,000 list appends recorded 78,123,874 vs 46,130,169 instructions.
`arrlen()` accounted for 82.0% of the previous profile. Instruction totals include
startup and are not wall-time ratios.

## Validation

- Final candidate: 62 upstream scripts passed, zero failures, three skipped
  (privileged, PCRE, GDBM), with capability-dependent individual skips retained
  in the logs.
- Four new upstream-format tests cover empty/self append, mutation/recreation,
  uniqueness, ksh list/scalar distinctions, and tied/exported environment updates.
  They also pass with the untouched baseline executable.
- 5,192 array comparisons match both pristine Zsh and the third psh across C
  and C.UTF-8, native/ksh/sh, readonly/unique/tied/exported/special/associative
  arrays, indexed/keyed append, conversion, scope and mutation sequences.
- The 28,394 scalar read/write comparisons still match pristine Zsh.
- A candidate built with `--disable-multibyte` passes eight substitution scripts
  with the UTF-8 script skipped; 5,192 array comparisons match the pristine
  no-multibyte build.
- Selected suites match the previous psh: 14,237 zjson checks, 101 zoup cleaner
  checks, nine stream checks and 86 game-engine checks. All 307 zhtml2md checks
  pass on the candidate.
- Valgrind Memcheck reports zero errors for list/mutation, unique/tied and native
  callback/API workloads.

## Native accessor and API fixture

`check-append-module.py` compiles `append-module.c` against pristine configured
headers. The same `.so` is loaded into pristine Zsh, the previous psh and the
candidate in isolated test processes. Explicit expected results cover:

| Accessor/API case | Getter calls | Custom setter calls | Result |
| --- | ---: | ---: | --- |
| Stable custom getter/setter | 2 | 1 | `a b c tail` |
| Getter returns a short view, then the full array | 2 | 1 | `a tail c` |
| Getter replaces itself with standard accessors | 1 | 0 | `a tail c` |
| Standard getter with custom setter | 0 counted by fixture | 1 | `a b c tail` |
| Direct public `setarrvalue()` call | 1 | 1 | `a api c` |

The self-replacing case guards against deciding eligibility after a callback.
The standard getter in the custom-setter case is not instrumented; the fixture
counter therefore remains zero. Unloading each fixture removes its parameter,
and the native workload is also exercised under Memcheck.

This is local Linux compatibility evidence, not complete ABI certification for
every module/platform. The fixture is test-only and is not installed into the
runtime module directory. Public symbol/declaration equality and native reports
are recorded in [`results/round4/`](results/round4/).
