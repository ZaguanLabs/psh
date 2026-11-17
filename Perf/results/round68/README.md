# Round 68 evidence

See [the report](../../round68.md). No production change is adopted.

- `candidate.patch.gz`: corrected one-pass explicit-separator prototype.
- `before.json.gz`, `pristine.json.gz`, `candidate.json.gz`: complete 21,840-case
  ordinary splitter behavior, including growth cases.
- `final-memcheck.json.gz`: keyed 840-case instrumented comparison, zero
  status/output differences. Leak checking was disabled.
- `native/sep-alloc-probe.c.gz`: final private native fixture. `report.json.gz`
  covers eight passing host/locale/plain-or-instrumented runs with one stdout hash.
- `upstream.log.gz`, `ohmyzsh.json.gz`, `ohmyzsh.log.gz`: completed 63-script and
  24-session validation for the repaired candidate.
- `upstream-cursor-unset.log.gz`: failed pre-initialization upstream attempt.
- `ohmyzsh-initial-failure.txt`: observed candidate-handoff failure summary.
  The original raw log was overwritten by the corrected run. This file records only
  the observed summary, not a recovered full transcript or an improvement claim.
- `profile-before/` and `profile-after/`: matched profiles with identical states.
- `focused-timing.json.gz`: all focused samples and separately retained process/
  inner-batch timings.
- `customer-timing.json.gz` and `customer-repeat.json.gz`: both complete thirteen-
  kernel comparisons, including slower primary workloads and faster controls.
- `build.log.gz`, `rebuild.log.gz`, `cursor-fix-build.log.gz`,
  `restoration-build.log.gz`: prototype build history. `source-identity.json`
  records distinctive binary hashes, restored source hash and related inputs.
