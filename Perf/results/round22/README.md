# Round twenty-two evidence

Read [the report](../../round22.md) for adoption, tradeoffs and limits.
Baseline source is commit `4d82600983d23820b56be336e687b2cac2af0cea`.

- `final/` contains the accepted signal-guarded advancing-prefix cache:
  two complete nine-sample customer runs, library/parser/bound/array controls,
  hardware counters, matched instruction profiles, GCC/Clang/native checks,
  the exact installed OMZ certificate, package suites and activation protections.
- `full-length/` preserves the initial `issetvar()` sketch, first full-count
  prototype and its results. The frozen binary record is its comment-only
  rebuild used for the cold control in `bounds/full-length-cold.json`; initial
  benchmark files retain their own earlier binary hash.
- `bounds/` preserves the intermediate cache that answers confirmed bounds but
  restarts larger scans from the beginning. It includes all repeated timing and
  slower controls, plus the added cold full-count comparison.
- `progressive-unqueued/` preserves the advancing-prefix prototype before the
  signal guard. It passed broad functional checks but was rejected because it
  published cache metadata while signals were unqueued. Its debugger negative
  control expects those writes. A `passed: true` negative-control report means
  that the expected bad behavior was reproduced, not that this build is safe
  or accepted.

Reports bind measured/tested binaries, workers, native fixtures and project
sources to hashes. Every wall-time sample and slower control is retained;
profiled elapsed times are not latency results. Raw Callgrind profiles are
compressed beside flat reports. Native `*-native/` directories contain
Memcheck logs, with leak checks disabled. Binaries and module objects remain
local, as do complete stable-install/startup protection snapshots.

`final/installed-package.json` identifies the active private rc0 build and
native module hashes. `final/activation.json` contains protection counts,
without private snapshot contents. The code/ownership patch reconstructs twelve
files from the parent commit, checked by `final/patch-check.json`.

The final transient-scope fixture explicitly warms via a queued expansion;
bare `[[ -v ]]` intentionally does not populate the accepted cache. GCC, Clang
and installed native checks were rerun after that fixture improvement, after
all timings finished. Core source, benchmark workers and installed bytes did
not change. Earlier successful native reports remain local under
`.work/logs/round22/final/pre-transient-warm/`.

No rc0 tag, draft release or public artifact is replaced by these results.
