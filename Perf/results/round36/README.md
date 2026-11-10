# Round 36 evidence

The [report](../../round36.md) rejects both option-default traversal prototypes.
The active daily driver remains `1.0.0-rc0-bde30291d0ec`, SHA-256
`f3123ab771535d73d98ff318fac408b2a339dac0980b5fe9f7cf42fb7ed5a9a6`.
Neither candidate was packaged, installed or activated. There are still 27
accepted optimizations.

- [Parent](parent.json), [fused proposal](fused-source.patch) and
  [source identity](fused-source.json) bind the two-file production trial to
  `22bc13984a8b1d7fa791732737678e100e59e73b`. `queued-only/source.patch` retains
  the first guarded proposal. [Closeout](closeout.py) replays both and checks
  restored production inputs, installed payload and protected files.
- `queued-only/` contains the first prototype's validation, profiles, build
  logs and source patch. Its native oracle and upstream tests pass, but the
  guarded loop barely runs in customer profiles. Its planned timing script is
  not evidence of a completed timing phase. The root `fused-*` records describe
  the second proposal; root `previous-*` records describe the accepted-source
  private comparison build. `previous-build.json` is its build-command receipt,
  not a packaged-release manifest.
- [Matched profiles](matched-profiles.json) retain eight final whole-process
  Callgrind runs, source/binary/state fingerprints and flat views. Root
  `previous-*.callgrind.gz` and `fused-*.callgrind.gz` are the final profiles;
  another eight profiles under `queued-only/` belong to the first proposal.
  Compression is deterministic and raw instruction data remain intact.
- [First timing commands](pilot-timing.json), [repeat commands](repeat-timing.json),
  `customer-pilot.json`, `customer-repeat.json`, `library-pilot.json` and
  `library-repeat.json` retain all nine-sample alternating comparisons and state
  checks. Measurements use CPU 13 and C.UTF-8, after own builds/tests/profilers
  finish. They compare private release configurations, not an installed trial.
  Coder/chat repeat values vary markedly; no stable causal slowdown magnitude
  or cause is established. All slower and faster controls remain.
- [Broad validation](validation.json) covers 13 groups, with detailed JSON and
  logs. `initial-emulation-module.c` preserves the unextended native fixture
  used in those original comparisons. `emulation-native.json` and
  `pristine-emulation-native.json` concern that version, not the later extension.
  Accepted-source, guarded and fused upstream logs each record 63 passed,
  zero failed and two skipped scripts.
- [Extended accepted/fused checks](emulation-reentry.json),
  [pristine/installed checks](pristine-reentry.json) and
  [pristine DEBUG/development checks](development-reentry.json) pin the final
  extended fixture. Each pair has 233,032 observations in four Memcheck
  processes: 699,096 observations in 12 processes total, all final zero-error
  results, leak checks disabled. These are repeated observations of 58,258
  scenarios per host/locale. Per-process logs are retained. The new 1,536 cases
  cover deterministic generated-provider reentry and both output buffers.
- `queued-only/pristine-emulation-native.log` retains the initial SDK mismatch:
  a DEBUG-header fixture cannot import `queue_in` from a release host. Final
  release comparisons use matching headers. `fixture-setup-failure/` retains
  the new fixture's missing-add-callback source and NULL-call failure. The
  corrected final fixture passes on original Zsh as well as psh. Failed runs
  are excluded from the passing final totals.
- [Restoration](restoration.json) verifies all 1,853 canonical package inputs,
  1,603 installed manifest entries and 11,828 stable-Zsh/startup entries, unchanged
  developer ELF, `/etc/shells` and account login shell. Existing seven-suite
  package and 24-session OMZ receipts are reused only for the byte-identical
  daily driver. No new candidate OMZ or Clang certification is claimed.
  [Final checks](final-checks.json) summarize patch replay and extended results.
- Precommit GitHub receipts compare the private draft and seven assets exactly
  with the historical rc0 receipt. [Final checkpoint helper](final-checkpoint.py)
  verifies the pushed commit, clean tree, active binary and original tag/draft/
  visibility before updating ignored local metadata. Post-push receipts stay
  under `.work/logs/round36/`. No release or tag is published.

[SHA-256 index](sha256.json) covers every archived file except itself. Native
fixture binaries, interpreter binaries, build trees and private machine
snapshots stay local. Raw logs/patch whitespace is preserved. Passing coverage
does not establish universal compatibility or a new other-OS/32-bit guarantee.
