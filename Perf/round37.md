# Round 37: arithmetic state-contract maintenance

This maintenance iteration is active as `1.0.0-rc0-7e8f4c48abf5`. It centralizes
recursive arithmetic saves/restores, documents ownership and result channels,
adds state-boundary regression coverage, and fixes development-baseline module
isolation. The count remains **27 accepted optimizations**; no speedup is claimed.

The complete installed core `.text`, `.data` and `.bss` sections are identical
to the preceding release. All 40 native modules also retain identical `.text`
sections. The stripped executable remains **854,680 bytes**, with the same
1,063 dynamic exports. Its SHA-256 is
`8f4b852f5e26aac6942b956f064ee1629177c0c5ffc3702b57b2513be8db837d`.

## State boundary and selected implementation

The [state/ownership map](arithmetic-internals.md) distinguishes four categories:

- Nine parser/stack fields restored by nested `mathevall()` calls.
- `mtok`, handled by the public/internal entry-point wrappers and the comma
  protocol used for function arguments.
- Shared result channels: `lastmathval`, output radix and underscore formatting.
- Shell-owned errors, options, locale and parameter state, plus the separate
  recursion counter and process-lifetime conversion locale.

An indiscriminate context object would conflate those lifetimes. The selected
change defines the nine existing save pairs once and expands that same list for
both directions. Existing typed flat locals, initializations, statement order,
recursion-limit behavior, lazy variable retrieval and final-result publication
remain. The private helper macros are undefined immediately after the routine.
There is no runtime context object, new allocation, extra indirection, new native
interface, changed public structure or raised C-language requirement.

GCC and Clang release comparisons establish stronger evidence than matching
sample outputs alone: their complete preprocessed arithmetic translation-unit
token streams are equal, including string literals and C operators. Every
allocated arithmetic-object section and its text relocations match. All 124
generated native declaration/module headers per compiler also match. Expanding
the field list back to the old statements reconstructs the original `math.c`
exactly. The five-file [incremental patch](0037-arithmetic-state-contract.patch)
is replayed against parent `9c04d7a6bc055e510bc45ab8cb2f08f1dec8a369`.

At installed-executable level, the only changed allocated sections are the
GNU build identifier and `.rodata`. Replacing the old release name with the new
one in the old readonly data reproduces the new readonly data exactly: those
differences are the compiled private installation paths. This change adds no
executable work or core memory-layout change in these builds. Debug information
and source locations naturally differ.

## Alternatives retained

The first typed save-record implementation passes broad differential, focused
memory and GCC/Clang upstream checks. However, GCC reserves 64 additional stack
bytes per evaluator frame: 3,272 becomes 3,336 bytes, before the unchanged saved
registers/return address. Its arithmetic text remains 15,291 bytes but changes
instructions. That extra storage is unnecessary for this cleanup, so the record
is not selected. Its source, binaries locally, receipts and eight raw profiles
remain. Those profiles are not substituted for the final installed profiles.

Object-only probes also retain a separate early-error result, readonly operator
metadata, and a declaration-generating field list. They either retain the larger
frame or change generated code/data placement. Their sources, commands, assembly
and fingerprints are retained without claiming runtime certification. The
selected flat-local pairing preserves the original generated code instead.

## Development module isolation

The DEBUG pristine comparison exposed a workflow defect: `Perf/build.py` gave
both baseline and candidate the `.work/runtime` prefix. After a candidate build,
the pristine shell could attempt to load psh's `zsh/mathfunc` and fail with an
undefined `psh_scope_module_ack` symbol. The failed run completed zero arithmetic
cases and is excluded from passing totals; it is not a Zsh evaluator defect.

The builder now configures the pristine shell with `.work/baseline-runtime` and
installs each host's own default modules as well as its per-build module copy.
The candidate keeps `.work/runtime`. Both real DEBUG shells successfully load
their matching mathfunc and evaluate `sqrt(4)`. The old baseline tree is retained
locally; its source, failure and identity receipts remain in the archive. The
rebuilt isolated pristine DEBUG host passes its upstream and focused checks.
Release-profile comparisons already used separate runtimes.

## Verification

- The final 13-group broad comparison passes, including **195,600 arithmetic
  comparisons** across five locales, scalar/array/search/pattern/substitution
  checks, native numeric APIs, generic hash mutations, custom accessors, PTY
  completion, option emulation, customer kernels and five original project suites.
- New focused coverage has **54 expressions**, native/ksh/sh modes and four
  option contexts: 648 paired comparisons per locale. Nested calls vary
  precedence, radix, floating results, function arguments and lazy lvalues;
  short circuits, recursion limits and post-error recovery are included.
