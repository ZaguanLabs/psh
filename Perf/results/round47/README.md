# Round 47 evidence

See [the investigation](../../round47.md) for interpretation and limits.

- `import.json.gz` pins the verified zdraw tag and all 450 upstream files;
  `sources-before.json.gz` preserves the preceding complete vendor manifest.
- `1d2a092078fb-*.json*`, package test logs and `verify.log.gz` describe the
  final inactive release. Existing local packaging/OMZ edits were used by the
  workflow but are not part of this update's commit.
- `first-package/` retains the superseded zdraw-only package, its passing gates
  and the failed supplemental stock-curses comparison. It is not the accepted
  corrected candidate.
- `querychar/` contains the pristine/previous/candidate results, minimal PTY
  reproducer, and diagnostic source/compiler command/Memcheck log. The
  diagnostic moves the original one-wchar capacity to an exact heap allocation;
  it is not an unchanged-stock Valgrind observation. `previous-matrix.json`
  intentionally reports failure. Corrected and zdraw matrices pass.
- `curses-differential/` retains the original seeded corpus and matching raw
  cell/status/terminal captures after the fix.
- `lifecycle-*.json` and `*-memcheck.log.gz` cover normal and forced-guard paths.
  Forced rejection is not testing an actual older ncurses installation.
- `components*.json.gz` are two separate alternating nine-sample comparisons.
  All rendered-state/resource comparisons pass. Profiling was completed before
  timing, and profiles are stored separately. `timing-summary.json` retains
  every case, including slower controls.

Large JSON and terminal/log/text artifacts are gzip-compressed with zero mtime.
`SHA256SUMS` hashes the stored bytes. No package is activated or published.
