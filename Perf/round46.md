# Round 46: avoid unused lexer scratch storage

The parent is `c983a44`. Baseline release `1.0.0-rc1-345edd03d312` has
SHA-256 `46603868a3b9576e4ecc1cd79d35fb1aa49954fe66a61ab6f0234bdde524c0f4`.
Candidate release `1.0.0-rc1-126770ba80d2` has SHA-256
`41feca1e89521329ca50993bc0a1e801f38fe74364fd02327a77fae16cb05571`.
Both are GCC 15.2 release-profile PGO+LTO builds. The candidate executable is
887,408 bytes versus 883,312 bytes, a 4 KiB increase. All 1,070 dynamic exported
symbol names are identical.

This investigation follows the remaining lexer allocation in round 44's glob
profile, while measuring against the later accepted round 45 release.

## Ownership and eligibility

`exalias()` previously declared a `VARARR` buffer sized to `strlen(tokstr)+1`
for every non-null token string. Only strings containing internal token markers
used that storage: they were copied with the original token-to-character mapping
for alias and reserved-word lookup. Plain words pointed `zshlextext` directly
at `tokstr`, leaving their allocated scratch unused.

The actual release configuration does not enable `USE_STACK_ALLOCATION`.
Here VARARR uses `zhalloc()`, so unused storage remains in the surrounding arena
until that arena is released. Repeated parsing in glob qualifiers can accumulate
these allocations. Removing the unused allocation also removes its length scan.

The candidate initializes the heap copy pointer to NULL and allocates it only
inside the existing `has_token()` branch. Tokenized words receive the identical
size, contents, allocation mechanism and lifetime. Plain words still use tokstr.
All restoration checks require an allocated copy and the original pointer
identity; POSIX_ALIASES continues to distinguish copied token text from plain
words. Aliases, reserved words, spelling correction and ZLE callbacks keep their
original ordering. No cache, early heap release, parser API or token format is
introduced. Optional stack allocation retains its original allocation path,
with a named backing buffer and pointer alias to avoid always-true array-address warnings.
Both VLA and alloca configurations pass `-Wall -Werror` syntax checks.

An initial unguarded NULL-sentinel trial was superseded before final verification.
Explicit non-null guards avoid mistaking absent scratch for matching storage if
an alias callback changes the global lexer text pointer. No observed upstream
bug or incompatibility is claimed from that defensive refinement. Its inactive
build and partial evidence remain archived separately. A second trial was
superseded to remove the optional VLA warnings; preprocessing confirms that
this final declaration adjustment leaves the default heap path identical.

## Characterization

Before changing production code, 328 cases compare pristine Zsh 5.9.2 and the
preceding psh in C and C.UTF-8. They include normal/escaped/quoted names,
POSIX_ALIASES and disabled aliases, zsh/sh/ksh emulation, global and suffix
aliases, recursion, reserved words, operators, retained functions, substitutions,
heredocs, traps, always blocks, diagnostics, Unicode, invalid bytes, embedded NUL,
and plain/quoted words up to 32,768 characters. Raw output, diagnostics and exit
status are compared. The initial fixture incorrectly expected zero from an
always block whose body returns false; both hosts return one. The corrected
expectation and the initial report are retained; shell behavior is unchanged.

The final lexer comparison uses Memcheck on all three hosts. The existing glob
ownership matrix adds qualifiers that mutate aliases and retain functions and
traps, including the original-header native parser fixture. Genuine interactive
coverage comes from the full upstream ZLE/completion tests and the unchanged
personal OMZ stack exercised by the package terminal gate.

## Measurement method

The glob memory profile uses actual installed PGO+LTO binaries and Massif's
page accounting, which includes Zsh's mmap-backed arenas. Mapped-page peaks are
not RSS or elapsed speed. A separate Callgrind profile uses the customer's
zcoder layout kernel, including source loading, setup and validation.

After builds, checks and profiles finish, paired timings alternate hosts on
CPU 13 in C.UTF-8. The existing glob driver measures whole processes and peak
RSS. Warm customer kernels and JSON operations remain regression controls.
The new customer-process driver includes source loading, setup, warmup,
operation, validation and output, checks complete state bytes, and records
peak RSS. These are fresh kernel processes, not complete application launches.

The active rc0, stable Zsh, startup files and account login shell stay unchanged.
Pre-existing packaging/OMZ edits and the sent hash-getter bug report are preserved
and excluded from this round's commit. Local build provenance includes those
existing packaging/gate edits. No public release or activation is performed.

