# Round 44 evidence

See [the report](../../round44.md). Gzip files retain complete JSON/text with
zero compression timestamps. Profiling and timing are separate operations.

- `glob-programs.patch.gz`: the production trial against parent `87f6251`.
  It adapts upstream workers 55203 while preserving legacy parser prototypes.
- `before.json*`: original 136-case pristine/preceding-release characterization.
- `before-harness-errors.json*`: rejected harness with unintended module-load
  diagnostics and an incorrectly braced replacement string.
- `release-check.json.gz`: final 148 cases on pristine Zsh, preceding psh and
  candidate psh, all under Memcheck. Complete bytes/status must match.
- `heap-check.json.gz`: the same 148 cases on allocator-aware diagnostic builds.
- `*-check-initial.json*`: earlier 136-case checks, retained separately.
- `diagnostic-builds.json`, `*-heap-config.h.gz`, `heap-build.log.gz`: diagnostic
  build configuration and binary identities. These binaries are not timed.
- `native-symbols.json`: all original dynamic symbols retained, two additional
  core helpers, identical original parser prototypes in generated headers.
- `pattern-reference.json*`: 63,840 pattern checks against pristine Zsh.
- `profile*.py`, `memory-profile*.json`, `*.massif.gz`, `*-peak.txt*`: actual
  release memory profiles and full output hashes. Malloc-only profiles miss
  mmap-backed arenas; page profiles account for those mappings. Page allocations
  are not RSS, and no elapsed speed claim is derived from Valgrind runs.
- `core-concurrent-failed.*`: the original V14system timing failure, retained
  before the isolated repeat; upstream thresholds are unchanged.
- `fcff3fb31d43-*`, `core-isolated.log`, `final-checks.json`, `verify.log`,
  `test-*.log.gz`: exact-package provenance and successful final core, bundled,
  OMZ and native-library checks. The first aggregate package log remains failed
  because of its original core timing failure; the isolated core rerun replaces
  that suite's receipt without rerunning already-passing bundled suites.
- `glob.json*`, `glob-repeat.json*`, `customer.json*`, `objects.json`,
  `measurement-session.json`, `measure.py`, [timings.md](timings.md): both complete
  paired glob comparisons and all eighteen customer/JSON controls. Raw RSS and
  elapsed samples, binary/source identities and complete-state hashes remain.

The current project scripts contain the reusable test/native fixture and paired
memory/timing driver. Stable installation/account snapshots and the unrelated
pre-existing local diff are deliberately kept local.
