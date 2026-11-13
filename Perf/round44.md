# Round 44: release temporary glob programs without changing legacy parsers

This round isolates the memory proposal screened in [round 43](round43.md).
The parent is `87f6251`; the baseline is installed release
`1.0.0-rc1-5982ba7e218f`, SHA-256
`f0347fdcc66a0006b5291cb34e4e222d555bf219d54c36e13fd3542b586aaaef`.
The candidate is `1.0.0-rc1-fcff3fb31d43`, SHA-256
`95998d2dd8b1ee105777fc942d5bdfdb3239b64dd60e57f0b974f3569c6f4e77`.
Both use GCC 15.2, the release profile and PGO+LTO. The executable remains
883,312 bytes. Neither the active rc0 daily driver nor published releases change.

## Ownership change and invariant

Mikael Magnusson's upstream commit
`588b37fd70bb9bd42f9abbce4651e1e2dd1d43bd`
([workers 55203](https://zsh.org/mla/workers/2026/msg01050.html)) releases the
temporary Eprog after each shell-code glob qualifier. Previously the final
program and its wordcode/string storage were allocated from the surrounding
Zsh arena, remaining there until the enclosing heap was released. A scan with
many candidates therefore accumulated many programs even though each was used
once.

The adaptation keeps **both** `parse_list(void)` and
`parse_string(char *, int)` unchanged in signature and ownership. Their programs
still have `EF_HEAP` and `nref == -1`; `freeeprog()` remains a no-op for them until
the surrounding heap is released. Core helpers accept the allocation choice,
and only `qualsheval()` requests a reference-counted program. It releases its
reference immediately after `execode()` returns. Execution still parses each
candidate independently: aliases and other parse-time side effects can change
between files. There is no compiled-qualifier cache.

Named functions copy their executable storage, and traps retain their existing
storage rules. Tests explicitly invoke functions and deliver signals after
the qualifying program has finished. Anonymous functions finish before the
outer program reference is released. Remaining parser scratch allocations and
the matched-file list still use their existing lifetime; this change does not
make total glob memory constant.

The two helpers are not marked `mod_export`, but this ELF build exposes ordinary
core symbols too. An initial assertion expecting an identical dynamic-symbol
set was therefore too strict: all 1,068 old names remain and exactly two helper
names are added, for 1,070. No old prototype or layout changes. A fixture compiled
against pristine headers calls both original parser functions, executes and
reuses their programs after `freeeprog()`, and repeats those checks inside a
qualifier. No new SDK acknowledgment is required.

## Characterize before replacing

`check-glob-programs.py` establishes 136 cases on pristine 5.9.2 and the preceding
accepted release before the production changes. It expands to 148 cases with
empty programs, EXIT traps and handled interrupts, then compares the candidate
against both hosts under Memcheck, and separately compares matching candidate/
preceding source builds configured with `--enable-zsh-valgrind`.

The matrix covers C and C.UTF-8; hidden, unusual, invalid-byte and Unicode
filenames; symlinks; filters; REPLY/reply replacements; scalar/array/hash results;
nested globs; multiple predicates; sorting; `+function`; changing aliases;
anonymous and retained functions; retained string/function traps; eval,
subshells, pipelines, always blocks, return/break/continue and parse/arithmetic
errors. Full raw output bytes, diagnostics and status must match. Unexpected
diagnostics fail even when all hosts produce them.

All 148 final cases pass in both the three-host release comparison and the
two-host allocator-aware comparison. The broader pattern comparison adds
63,840 checks against pristine Zsh with no differences.

The initial harness accidentally hid `zsh/parameter` by replacing module_path
and then queried its `functions` parameter; a replacement-string case also
needed braces to prevent colon modifiers. Its report is retained but is not
accepted evidence. The corrected fixture directly invokes the functions and
traps that each case creates, without depending on parameter-module autoloading.
The module itself always builds against the original headers.

## Profile the actual releases

The 10,000-file, 1,024-byte-literal fixture compares complete NUL-delimited
filename output on the actual installed PGO+LTO binaries. Initial malloc-only
Massif profiles report the same 2,733,984-byte peak, missing Zsh's mmap-backed
arenas. Those uninformative profiles are retained.

With `--pages-as-heap=yes`, peak page allocations fall from 156,979,200 to
144,953,344 bytes, a reduction of 12,025,856 bytes. This is mapped-page accounting
under a profiler, **not resident memory or an elapsed-time benchmark**. The
baseline peak includes two approximately 6 MiB arena-allocation paths through
`bld_eprog()`; those paths are absent from the candidate peak. Individual arenas
may contain allocations from more than one caller, so the stack attribution is
not an exact per-object memory census.

The narrow source scan found no literal forms covered by its query in selected
tracked customer scripts. That is not an exhaustive usage audit: qualifiers
can be generated dynamically. Customer kernels remain regression controls;
synthetic file selection is the direct target of the memory claim.

## Test history

The initial full core run has one failure in V14system's half-second file-lock
wait: it observed 1.074349 seconds against the upstream 0.3–0.7 second window.
That run overlapped other correctness/profiler work. Its original report and
log are retained, and the test threshold is unchanged. The isolated full core
repeat passes: 63 successful scripts, zero failures, two skips. All seven
core/bundled suites pass across the initial run and the core repeat, including
190 native zdraw tests. Full package verification passes 24 unchanged OMZ
sessions, 14 native-library observations and the protected-system checks.

Existing edits in the four packaging/OMZ files and the previously sent
hash-getter report predate this round. They are preserved and excluded from its
commit. The local package provenance includes those existing builder/gate edits.

## Paired release measurements and decision

The change is **adopted as the 28th core optimization**. No intentional language
or native-interface difference is added. Publication and activation remain held.

After all builds, tests and profilers finish, two independent nine-sample
comparisons alternate the same release binaries on CPU 13, C.UTF-8. Each uses
an excluded warmup per host. Fresh-process timing includes launch and complete
output; GNU time reports child peak RSS. File creation and result validation
are outside the timed process. Every complete filename list matches.

At 10,000 files:

| Qualifier | First-run peak RSS, KiB | Less RSS across runs | Less elapsed time across runs |
| --- | ---: | ---: | ---: |
| Long code, 1,024-byte literal | 60,712 → 48,988 | 19.2–19.3% | 16.6–18.5% |
| Function predicate (`+function`) | 8,376 → 7,520 | 9.2–10.2% | 18.0–19.4% |
| Retained function definition | 42,280 → 30,812 | 27.1–27.2% | 23.5–24.4% |
| Short `:` predicate | 7,668 → 6,948 | 9.4% | 1.3–1.4% |

The plain-glob and sort-code paths are controls. Sort code already parses once
per sort criterion, outside its filename loop, and is unchanged. Its 10,000-file
timing ranges from 0.9% less time to 0.15% more, with slightly higher measured
RSS. The 100-file cases are dominated by process startup and have small/noisy
RSS differences, including increases. All cases and slower controls remain in
[the timing table](results/round44/timings.md), not only the large wins.

Thirteen customer kernels and five JSON operations use nine alternating samples
with identical complete result states. Their median changes range from about
1.3% less time to 0.5% more. That establishes no new general application speedup;
the adopted benefit is lower peak memory and less elapsed time in large
shell-code qualifier scans. It is not a claim that every glob or application
uses 19% less memory or runs 19% faster.

[The evidence index](results/round44/README.md) retains both timing runs, final
package receipts, the failed concurrent core test and preliminary harness/profile
results. The stable Zsh installation, personal startup files and account login
shell remain untouched.
