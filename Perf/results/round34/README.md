# Round 34 evidence

The live-level scope scanner is **not adopted**. See [the report](../../round34.md)
for private/installed comparisons and all dense/sparse controls. Production
source/tests and active/developer executables are restored to their previous
bytes. The accepted optimization count remains twenty-six.

- `proposed-with-fixtures.patch` applies the two C edits and three test/timing
  tools to parent `8432071d9d6bc633ad19a2f695b4df6917085416`.
  `source-checks.json` proves that the new helper and one scope-exit call are
  its only production changes. It records the unchanged generic scanners,
  restoration/history/locale/signal code and public structures, plus the one
  added core prototype/ELF symbol. `patch-preservation.json` replays all five
  files after restoration and verifies their recorded hashes.
- `scope-native.json`, `pristine-scope.json`, `clang-scope.json`,
  `development-scope.json` and `installed-scope.json` bind every matching SDK,
  compiled fixture, executable and source/driver fingerprint.
  `native-validation.json` reconciles 14,112 scenarios in fourteen zero-error
  Memcheck processes (leak checks disabled). Each host/locale has 1,008
  scenarios, not that many unique expressions across the repeated matrix.
  Independent expected callback traces/counts validate actual end-of-scope
  operations, including live level changes and generated-provider delegation.
- `validation.json` records twelve broad groups; `pre-pilot-validation.json`
  and `additional-builds.json` record GCC/Clang/DEBUG/pristine checks.
  `hash-scans.json` separately records 481,248 generic scan scenarios under
  four Memcheck processes. Original project-suite output and correctness states
  remain in their own receipts. Raw failure logs under `fixture-errors/`
  preserve the repaired fixture-name collision, installer argument mistake and
  caller-annotation orientation mistake. These are setup failures, not removed
  product failures.
- `matched-profiles.json` binds eight Callgrind runs and their output/project
  states. All eight raw profiles are retained with deterministic gzip, alongside
  flat and inclusive caller views. `profile-metrics.py` deduplicates annotated
  edge views and records scope exits, instructions and cleanup callback counts.
  These whole-process instruction counts differ from warm timer scope.
- `customer-pilot.json`, `library-pilot.json` and `pilot-timing.json` retain the
  nine-sample private-build pilot, including slower controls. Private gains and
  baseline medians are not substituted into installed-build results.
- `inactive-build.json` binds the exact inactive release
  `1.0.0-rc0-9e2e75ec24d7`. `inactive-validation.json`, `inactive-ohmyzsh.json`,
  terminal/core harness receipts and seven suite receipts/logs describe its
  successful package checks, all 190 zdraw tests and 24 genuine OMZ sessions.
  Tested native modules are staged before verification. `identity.json` records
  preserved existing exports, one added internal symbol and unchanged stripped
  byte size. This package was never activated. The private trial ELF is also
  retained locally at `.work/round34/rejected-zsh`; binaries are not committed.
- `timing-input.json`, `timing-commands.json` and `timing-preconditions.json`
  bind all nine installed timing groups. Customer/library comparisons each
  have two complete groups of nine alternating samples per case. CPU affinity
  is 13; all states and input hashes match. Own builds/tests/profiles finish
  before timing. The event launcher compiles before its own measurements;
  observer modules are prebuilt. The brief CPU pre-observation is not a
  continuous external-activity audit. All slower controls and raw samples stay.
- `scope-benchmarks.json` retains all 42 paired cases, with rotated/reversed
  case order across nine samples, loop controls, native table observations and
  restored binding/table checks. Timed warm batches exclude construction,
  warmup, observations and final validation. `observer-builds.json` records
  separate matching installed SDK builds. Dense and retained sparse capacity
  have materially different results; neither is omitted.
- `hardware.json` has four installed whole-process counter cases.
  `hardware-scheduling.json` confirms fully scheduled counters. Counts and
  branch misses inform the analysis but do not establish the cause of timing
  differences or an application-startup speedup.
- `restoration.json` verifies all 1,853 canonical input hashes, unchanged
  active manifest/links/protected files, `/etc/shells` and login shell, and
  the byte-identical developer ELF. The restored developer passes 62/0/3 and
  another 2,016 scope scenarios under two zero-error Memcheck processes.
  `restored-native-artifacts.json` records transient Vendor object restoration.
  The inactive prefix retains trial objects; stable Zsh remains untouched.
- `active-validation.json`, `active-ohmyzsh.json` and associated receipts come
  from fresh normal-user verification after restoration, including 24 new
  interactive sessions. `active-prior-test-*.json` are historical suite receipts
  reused for the identical active artifacts; full suites were rerun for the
  inactive trial rather than the unchanged active package.

Archived scripts record their historical phase. `candidate-closeout.py` ran
with `--source-only` before rejection; do not run it against restored source
expecting to reconstruct the candidate. Reproduce the proposal in a separate
checkout of its recorded parent. The original phase paths may later be reused;
fingerprints identify the tested artifacts. Stable-file/previous-release
snapshots stay local; only aggregate protection proof is archived. Raw log and
patch-context whitespace is preserved. The pre-commit GitHub receipt retains
the original private rc0 draft/seven assets. No tag or release asset changes
are made. `sha256.json` fingerprints this archive except itself.
