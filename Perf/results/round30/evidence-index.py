from pathlib import Path
import hashlib,json
out=Path('Perf/results/round30')
(out/'README.md').write_text('''# Round 30 evidence: decimal lexer prototypes rejected

[The report](../../round30.md) explains the measured tradeoffs and restored state.
The accepted daily driver remains `1.0.0-rc0-56f97a85e8cb`, with twenty-six
optimizations. No activation was performed.

`restoration.json` proves current production/source, developer binary and active
release identity, unchanged protected entries and the fresh active OMZ gate.
`active-*` reports contain fresh package/OMZ verification plus historical suites
for unchanged accepted artifacts; seven suites were not newly rerun on restoration.
`restored-small.json` and its Memcheck logs cover the restored developer host.
`restored-native-artifacts.json` records exact active module bytes copied back to
transient Vendor build outputs; trial bytes remain in its inactive prefix.

Root timing JSON covers nine completed groups comparing exact installed old/new
release executables on CPU 13, nine alternating samples per pair. Customer and
library groups are repeated. Parser/search/array controls, arithmetic token
controls and fully scheduled hardware counters retain slower cases. Warm timers
and exec-through-exit counters have different scopes. `activity-before.json`
is one aggregate observation, not a continuous activity audit.

`interrupted-timing/` retains the first batch's completed customer/library JSON,
partial parser log and status 143 receipt. Its SIGTERM cause is unknown; no failed
state comparison was reported. Its samples are not mixed with the final rerun.

`one-digit/` contains the first, narrow prototype's unapplied source patch,
private-build profiles and pilot validation. That prototype was not measured as
an installed candidate. The selected bounded proposal is retained as
`proposed-with-fixtures.patch`. Neither production source change is adopted.
Historical work paths may now hold a later or restored executable; use recorded
source/binary hashes and reconstruct the appropriate build before reproduction.

`source-checks.json`, `patch-check.json`, `candidate-closeout.py`,
`inactive-package.json`, `inactive-build.json`, `inactive-package-validation.json`,
`inactive-ohmyzsh.json`, `inactive-core-harness.json`, `inactive-terminal-profile.json`,
`test-*`, `identity.json` and `release-identity.json` describe the tested inactive
trial before restoration. They are not current active-source claims. The trial
`1.0.0-rc0-363dc2fc22b0` was installed for testing and never activated.

Final candidate native receipts are `small-native.json`, `clang-small.json`,
`development-small.json` and `installed-small.json`: 16,777,600 API observations
across ten Memcheck processes, with SDKs selected per host. Pilots bind their own
fixture fingerprints and remain separate. `setup-failures/` preserves the initial
SDK mismatch, reference Mario fixture invariant and missing local snapshot logs.
The report explains their corrections.

Compressed raw profiles, flat summaries, source/state hashes and command receipts
remain. The archive excludes compiled fixtures, private protected-file snapshots
and the local previous-release manifest. `sha256.json` hashes all archived files
except itself. Pre-push GitHub receipts record the unchanged historical draft and
seven assets; no public release was made.
''')
files={str(p.relative_to(out)):hashlib.sha256(p.read_bytes()).hexdigest() for p in out.rglob('*') if p.is_file() and p.name!='sha256.json'}
(out/'sha256.json').write_text(json.dumps(files,indent=2,sort_keys=True)+'\n')
print('Indexed',len(files),'files')