## Compiled customer caches

The initial zcoder profile revealed little lexer activity: the project already
has sibling `.zsh.zwc` files. `try_source_file()` can use these when they are at
least as new as the source and have valid matching bytecode. A fresh process is
therefore not necessarily a fresh text parse. The initial profile is retained,
but its source manifest did not include those bytecode inputs.

The follow-up profile captures source and cache hashes, sizes and modification
times. It compares both current project loading and private text-only copies;
all four complete states match. Current loading records 122,657,284 versus
122,650,723 instructions (0.005% less); text-only loading records 128,024,740
versus 127,942,866 (0.064% less). Neither supports a meaningful broad customer
speed claim. The new process benchmark retains both modes, requires the text
copy's complete result to equal the baseline's current loaded result, and does
not modify customer sources or caches. Measurement-session manifests also guard
source and bytecode inputs for the existing warm customer/JSON controls.

## Profile result

The 10,000-file, 1,024-character plain-word qualifier records peak page
allocations of 144,953,344 bytes on the preceding release and 136,683,520 bytes
on the candidate: 8,269,824 bytes (7.89 MiB) less. Full NUL-delimited file lists
match. These figures include large locale mappings and other unrelated pages;
arena call stacks are not exact per-object accounting. No elapsed-time or RSS
claim is inferred from this profiler.

The final lexer matrix passes all 328 cases under Memcheck on all three hosts.
All 148 existing glob-program cases pass too. A separate state-only check
compares 13 customer kernels across both releases and both loading modes; all
52 observations match their expected workload results and complete state bytes.
A read-only openat trace confirms zcoder actually opens its util/input bytecode
caches. The original customer libraries and cache metadata remain unchanged.

## Repeated timings and adoption

The change is **adopted as the 30th core optimization**. No intentional language
or native-interface difference is added. Both complete nine-sample runs finish
successfully with unchanged source/cache input manifests and matching outputs.

At 10,000 files:

| Qualifier | First elapsed, previous → candidate | Less time across runs | First peak RSS, KiB | Less RSS across runs |
| --- | ---: | ---: | ---: | ---: |
| Long code, 1,024-character plain word | 377.817 → 323.072 ms | 14.5–15.9% | 48,912 → 41,032 | 16.1–16.3% |
| Retained function definition | 277.761 → 203.192 ms | 24.2–26.8% | 30,756 → 20,036 | 34.9–35.0% |
| Function predicate | 72.833 → 70.216 ms | 3.6–4.8% | 7,524 → 7,204 | 3.9–4.3% |

These gains are specific to repeated parsing workloads, not general shell or
application-launch improvements. Small-glob, short-predicate and sort controls
remain in the full table. The 10,000-file sort control takes 1.2–1.3% more time.

Customer results are mixed. Warm JSON cases take 1.2–2.0% less time across the
two runs, while the profiled zcoder layout instruction count is essentially
unchanged. Endgame world construction takes 1.3–1.4% more warm time and
1.4–1.8% more fresh-process time. zchat paste takes 0.7–1.9% more warm time and
1.2–1.4% more time in the private text-only process comparison. Other slower
cases remain alongside the improvements; these costs are not dismissed as
noise. The substantial targeted memory/time reductions justify the small change,
without claiming a general lexer-derived speedup for the customer's programs.
The executable's 4 KiB increase is retained as another measured cost.

All seven upstream/bundled suites pass, including 63 successful upstream scripts
with zero failures and two skips, and 190 zdraw tests. Core tests run after the
initial checks/profiles and without concurrent workloads. Additional cache-aware
profiling and state checks finish during bundled testing, before any timing.
Full package verification passes 24 unchanged OMZ sessions, 14 native-library
observations, component rendering, module isolation and protected-installation/
account-shell checks. The candidate remains installed inactive.

See [every timing case](results/round46/timings.md) and the
[evidence index](results/round46/README.md), including both superseded trials,
all controls, final validation and reproducible drivers.


During final archiving, an output-name collision was caught: the glob timer had
overwritten the earlier glob correctness report/log. The original check-session
record still shows its successful exit. The identical 148-case Memcheck matrix
was rerun after timing, with distinct `glob-check` filenames, to restore its raw
evidence. The orchestration script is corrected and its original version kept;
production code and timing results are unchanged. No correctness/profile work
overlaps the timing samples.
