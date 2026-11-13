# Round 45 evidence

See [the report](../../round45.md) and [all timings](timings.md).
Gzip files retain complete text/JSON with zero compression timestamps.

- `bounded-array-copy.patch.gz`: production change against parent `86e4a66`.
- `before.json.gz`: characterization on pristine Zsh and preceding psh before
  changing the helper. `array-copy.json.gz` is the final three-host Memcheck
  comparison: 98 groups per host, including 3,456 shell slice observations and
  858 native bounded-copy checks across C and C.UTF-8.
- `arrays-pristine.json`, `arrays-previous.json`: 5,192 array comparisons each.
  `native-array-cache.json` retains the previously documented raw-array alias
  difference and separately checks the supported getter contract.
- `workload-smoke.json`, `benchmark-smoke-correction.txt`, `beyond-baseline.txt`:
  state-only workload checks and the corrected harness expectation for quoted
  beyond-end slices. No shell behavior changed to accommodate that expectation.
- `object*.callgrind.gz`, `object*callers.txt.gz`, `object*profile.out.gz`,
  `profile-summary.json`: actual release instruction profiles and full states.
  They include setup, warmup and validation; profiler duration is not a speed
  measurement. The summary records matching binary, worker and customer sources.
- `copies*.json`, `customer*.json*`, `applications*.json`, `measure*.py`,
  `measurement*.json`: both complete nine-sample comparisons and the focused
  21-sample URL/drawing controls. Raw output state hashes and all slower cases
  remain. Timing starts only after tests, builds and profilers finish.
- `345edd03d312-*`: exact package build/training metadata, suite receipts,
  full verification, 24 unchanged OMZ sessions and 14 native-library observations.
  Build provenance includes the pre-existing local packaging/gate edits, which
  are not part of this round's commit. `native-symbols.json` confirms the same
  1,070 exported dynamic symbol names as the preceding release.
- `compare.py`, `finish-checks.py`, their JSON reports and logs, `test-*.log*`:
  orchestration and successful upstream/bundled checks. The final core suite
  runs separately after other test/profile processes finish.
- `SHA256SUMS`: all archived evidence files except the checksum list itself.

The reusable fixture, comparison driver and benchmark live in `Perf/`.
Protected installation/account snapshots, compiled test modules and unrelated
local changes remain local. The candidate is installed inactive; the daily
shell still points to the published rc0 installation. No release is published.
