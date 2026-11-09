# Round 33 evidence

The integer-power implementation and alignment variant are **unadopted**.
See [the report](../../round33.md) for the decision and all timing tables.
Production source/tests and the active/developer executables return to their
previous bytes. The accepted optimization count remains twenty-six.

`initial/` freezes the first candidate before changing its private build for
the layout experiment. Its installed release is the inactive
`1.0.0-rc0-52a0aa60cf05`; the active release remains
`1.0.0-rc0-56f97a85e8cb`. Recorded executable paths can have been reused after
the observation: use fingerprints to identify artifacts. The original private
ELF is preserved locally as `.work/round33/initial-zsh`, and the aligned one as
`.work/round33/aligned-zsh`; compiled binaries/modules are not committed here.

- `initial/proposed-with-fixtures.patch` is the complete unapplied proposal
  against parent `98a0bf506c05a333f07eea92791926f9f35fba6d`. It changes math.c,
  two C01 arithmetic blocks and three fixture files. `initial/source-checks.json`
  proves the integer calculation is its only production change; the float branch
  and public headers/declarations remain unchanged. `patch-preservation.json`
  separately replays the proposal after restoration and checks all recorded file
  hashes. COMPATIBILITY.md is among those hashes but has no patch hunk.
- `initial/validation.json` records the thirteen broad comparison groups.
  `initial/native-validation.json` reconciles 730,944 power observations in
  eighteen zero-error Memcheck processes across GCC, Clang, pristine DEBUG,
  development DEBUG and exact installed hosts. Detailed `*-power.json` and
  `power-native.json` bind each host, matching SDK/module and driver. Logs remain
  in their corresponding subdirectories; leak checks are disabled. The 160-case
  huge matrix runs on candidate hosts only. These are repeated observations,
  not 730,944 unique expressions or certification of all supported platforms.
- `initial/upstream.log`, the Clang/development logs and
  `initial/additional-builds-final.json` record successful upstream checks.
  `initial/setup-failures/` retains the first pristine C01 harness-directory
  error. The corrected invocation and passing retry remain separately recorded;
  the original failure receipt is not rewritten.
- `initial/inactive-build.json` retains the exact build/input manifest.
  `initial/package-validation.json`, `package-ohmyzsh.json`, native installed
  power evidence and seven `test-*.json`/logs certify that inactive package.
  The bundled native objects were tested before staging. Its OMZ receipt has
  24 sessions with unchanged re5et/git/highlighter and real terminal interaction.
  It was never activated. `initial/identity.json` and `release-identity.json`
  cover byte sizes, invocation modes and unchanged dynamic exports.
- `initial/timing-input.json` and `timing-commands.json` record all nine timing
  groups, their statuses and duration. Customer/library groups each have two
  complete passes; all controls and individual samples remain. Power cases have
  nine alternating observations each, explicit batch sizes and result hashes.
  Timings follow completed own builds/tests/profiles. The separate event
  launcher is compiled before its own counter measurements. External activity
  is not continuously audited. `hardware-scheduling.json` confirms fully
  scheduled counters for all four cases.
- `initial/matched-profiles.json` binds six private-host Callgrind runs to
  executable/worker/project/output fingerprints. All six raw profiles are
  retained as deterministic gzip files, with flat views and logs. Their
  whole-process instruction counts differ in scope from warm timers.
- `aligned-source.patch`, `aligned-identity.json`, `aligned-timing.json` and
  customer/library samples describe the exploratory alignment variant. It has
  nine paired samples per case, not repeated installed certification. No
  compatibility/package approval is claimed for this variant. Alignment changes
  other function placement too; these observations do not establish causality.
- `restoration.json` verifies canonical input hashes, unchanged active manifest,
  protected files, links, login shell and `/etc/shells`, plus the byte-identical
  developer ELF. `restored-development-upstream.log` is the fresh 62/0/3 run;
  `restored-power.json` records another 121,664 observations and two zero-error
  Memcheck processes, without huge tests. `restored-native-artifacts.json`
  records transient Vendor object restoration from the tested active payload.
- `active-validation.json`, `active-ohmyzsh.json` and terminal/core harness
  receipts come from fresh normal-user package verification after restoration.
  All 24 interactive sessions pass. `active-prior-test-*.json` are historical
  suite receipts reused for the identical active artifacts; full suites were
  rerun for the inactive trial, not for the unchanged active release.

Archived scripts describe the commands run at their recorded phase; they are
not a command to install the rejected proposal in the current worktree. Apply
the proposal to its recorded parent in a separate checkout to reproduce it.
Stable-file and previous-release snapshots stay local; only aggregate protection
results are archived. `github-precommit.json` preserves the original private
rc0 draft and seven assets. No tag/asset/publication changes are made.
`sha256.json` fingerprints this archive except itself.
