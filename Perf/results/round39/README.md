# Round 39 evidence

See [the investigation](../../round39.md) for the candidate, exact hashes,
methods, results and remaining native-integration boundary. Publication and
activation remain held. This directory contains evidence, not a release archive.

- `final-scenes.json`: six full customer scenes, five alternating samples per
  host plus excluded warmups, complete palette/material/depth comparisons.
- `final-scene-repeat.json`: independent five-sample Moonlit comparison.
- `final-customer*.json`: all thirteen offline customer kernels, nine samples
  each in two complete runs. Slower/flat controls are retained.
- `same-binary-fallback.json`: identical candidate ELF and native module, with
  only the baseline's empty preload marker selecting legacy float conversion.
  `opaque-preload.so-binary.json` fingerprints that object; its source is
  `Perf/convfloat-opaque-preload.c`, compiled with
  `cc -O2 -shared -fPIC SOURCE -o OUTPUT`. No hooks or constructors are present.
- `guarded-moonlit.*` and `pilot-scene-benchmark.py`: preliminary five-sample
  guarded trial before early marker capture/final tested-module refresh. The
  frozen driver matches the hash in that historical report.
- `baseline-moonlit.callgrind`, `*-flat.txt`, `*-inclusive.txt`: complete
  instruction profile of the preceding optimized release. Profile wall time is
  excluded from performance measurements; inclusive costs overlap.
- `convfloat*characterize*`: pristine-versus-previous-converter characterization.
- `final-native-full.json`: preceding/final builds against the pristine native
  output/state oracle, five global and three thread-locale contexts.
- `final-native-memory.json`: exact release executables under Memcheck; their
  production preload policy deliberately selects legacy formatting.
- `diagnostic-memory.json`: separate instrumented fast-path memory coverage.
  `diagnostic-newlocale.json` and `diagnostic-enter.json` require positive
  injected failure counts while preserving the oracle results. Counters in
  private-thread contexts are cumulative; those calls use the legacy path.
- `diagnostic-build-commands.json`, `diagnostic-binary.json`: isolated ordinary
  build with `-DPSH_TEST_FLOAT_ALLOW_PRELOAD` and GNU linker wrapping. Its fault
  object is built from `Perf/convfloat-fault.c` with
  `cc -O2 -g -DPSH_LINKED_FAULTS -c SOURCE -o OBJECT`; link flags in the recipe
  point to that object. This bypass is absent from the distribution build.
  Use `check-convfloat.py --linked-faults-candidate --fault newlocale|enter
  --expect-candidate-faults` against this diagnostic host. No diagnostic timing
  contributes to a claimed gain.
- `no-locale-api*`: configure cache forces `zsh_cv_math_strtod_l=no`; the
  resulting compile-time fallback compares against pristine Zsh in five locales.
- `final-policy.json`: independent scope/formatting capabilities, constructor
  suspension, unload/reload, failed loads, sticky disable, real pending traps,
  and startup markers removed before script-level loading.
- `final-printf-extension-matrix.json`: old-SDK module with GNU standard printf
  callbacks, matching old/new constructor and ordinary-call locale observations
  across five locales. Reproduce with `Perf/check-convfloat-printf.py`.
- `rejected-unguarded-formatter.patch` and
  `printf-extension-original-prototype.json`: the rejected prototype and exact
  callback-visible regression that required the native policy.
- `selected-correctness.json` and named comparison reports: twelve broader
  pristine-versus-candidate groups. Existing native-array raw-alias differences
  retain the prior explicit ownership classification. `stateful-inputs.tar.xz`
  holds the exact generated normal/Memcheck programs and logs.
- `memory/`: available Memcheck logs. Float tests use quiet error reporting and
  error exit codes; empty logs are expected on success. Leak checking is disabled.
- `selected-build.json`, `selected-training.json`, `selected-validation.json`,
  `selected-ohmyzsh.json`, installed-core receipt, terminal profile and all seven
  package-suite receipts/logs identify the exact inactive package, SDK and tested
  native modules. Compiler build logs retain warnings and untrained optional
  modules; suite/profile/build wall times are not benchmark samples.
- `final-protection-and-exports.json`: all old exported symbols remain, five
  helpers are added, compiled inputs still match, and protected Zsh/startup,
  active binaries, account shell, /etc/shells, old tag/archive remain unchanged.

`measure.py`, `validate-selected.py` and `finish-validation.py` freeze the local
orchestration used for this checkpoint. Paths are host-local. Binary and source
hashes, checked states and sample distributions are retained in the reports.
Exact native fixture source and current runners are in `Perf/`; older compiler
baseline details are in round 38. No universal compatibility or speedup is
established by these results.
