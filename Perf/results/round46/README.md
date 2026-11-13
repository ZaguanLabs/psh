# Round 46 evidence

See [the report](../../round46.md) and [complete timings](timings.md).
Gzip files retain complete data with zero compression timestamps.

- `lexer-scratch.patch.gz`: production change against parent `c983a44`.
- `before.json*`: 328-case pristine/preceding-release characterization before
  editing production code. `before-harness-status.json*` retains the original
  wrong fixture expectation for an always block's failure status.
- `lexer-release.json*`: final 328-case three-host comparison under Memcheck.
  Full raw output, diagnostics and status remain. `glob-check.json*` adds 148 existing
  glob-qualifier cases, including original-header native parser ownership.
- `initial-trial/`, `guarded-trial/`, and the `f0cacb372578-*` / `884cfe71d8a3-*`
  metadata retain superseded candidates. The first gained explicit NULL guards;
  the second gained a pointer alias for optional stack storage to remove VLA
  address warnings. Neither trial is used for adoption or timing claims.
- `stack-path.json`, `stack-*-config.h*`: strict syntax checks for VLA and alloca
  configurations, source hash, and identical default preprocessing across the
  final declaration adjustment. These are compile checks, not platform runtime
  coverage. `native-symbols.json` records the unchanged 1,070 exported names.
- `*-pages.massif.gz`, `*-peak.txt*`, `memory-profile.json`, `profile.py`:
  actual release mapped-page profiles and full filename-list hashes. This is
  not RSS or elapsed timing, and arenas can contain allocations from multiple
  call sites. Original profiling logs remain.
- `customer-profile.json`, `baseline-coder*`, `candidate-coder*`: initial
  customer profile, before discovering sibling bytecode caches. Its input
  manifest omitted those caches; do not treat it as a forced text-parse result.
- `customer-loading-profile.json*`, `current-*-coder*`, `text-*-coder*`,
  `profile-customer.py`, `coder-loading.strace*`: follow-up profile with cache
  and source metadata, private text-only copies, matching states in all four
  runs, and a read-only trace confirming actual util/input cache opens.
- `customer-state-check.json*`, `customer-state-check.py`: 13 kernels, two
  releases, two loading modes; all 52 complete states match. The source-only
  mode must match the current cached workload, without editing project files.
- `126770ba80d2-*`, `test-*.log.gz`, `final-checks.json`, `check-session.json`,
  `run-checks.py`, `verify.log.gz`: exact-package provenance and final upstream,
  bundled, OMZ and native-library results. Build provenance includes the
  pre-existing packaging/gate edits excluded from this round's commit.
- `glob*.json`, `customer*.json*`, `applications*.json`, `fresh-customer*.json*`,
  `text-customer*.json*`, `measure.py`, `measurement-session.json`: all samples
  from both nine-sample alternating comparisons, including slower controls.
  Warm-operation timings and fresh-kernel process timings have distinct scopes;
  neither fresh kernel mode is a complete app launch.
- `input-metadata-before.json*`, `input-metadata-after.json*`: matching source
  and bytecode cache hashes, sizes and modification times across the entire
  timing session, including existing warm customer/JSON drivers.
- `SHA256SUMS`: hashes for all archived evidence files except the list itself.

The reusable lexer comparison and customer process timer are in `Perf/`.
Protected installation/account snapshots, unrelated local edits and compiled
fixture modules remain local. The release remains inactive; no public release
is published. Timing runs do not overlap builds, tests or profilers.

The archive integrity check caught an output-name collision: the glob timer
replaced the original `glob.json` correctness report and log. The original
orchestrator/check-session record retains its successful exit. After all timing
finished, the same 148-case Memcheck matrix was rerun as `glob-check.json` to
restore complete raw evidence. `run-checks-original.py` retains the original
orchestrator; `run-checks.py` uses distinct output names for future runs.
