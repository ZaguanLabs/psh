# Round 29 evidence: both hash prototypes rejected

[The report](../../round29.md) explains why the installed daily driver retains
its original hash function and twenty-six accepted optimizations.

`restoration.json` is the current-state proof: production inputs match the active
accepted release, the developer ELF is byte-identical to its prior accepted
build, release links were never switched, and protected files are unchanged.
`active-*` reports contain fresh package/OMZ checks and historical suite receipts
for unchanged active artifacts. They do not represent newly rerun seven suites.
The active prefix remains `1.0.0-rc0-56f97a85e8cb`.

Root timing JSON is the final comparison of the exact old and inactive installed
releases, CPU 13, nine alternating samples per pair. Both complete customer and
library groups, parser/search/array controls, hardware counters and native
key-length controls are retained. `final-activity-before.json` is one aggregate
observation, not a continuous system-activity audit. Warm timers, native hash
call timers and exec-through-exit counters have different scopes.

`grouped-initial/` retains the first four-byte-grouping prototype, its source
patch, full timings, profiles and validation. Its original work path later held
the second prototype; the first ELF is retained locally as
`.work/round29/grouped-initial-zsh`. Its private-build gains are not an installed
performance certification, and its short-key regressions motivated the peel.

`peeled-noisy/` retains all nine groups from the variable CPU-2 private-build
pass, including extreme slower/faster controls. An activity observation records
aggregate CPU usage only. The cause of that pass's variability was not isolated.
It is not used as a basis for adoption, and its baselines are not mixed with
other passes. `peeled-source.patch` is the unapplied second prototype.

`source-checks.json`, `patch-check.json`, `proposed-with-fixtures.patch`,
`candidate-closeout.py`, `inactive-package.json`, `inactive-build.json`,
`inactive-package-validation.json`, `inactive-ohmyzsh.json`, `test-*.json`,
`identity.json` and `release-identity.json` describe the tested inactive candidate,
before restoration. They must not be read as current active-source claims.
Source reconstruction requires the recorded parent and proposed sources.
The candidate `1.0.0-rc0-e1f66a23cf65` was installed for testing and never activated.

Final candidate native receipts are `hash-native.json`, `clang-hash.json`,
`development-hash.json` and `installed-hash.json`: 5,384,280 repeated input checks
across ten Memcheck processes. `restored-hash.json` checks the restored developer
host separately. Initial pilot receipts bind their own earlier fixture inputs.
The module's timing builtin was added after the initial smoke check; final
receipts bind the final source fingerprint. `hash-machine-code.json` binds the
profiled and installed leaf routine bytes; it does not compare whole executables.

`restored-package-verification-initial.log` retains the expected failure caused
by transient Vendor module outputs from the trial. `restored-native-artifacts.json`
records restoration of exact previously tested active module bytes, preserving
the trial modules in its inactive prefix. `restored-package-verification.log`
records the successful rerun. No verifier check or installed release was changed.

Raw profiles are compressed; flat summaries and fingerprints remain. Historical
commands reference work paths that must be reconstructed for reproduction. The
archive excludes compiled fixtures, launchers, personal protected-file snapshots
and the private previous-release manifest. Aggregate protection results remain.
`sha256.json` hashes every archived file except itself. The pre-push GitHub receipt
records the unchanged historical rc0 draft/assets; no release was published.
