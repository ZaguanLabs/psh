# Round 28 evidence

Read [the investigation report](../../round28.md) for the implementation,
measurements, compatibility reasoning, slower controls and installed identity.

The root measurements describe the selected array-prefix change.
`customer-benchmarks.json` and `customer-repeat.json` retain both full customer
groups; `library-benchmarks.json` and `library-repeat.json` retain both library
groups. Parser, search and array controls include all cases and samples.
`hardware.json` contains counters, scheduling, fingerprints and samples;
`timing-commands.json` records all eight completed, isolated timing groups.
Warm operation timers and exec-through-exit counter scopes differ.

`deep-profiles.json` describes profiles of the actual preceding daily-driver
release. `matched-profiles.json` compares the parent/candidate builds with the
same customer inputs and resulting states. `instruction-summary.json` records
complete profile hashes, totals and `arrlen` caller attribution. Raw Callgrind
files are gzip-compressed; flat summaries retain all functions.

`scan-revisit/` contains the rejected unsorted/unfiltered scanner specialization,
its source patch, paired customer/library timing, and build records. Historical
commands name the original candidate path; its build was subsequently retained
locally as `.work/round28/scan-candidate` before rebuilding the selected change.
Those measurements are not attributed to the selected append optimization.
The prototype is not newly certified for correctness or adopted.

Final append state/loan receipts are `append-prefix-native.json`,
`clang-prefix.json`, `development-prefix.json` and `installed-prefix.json`.
Their ELF/module/fixture fingerprints bind 21,930 counted state snapshots and
additional fallback/native-loan checks across 30 Memcheck processes.
`append-prefix-pilot.json` is the initial smoke check; the fixture was later
extended to warm the readonly parameter before its refused write, so use the
final receipts' source fingerprints. `cache-native.json` retains both ordinary
malloc and Memcheck lifetime/mutation results. `cache-signals.json` and its GDB
log verify the unqueued-search guard. The other native/broad groups retain
commands, status and source/binary fingerprints alongside upstream logs.

`package-validation.json`, seven `test-*.json` receipts, `ohmyzsh.json`,
`installed-package.json`, `source-checks.json`, `patch-check.json`,
`release-identity.json`, `identity.json` and `activation.json` bind the new
installation, its tests, source reconstruction and preserved previous release.
The pre-push GitHub receipt records the unchanged historical draft/assets.

The archive excludes compiled fixture modules, launcher binaries, personal
protected-file snapshots and the private previous-release manifest. Relevant
aggregate protection results remain. `sha256.json` hashes every archived file
except itself. The Python drivers document exact historical commands; their
work directories and source snapshots must be reconstructed when reproducing.