- Focused Memcheck runs cover GCC parent/final, Clang parent/final, pristine
  release/exact installed shell, and isolated pristine DEBUG/developer shell.
  C and C.UTF-8 give **5,184 paired comparisons in 16 instrumented host/locale
  invocations**, including forked subshells. Every final quiet error log is empty;
  leak checks are disabled. The SDK/runtime setup failure is separate.
- Final GCC and Clang upstream results are 63 passed, zero failed, two skipped.
  Both rebuilt DEBUG hosts pass 62, zero failed, three skipped.
- All seven package suites pass, including the complete zdraw suite in both
  locales. `Packaging/verify.py verify` passes with **24 unchanged OMZ terminal
  sessions**, the existing re5et/git/highlighter stack, actual completion,
  history, prompt, async and Ctrl-C checks, installed components and startup tests.

## Exact installed workload checks

Old `1.0.0-rc0-bde30291d0ec` versus new `1.0.0-rc0-7e8f4c48abf5`: nine alternating
samples per case on CPU 13 in C.UTF-8, with matching states and pinned binaries,
workers and project sources. Own builds, tests and profilers finish first.
External activity is not continuously audited. Timers exclude startup and setup;
these are offline project kernels, not full application-startup measurements.
Positive time changes are slower. Customer units are milliseconds per batch;
library units are milliseconds per call.

| Kernel | First old → new | Time change | Repeat old → new | Time change |
| --- | ---: | ---: | ---: | ---: |
| coder paste | 115.568 → 117.459 | +1.64% | 116.602 → 117.634 | +0.89% |
| coder layout | 5.793 → 5.783 | -0.17% | 5.791 → 5.792 | +0.02% |
| coder wide layout | 65.682 → 65.810 | +0.19% | 66.210 → 65.938 | -0.41% |
| chat paste | 210.182 → 207.771 | -1.15% | 209.642 → 215.325 | +2.71% |
| chat layout | 5.808 → 5.787 | -0.36% | 5.815 → 5.805 | -0.17% |
| chat wide layout | 65.393 → 65.430 | +0.06% | 65.483 → 65.669 | +0.28% |
| Endgame | 44.568 → 44.191 | -0.85% | 44.289 → 44.644 | +0.80% |
| Mario | 20.451 → 20.614 | +0.80% | 20.380 → 20.630 | +1.23% |
| z3dfx | 11.937 → 12.003 | +0.55% | 11.858 → 12.066 | +1.75% |
| z3dfx.agy | 11.814 → 11.972 | +1.34% | 12.000 → 12.132 | +1.10% |
| z3dfx.grok | 11.876 → 12.001 | +1.05% | 11.855 → 12.060 | +1.73% |
| URL encoding | 13.960 → 13.891 | -0.49% | 14.029 → 13.924 | -0.75% |
| drawing binning | 13.095 → 13.087 | -0.06% | 13.097 → 13.053 | -0.34% |
| JSON array | 92.879 → 92.045 | -0.90% | 93.304 → 93.707 | +0.43% |
| JSON encoding | 204.595 → 206.569 | +0.96% | 206.759 → 207.346 | +0.28% |
| JSON validation | 92.274 → 91.118 | -1.25% | 91.944 → 91.340 | -0.66% |
| navigation | 1.930 → 1.960 | +1.57% | 1.921 → 1.961 | +2.11% |

Every slower result remains. No causal speed change or aggregate improvement
is inferred from these fluctuations. The zero generated-runtime-cost conclusion
rests on code/data/layout identity, not on selecting favorable medians.

Eight final exact-installed Callgrind profiles retain matching states and
source fingerprints. Old/new whole-process instructions are coder
1,298,710,170/1,298,710,106; chat 2,192,599,825/2,192,599,823; Endgame
1,145,829,724/1,145,829,722; JSON encoding 2,546,923,380/2,546,923,380.
These negligible whole-process differences do not establish an optimization.

## Protection and limits

The isolated installer activates only after these checks. All 1,603 entries of
the preceding release and 11,828 protected stable-Zsh/startup entries remain
unchanged, as do `/etc/shells` and the account login shell. Existing processes
retain their old release paths. No framework, theme, plugin or personal startup
file is edited. All 1,853 canonical package inputs match; all 1,847 pristine
release files are verified. The original private rc0 tag, draft and seven assets
remain historical checkpoints, with no publication or version bump.

No new parser instance model, execution-plan cache, allocation ownership scheme,
readonly operator tables or language/ABI departure is introduced. This is a
bounded foundation for later modernization. No fresh other-OS, 32-bit or
non-multibyte certification is claimed. The [evidence index](results/round37/README.md)
distinguishes final certification, rejected prototypes and setup failures.
