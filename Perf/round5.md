# Forward array pattern searches — 2026-11-06

These measurements compare the **fourth psh** (`.work/round4/psh`) with the
fifth candidate. Both contain the preceding four optimizations. They isolate
this revision rather than comparing cumulative changes against pristine Zsh.

## Change and compatibility boundary

An indexed-array pattern search previously counted the entire array before
looking for a match. For a forward search with a nonnegative normalized start,
`getarg()` now walks safely to that start and begins matching immediately.
An early match avoids inspecting the unused suffix. A failed search reaches
the null terminator, which supplies the original length-plus-one missing index.
An offset beyond the array stops at the same terminator; it cannot overrun it.

Pattern compilation and arithmetic flag evaluation still precede the search.
The matcher sees the same elements in the same order and retains occurrence
counting and capture updates. Empty arrays still use the original early return.
Backward searches and negative starts retain the length-based path. Scalar and
associative searches retain their original paths. There is no persistent cache,
representation change, added exported symbol or public declaration change.

Custom getters are still called at the same points, and the returned snapshot
is searched. Value-returning searches retain their subsequent getter call,
including when the first getter returns a short view or replaces its accessors.
The test-only module verifies those distinctions against explicit expected
results on pristine Zsh and the candidate.

The [incremental source/test patch](0005-forward-array-search.patch) applies
after the fourth patch. Applying it to a temporary copy of the fourth revision
reproduced the candidate source and tests exactly.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine fresh processes per build, alternating order,
pinned to CPU 2. Other builds, tests and profilers from this work were idle
during timings. Setup and warm-up are excluded, and indices are checked after
each batch. Each array contains one `target` or none, with other elements `x`.

Milliseconds per complete batch, using `(ib:start:)target` unless noted:

| Case | Elements | Start | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Tiny, first match | 8 | 1 | 20,000 | 17.368 | 16.962 | 1.02x |
| First match | 100,000 | 1 | 2,000 | 47.633 | 1.722 | 27.66x |
| Middle match | 100,000 | 1 | 20 | 10.994 | 10.389 | 1.06x |
| Last match | 100,000 | 1 | 20 | 21.395 | 20.756 | 1.03x |
| Missing | 100,000 | 1 | 20 | 21.408 | 21.115 | 1.01x |
| Match at middle start | 100,000 | 50,000 | 1,000 | 24.055 | 13.361 | 1.80x |
| Match at last start | 100,000 | 100,000 | 1,000 | 24.769 | 24.219 | 1.02x |
| Start beyond end | 100,000 | 100,001 | 1,000 | 23.309 | 23.366 | 1.00x |
| Negative start control | 100,000 | -1 | 1,000 | 23.366 | 23.228 | 1.01x |
| Backward control, `(Ib:start:)` | 100,000 | -1 | 1,000 | 23.379 | 23.346 | 1.00x |

Early searches no longer scale with the unused suffix. Searches from a distant
positive start still walk the preceding pointers; this change does not make
arbitrary start lookup constant-time. Late and failed searches remain linear.
The small differences in controls do not establish systematic gains or losses.
All samples are retained in [`search-benchmarks.json`](results/round5/search-benchmarks.json).

Complete warm offline application/library calls, milliseconds per call:

| Workload | Previous psh | New psh |
| --- | ---: | ---: |
| zjson: parse a 2,000-number array | 113.491 | 107.645 |
| zjson: encode 4,000 already decoded strings | 236.218 | 230.438 |
| zjson: validate a 2,000-number array | 103.494 | 101.353 |
| z3dfx navigation rebuild | 2.423 | 2.401 |

Parsing measured 5.2% faster in this run. Encoding, validation and navigation
measured 2.4%, 2.1% and 0.9% faster. These modest application shifts have not
been attributed individually to eliminated scans versus code layout or timing
variation. They do not imply a 28x parser or game speedup. Resulting state
matched across all samples, and encoding also matched an explicit expected JSON
string. See [`application-benchmarks.json`](results/round5/application-benchmarks.json)
for source hashes and raw samples. These are offline library calls, without
network, GPU or terminal rendering.

Callgrind on 1,000 default first-element searches in a 10,000-element array
recorded **61,233,311 vs 21,225,314 instructions**, including startup and fixture
construction. `arrlen()` accounted for 40,005,000 instructions (65.33%) in the
previous profile. Instruction counts are not wall-time ratios; the profile
command and logs are retained with the results.

## Validation

- Final candidate: **62 upstream scripts passed, zero failures, three skipped**
  (privileged, PCRE, GDBM). Capability-dependent individual skips remain in the
  complete log.
- Two new upstream-format regressions cover start bounds, missing results,
  occurrence direction, ranges and capture state. The updated subscript suite
  also passes using the untouched baseline executable.
- **69,180 search comparisons** match both pristine Zsh and the fourth psh:
  C/C.UTF-8, native/ksh/sh, multibyte on/off, index/value searches, start and
  occurrence bounds, empty elements/arrays, Unicode/NUL patterns, captures,
  scalar/hash controls, invalid syntax and arithmetic effects. Matrices require
  a successful completion marker.
- The existing **5,192 array** and **28,394 scalar read/write** comparisons
  still match pristine Zsh.
- A `--disable-multibyte` candidate passes eight substitution scripts, with
  the UTF-8 script skipped. Another **69,180 search comparisons** match the
  pristine no-multibyte build.
- The same module built against pristine headers passes five append/API and
  15 search cases on pristine Zsh and the candidate. Search cases check stable,
  changing and self-replacing getters, custom setters and a prior direct
  public API mutation. Exact values, callback counts and unload cleanup match.
- Application suite output/status matches the fourth psh: 14,237 zjson checks,
  101 zoup cleaner checks, nine stream checks and 86 game-engine checks.
  All 307 zhtml2md checks pass on the candidate.
- Valgrind Memcheck reports zero invalid-access errors across the search
  matrices and native search cases. Leak checking was disabled; this is not a
  leak-freedom claim.
- The 1,847-file pristine source manifest verifies unchanged. Public exported
  symbols and generated parameter declarations are byte-identical to pristine
  Zsh. The final local executable is byte-identical to the tested candidate.

This is focused local Linux evidence of compatibility, not a complete audit of
Zsh or a proof of equivalence on every platform. Reviewable logs, hashes and
comparison reports are retained under [`results/round5/`](results/round5/).
