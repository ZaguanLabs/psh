# Round 43 evidence

See [the round report](../../round43.md) for scope, attribution and limits.
Gzip files are ordinary JSON/text compressed with a zero timestamp.

- `heap-lifetimes.json.gz`: final 124-case, five-host comparison; full raw
  stdout/stderr bytes are hex encoded. The installed and instrumented candidate
  must match repaired upstream exactly. Baseline failures remain in the report.
- `heap-lifetimes-shared-lock-failed.json.gz`: rejected first harness run, with
  an oracle lock error caused by shared concurrent-locale history fixtures.
- `heap-lifetimes-before-single-entry-check.json.gz`: intermediate passing run
  before extending history output checks to single-entry files.
- `diagnostic-builds.json`, `*-heap-config.h`, `*-heap-build.log.gz`: compiler,
  Valgrind, source and binary identities for isolated instrumented builds.
  Candidate diagnostics use pristine configure/build infrastructure with the
  candidate's tracked `Src` files; they are not release-performance binaries.
- `probe-*.py`, `*-probes.json*`: earlier small reproducers, including cases
  where ordinary arena-unaware Memcheck did not report the lifetime error.
- `history-upstream.patch`, `source-upstream.patch`: adopted upstream changes.
- `glob-upstream-unapplied.patch`: upstream glob-memory proposal, **not applied**
  because it changes exported `parse_list`'s signature.
- `glob-memory-probe.py`, `glob-memory-probe.json`: corrected synthetic peak-RSS
  screening, with full filename-output hashes. Different builds, single samples,
  no elapsed timing or isolated patch-benefit claim.
- `glob-memory-probe-invalid-syntax.log`: initial rejected qualifier syntax.
- `5982ba7e218f-*`, `package-*.log*`, `test-*.log.gz`, `verify.log`: exact-package
  provenance, upstream/bundled suites, OMZ/native gates and successful validation.
  Stable-system snapshot contents and the unrelated pre-existing local diff are
  not copied into this evidence directory.
- `customer.json`, `objects.json`, `measurement-session.json`, `measure.py`
  and [timings.md](timings.md): final nine-sample release comparisons, including
  full output-state checks, source/binary hashes and all controls.

The upstream oracle is unmodified commit
`b13bbf2acadb79268311f3dd0683f93992ce69ba`; negative controls use pristine
5.9.2 and preceding psh release `1.0.0-rc1-6db51a2527d4`.
