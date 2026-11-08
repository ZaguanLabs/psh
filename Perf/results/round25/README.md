# Round twenty-five evidence

[The report](../../round25.md) explains the classification branch merge, measured
customer gains, mixed library controls, native coverage and installed build.
The immutable reference is `5cdb994b00ed4c49bc57a115ca29b71d1193fb2d`.
The only production C change merges identical branches in `Src/utils.c`.

- `customer-benchmarks.json` / `customer-repeat.json` and
  `library-benchmarks.json` / `library-repeat.json` retain all nine alternating
  samples per run, including slower first JSON parsing/validation/navigation
  results. Parser and search controls also retain every sample.
  `timing-commands.json` and `timing-separation.json` record scheduling and
  separation from this work's builds/tests/profilers; external activity was
  not exhaustively audited. Warm timers exclude setup and warm-up.
- Fresh actual daily-driver profiles and matched comparison profiles are
  compressed as `*.callgrind.gz`. `instruction-summary.json` retains exclusive
  classifier counts and raw hashes; flat reports and disassembly remain beside
  them. Matched source/state hashes agree. Whole-process profiles include setup.
  `hardware.json` and `hardware-scheduling.json` retain all fully scheduled
  counter samples, including coder paste's slightly higher cycle median.
- `itype-native.json` records five-encoding GCC release checks;
  `clang-itype.json`, `development-itype.json` and `installed-itype.json`
  record C/C.UTF-8 pairs. Together they cover 28,588,032 native checks across
  22 Memcheck processes. Each call compares the original release function,
  returned boundary, subsequent converter state and unchanged buffer bytes.
- The first native attempt used the default pristine debug SDK with a release
  host. `itype-native-debug-sdk-setup.log` and
  `validation-debug-sdk-setup.json` retain that load failure. Explicit SDK
  arguments fix the setup. `validation.json` retains the successful retry
  and all other successful groups; its original combined log still records the
  first failure. No classifier check ran in that failed attempt.
- Upstream GCC/Clang/debug logs, broad differential receipts, the seven package
  suites, `package-validation.json`, `ohmyzsh.json`, installed identity and
  `activation.json` bind the tested executables. Framework tests run as the
  normal user. The previous installed psh and stable Zsh/startup entries are
  protected by local inventories; activation retains their counts.
- `source-checks.json` verifies 1,847 pristine files, all 1,853 installed core
  inputs, unchanged public headers, fixture syntax and the development profile.
  `patch-check.json` records four-file reconstruction from the parent commit.

Binaries, native fixture objects and complete personal/stable-install snapshots
remain local. `sha256.json` covers every evidence file except itself. The
original rc0 tag, private repository, draft and seven assets are retained;
this iteration creates no source archive or public release.
