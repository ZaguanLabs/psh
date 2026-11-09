# Round 27 evidence

Read [the investigation report](../../round27.md) for scope, method, slower
controls, validation limits and the active release identity.

Root measurements and receipts describe the selected option-mask change.
`customer-benchmarks.json` / `customer-repeat.json` and
`library-benchmarks.json` / `library-repeat.json` contain both complete timing
groups. Parser and search controls include every measured case. Hardware JSON
contains raw and scaled counters, scheduling, source/state hashes and samples.
`timing.py` records the separate timing sequence; other Python drivers retain
build, profile, test, source-reconstruction and activation commands.

`queued-only/` retains the rejected guarded-callback implementation, source diff,
profiles and native checks. Those receipts do not validate the selected change.
`fixture-queue-setup/` retains the initial fixture's DEBUG queue diagnostic,
including the pristine baseline result and original fixture source. It was a
fixture failure, corrected before the final native reruns; do not count these
receipts as final passes. `clang-setup-missing.log` records a missing local helper
before the successful Clang builds.

Final native emulation receipts are `emulation-native.json`,
`clang-emulation.json`, `development-emulation.json`, and
`installed-emulation.json`. They bind their source/ELF/module fingerprints and
cover 567,220 scenario executions in ten Memcheck processes. Final native logs
are in their corresponding directories. The frontend receipt is
`emulation-front.json`.

`package-validation.json`, seven `test-*.json` receipts, `ohmyzsh.json`,
`installed-package.json`, `release-identity.json`, `source-checks.json` and
`activation.json` bind tests and installation to the new rc0 build. The GitHub
pre-push receipt confirms the historical draft/assets were untouched before
commit. The original tag continues identifying its historical checkpoint.

Callgrind files are gzip-compressed; flat summaries and exact hashes remain.
The archive omits compiled test modules, timing launcher binaries, personal
protected-file snapshots and the private previous-release manifest. It retains
their relevant aggregate verification results. `sha256.json` hashes all archived
files except itself. Historical failed experiments remain distinguishable from
passing final receipts.
