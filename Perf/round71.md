# Round 71: initialize ASCII pattern conversion status

Review of rounds 60–70 led to the unresolved round-70 zjson failure. The
accepted C changes in rounds 60–66 validate descriptors and TCP ports before
narrowing, with documented select-only fallbacks. Their retained OMZ reports
all contain 24 successful sessions and unchanged-source evidence. Rounds 67–68
retain rejected experiments, not production splitter changes. Round 68's prose
incorrectly called all six batch medians faster despite the slower spaces case;
that sentence is corrected. Rounds 69–70 did not establish a compatible Clang
replacement or a performance gain.

## Root cause and change

Contrary to round 70's original explanation, neither character-class caller
initializes its local `zmb_ind`. `charref()` normally writes it after multibyte
conversion, but its ASCII/non-multibyte early return did not. `patmatch()` and
`patrepeat()` consequently passed an indeterminate status to
`mb_patmatchrange()`. The defect is present in the pristine source too; this is
not evidence of a Clang compiler bug or a regression introduced in rounds 60–70.

A debugger breakpoint on the preceding Clang-LTO executable captured the exact
customer sequence: ASCII quote (`ch=34`) reached `mb_patmatchrange()` with status
1 (`ZMB_INCOMPLETE`), flags 4096 (`GF_MULTIBYTE`). No character conversion was
needed for that byte. The quote/parse sequence then reported `invalid_utf8` for
valid repaired JSON. A subsequent invocation even passed status 4634135. The
retained trace includes the matcher call stack.

The fix sets `ZMB_VALID` when a status pointer is supplied on the early return.
It covers both callers, leaves conversion errors and shift-state handling
unchanged, and changes no native structure, exported signature or ownership.
Callers using `CHARREF()` with a null status pointer remain supported.

## Regression and customer evidence

The shell-only regression alternates malformed text, an ASCII quote, valid
Unicode, repeated error classes and repeated negated error classes. It exercises
both `patmatch()` and `patrepeat()`. In 100 iterations, the preceding Clang-LTO
build reports 100 ASCII errors; the preceding GCC-LTO build reports 100 repeated
ASCII-class errors. Both fail the added D07 upstream regression. Both corrected
builds produce no errors. The available pristine GCC build passes these probes;
undefined behavior need not manifest in every build.

The unchanged zjson reproducer repairs bytes `e2 82 41 c3 a9`, quotes the result,
and parses it. Before correction, Clang reports `invalid_utf8`; after correction
both compilers return the replacement character, `A`, and `é`. The same debugger
condition produces no invalid ASCII-status observations after correction.

Both private builds use `-O2 -g -flto`, multibyte and PCRE support, and separate
matching module/function runtimes under `.work/round71`. Historical builds are
retained. This is a development-build validation, not a new package certificate.

- Unmodified zjson: 14,237 checks, zero failures in each of C and C.UTF-8 for
  each compiler (four successful runs).
- Full upstream suite: 64 successful scripts, zero failures and two skips for
  each compiler, including the new D07 regression.
- Unchanged OMZ terminal gate: 24 sessions per compiler, including completion,
  editing, history, prompt, syntax highlighting, async callbacks and interrupts.
- Clang Memcheck: shell-only regression and customer reproducer pass with
  `--error-exitcode=99 --track-origins=yes --leak-check=no`. This does not certify
  leak freedom or every upstream case under instrumentation.

After all builds, tests and debugger/Memcheck runs finished, the customer timer
ran nine alternating samples on CPU 13 for all thirteen kernels, comparing the
preceding GCC-LTO build with corrected GCC-LTO. Every resulting state matched.
Medians range from about 0.8% faster to 1.4% slower. Coder paste is
114.626 -> 113.690 ms, chat paste 210.371 -> 209.426 ms, and coder wide layout
66.454 -> 67.411 ms. All slower controls and raw samples remain in
`customer-gcc.json`. These small mixed differences establish no meaningful
speedup; this round fixes wrong results. No Clang-versus-GCC performance claim
or installed PGO-release performance claim is inferred from this comparison.

## Scope and reproduction

No active installation, user configuration, stable Zsh, published tag or source
archive is changed. The compiler decision remains open: fixing this blocker
alone does not establish a performance benefit or full packaged native-module
compatibility. Activation still requires `Packaging/verify.py verify` on the
exact package, including the native-library gate.

The minimal scripts and debugger commands are retained with the raw results in
`Perf/results/round71`. Run the scripts from the repository root with
`LC_ALL=C.UTF-8 /path/to/zsh -df SCRIPT`; their printed states are compared in
`differential.json`. The upstream assertion is in `Test/D07multibyte.ztst` and
can be run with `make check TESTNUM=D07` in a matching build directory.
