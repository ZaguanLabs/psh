# Round twenty-six evidence

[The report](../../round26.md) explains the selected decimal prefix/handoff,
range and state invariants, measured customer gains, slower controls and install.
The immutable reference is `402746ade22e5a9e8fc80702d4bce53455a62d06`.
Only `Src/utils.c` changes in the production C source. There is no new native
interface, public layout, allocation or cache.

- Top-level customer/library `*-benchmarks.json` and `*-repeat.json` contain the
  selected implementation's two nine-sample alternating runs. Parser/search and
  ten direct-API controls retain all samples, including slower JSON array parsing
  and HTML prose. Source/worker/binary/output hashes bind each workload.
  The selected timing executable is `.work/round26/resume/Src/zsh`.
- `bounded9/` retains the first fixed-bound restarting trial, including its source
  diff, original native fixture and timing variation. `adaptive18/` retains the
  word-size-aware restarting trial, full compatibility evidence and its inactive
  package checks. Its additional `adaptive-conversion-final.json` catches the
  87% slower 19-digit control. Its first nine-case API driver/module sources are
  saved as `conversion-initial-*` to match those historical fingerprints.
  Neither restarting version is activated.
- `resumed/` retains selected native Memcheck logs and private build provenance;
  selected top-level receipts are copies of those completed measurements.
  Raw profiles are compressed as `*.callgrind.gz`; original hashes and exclusive
  conversion counts are in `instruction-summary.json`. Whole-process profiles
  include setup/warm-up. Hardware events include inherited tasks from exec to
  exit; all are fully scheduled. These scopes differ from warm timers.
- `strtol-native.json` records 13,309,824 conversion calls in eight Memcheck
  processes (GCC, C/C.UTF-8). `clang-strtol.json`, `development-strtol.json` and
  `installed-strtol.json` each record 6,654,912 calls in four C.UTF-8 processes.
  The combined selected total is 33,274,560 calls in 20 processes, including
  original-oracle runs. Values/end offsets/errno/error flags and all diagnostic
  bytes match. Large synthetic streams are retained as hashes and byte counts;
  input integrity, completion markers and memory-error exit status are checked.
- Broad differential, arithmetic operator, upstream GCC/Clang/debug, seven
  package-suite, installed identity and 24-session unchanged-OMZ receipts bind
  the selected hosts. Framework code runs only as the normal user.
  `activation.json` records stable-install/startup/old-release protection counts.
- `source-checks.json` verifies 1,847 pristine files, 1,848 timed interpreter
  inputs, all 1,853 installed core inputs, unchanged headers/declarations and
  the exact original conversion body after removing the additions. It verifies
  the oracle against pristine release source. `patch-check.json` records
  seven-file reconstruction from the parent.

An initial generated profile script was launched before it existed; the saved
setup log and successful retry remain under the first trial. The earlier trial
has substantial timing variation with no established external cause. No slower
or rejected measurements are removed or substituted for selected paired runs.

Binaries, native fixture objects and complete personal/stable-install snapshots
remain local. `sha256.json` covers every evidence file except itself. The private
repository, original rc0 tag/draft/seven assets remain; no public release or new
source archive is created.
