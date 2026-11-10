# Round 35 evidence

The accepted [report](../../round35.md) describes the parameter-scope bucket
index. The active private iteration is `1.0.0-rc0-bde30291d0ec`, with installed
ELF SHA-256 `f3123ab771535d73d98ff318fac408b2a339dac0980b5fe9f7cf42fb7ed5a9a6`.
The parent is `dcc2ed1e3023feb583303032c127624bcecb83f9`; the preceding daily
driver is `1.0.0-rc0-56f97a85e8cb`.

## Source and identity

- [Source checks](source-checks.json), [patch replay](patch-check.json),
  [frozen inputs](frozen-inputs.json) and [loader boundaries](loader-boundary-check.json)
  cover the complete [41-file incremental patch](../../0035-indexed-parameter-scopes.patch).
  Every changed core file reconstructs its parent exactly after removal of the
  recorded transformations. All 1,853 canonical package inputs match and all
  1,847 pristine release files are verified.
- [Identity](identity.json), [release identity](release-identity.json) and
  [installed package](installed-package.json) bind binaries, native modules and
  build profiles. Existing public structures, signatures and 1,056 ELF exports
  remain; seven helper exports are added. The development ELF retains DEBUG.
- [Vendor patches](vendor-patches.json) and the checked manifest preserve
  imported revisions and record the three conditional setup acknowledgments.

## Correctness and native lifecycle

- [Validation](validation.json), [final native commands](native-final.json),
  [additional builds](additional-builds.json) and
  [additional upstream checks](additional-upstream.json) identify exact commands
  and outcomes. GCC and Clang parent/candidate upstream results are 63 passed,
  zero failed, two skipped. DEBUG has 62 passed, zero failed, three skipped.
- The root `scope-*.json`, `pristine-scope.json`, `clang-scope.json`,
  `development-scope.json` and `installed-*.json` matrices contain 28,392
  scenario observations in 26 zero-error Memcheck processes. Each host/locale
  executes 1,092 cases; repeated observations are not unique scenarios. Leak
  checking is disabled. Matching per-process logs are retained in subdirectories.
- [Lifecycle](lifecycle.json) covers signal-trap unload and aware-to-opaque
  reload at the same path under four additional Memcheck runs.
  [Old modules](old-modules.json) adds 4,368 observations in two processes with
  previously installed modules; unacknowledged code selects legacy scanning.
  [Growth](growth.json) covers actual rehashing, shrinkage, caller locals and
  name reuse on four hosts under Memcheck.
- Arithmetic, scalar, array, search, pattern, substitution, numeric API,
  generic hash, accessor, emulation and completion JSON/logs retain the broad
  differential checks. [Customer correctness](customer-correctness.json) and
  [additional project tests](additional-project-tests.json) cover project kernels
  and original project suites.

## Measurements

- [Timing commands](timing-commands.json) and [preconditions](timing-preconditions.json)
  describe nine installed comparison groups, nine alternating samples per case
  on CPU 13. Customer and library comparisons have independent repeat groups.
  All slower controls and sample values remain. These are offline kernels;
  no full application startup claim follows.
- [Scope comparisons](scope-benchmarks.json) retain all 42 dense/sparse controls,
  including loop cost and retained capacity. The roughly fifteenfold dense
  empty-function result applies only to that control.
- [Matched profiles](matched-profiles.json) and [metrics](profile-metrics.json)
  refer to the eight final root `*.callgrind.gz` files and their flat/caller views.
  Raw profiles use deterministic gzip. The earlier pilot profiles are separate.
- [Hardware](hardware.json) and [scheduling check](hardware-scheduling.json)
  retain fully scheduled counters. Own builds, tests and profiles preceded the
  installed timing phase; external activity was not continuously audited.

## Packaging, activation and private checkpoint

[Package validation](package-validation.json), seven `test-*.json` suites and
their logs cover the installed package, including 190 zdraw tests.
[Oh My Zsh](ohmyzsh.json) records 24 genuine terminal sessions using the unchanged
re5et/git/syntax-highlighter setup, including completion, history, prompt, async
and Ctrl-C behavior. [Activation](activation.json) records the exact installed
ELF and unchanged previous-release manifest (1,603 entries), protected stable
Zsh/startup manifest (11,828 entries), `/etc/shells` and account login shell.

The precommit GitHub receipts preserve the original private rc0 draft and seven
assets. [Final checkpoint helper](final-checkpoint.py) checks the pushed commit,
active binary, original tag, draft and visibility, then updates only ignored
local checkpoint metadata. Its post-push receipts remain under `.work/logs/round35/`.
No new public release or tag is created.

## Historical attempts and archive integrity

`bootstrap-legacy/` contains the initial missing-main-acknowledgment run; its
passing legacy tests do not certify indexed execution. `indexed-pilot/` retains
the early source, profiles, timings and GCC counter-elision disassembly.
`pre-loader-final/` contains intermediate native/lifecycle receipts, distinct
from final root evidence. Root pilot files also identify their intermediate
binaries; use the final installed comparisons for accepted performance claims.
`setup-failures/` retains rejected vendor pins and the malformed compact zmdown
preprocessor edit. Failed build directories and intermediate ELF files remain
local; these archives include their source/log receipts, not the binaries.

[SHA-256 index](sha256.json) covers every archived file except itself. Raw logs
and patch context retain their original whitespace. Build directories, private
machine snapshots and executables are not committed. Coverage does not prove
universal compatibility; no new 32-bit, other-OS or allocation-failure-injection
certification is claimed.
