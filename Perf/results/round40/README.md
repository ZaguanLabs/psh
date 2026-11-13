# Round 40 evidence

The [audit](../../round40.md) withdraws the round-39 thread-locale output
optimization. The replacement is `1.0.0-rc1-519928894f02`, SHA-256
`c2dbffe4df42f9adfc77a5946685804ba2c14f4e1cd731ae66a8567c12245421`.
Publication and activation remain held; this directory is not a release asset.

- `round39-loader-regression.json`: the actual old candidate fails five of seven
  native-loading cases against pristine Zsh. It deliberately says `passed: false`;
  every reference observation passes. Output bytes, statuses and real load markers
  distinguish the regression from conversion errors or a fixture that never loads.
- `gconv-initial.json` and `loader-initial.json`: exploratory probes, including
  an early late-codec attempt whose LC_ALL setting prevented the locale change.
  The formal matrix corrects that setup and proves late loading occurred.
- `loader-pristine.json`, `loader-french-parent.json` and
  `selected-native-loaders.json`: replacement passes against pristine/system Zsh,
  including a French parent-process locale. Fourteen observations cover seven
  actual/unused-loader cases on this host. Runner and fixture sources are in
  `Perf/check-convfloat-loaders.py` and `Perf/convfloat-loader-library.c`.
- `round39-revocation.json`: the inactive faulty build's local activation receipt
  is revoked. The original receipt is retained in its private build directory and
  the original successful round-39 report remains historical evidence.
- `safe-*-native-loaders.json`: existing active rc0 and safe compiler-only rc1
  pass the new evidence gate without changing their binaries or activation.
- `installer-evidence.json`: data-only checks of the actual evidence-consumption
  function accept the valid report and reject missing/failed, wrong binary/path,
  and stale runner/library reports. No privileged activation runs in these checks.
- `formatter-restoration.json`: the converter body matches the pre-experiment
  source exactly. `final-protection.json` also proves no round-39 exports are
  removed, identifies the actual old-SDK binary used, and checks protected state.
- `native-full.json`: preceding safe/replacement builds against the pristine
  converter oracle, 1,555,200 comparisons with output and surrounding state.
- `native-memory.json`, `native-policy.json`, `printf-extension.json` and
  `native-summary.json`: exact-release Memcheck, the explicitly retired capability
  policy, old-SDK printf observers and an already-built round-39 module loading
  into the replacement. `--retired` requires formatting tracking to stay zero;
  scope capability checks remain independent. Existing historical checks are
  preserved rather than pretending the retired capability is still active.
- `selected-correctness.json` and named reports: twelve broader pristine
  comparisons. Native array raw-loan differences keep their previous explicit
  ownership classification. `stateful-inputs.tar.xz` preserves exact generated
  normal/Memcheck programs; available memory logs are also in `memory/`.
- `selected-build.json`, `selected-training.json`, `selected-validation.json`,
  `selected-ohmyzsh.json`, package-suite receipts/logs and installed-core receipt:
  exact inactive package, compiler feedback, native SDK/modules, all seven suites,
  63 successful upstream scripts/two skips and 24 unchanged OMZ terminal sessions.
- `restored-moonlit*.json`: five alternating samples plus excluded warmups in
  each of two comparisons with the safe compiler-only rc1. They retain the
  replacement's small slowdowns, not a new speedup claim.
- `restored-customer*.json`: thirteen actual offline customer kernels, nine
  samples each in two complete runs; all states match and slower samples remain.
- `withdrawal-control.json`: three alternating Moonlit samples against the
  withdrawn build, recording the approximately 10% time cost of the correction.
  All rendered outputs match in this workload without an injected formatter.
- `cross-run-consistency.json`: source/state consistency across repeats and the
  expected five rejected-candidate failures. Build, suite, profiling and checksum
  work do not overlap measured intervals.

The normal-user fixture creates private files only. It does not edit system NSS,
locale, loader or startup configuration. It requires GNU libc/loader interfaces
for injection cases; absent platform/locale coverage is reported explicitly.
Memory checks disable leak checking; quiet float-test logs can be empty on success.
The test suite is evidence for its covered cases, not universal compatibility
proof. Earlier source archives, published rc0 and the active shell stay intact.
