# Round 43: upstream lifetime repairs and allocator-aware checks

This round strengthens history loading and failed `source` commands with two
existing upstream fixes by Mikael Magnusson. It also screens temporary parser
memory as a future optimization target. No new interpreter optimization is
claimed; the count remains 27. No shell is activated or release published.

The parent is `689cf47aa88014728ef3d0adefb0df8605ecf6cc`.
The preceding accepted release is `1.0.0-rc1-6db51a2527d4`, SHA-256
`d10393954414ba849e7f4759acc0a2e006eb1c9961780d86e3a212d44c2b5102`.
The candidate is `1.0.0-rc1-5982ba7e218f`, SHA-256
`f0347fdcc66a0006b5291cb34e4e222d555bf219d54c36e13fd3542b586aaaef`.
Both are GCC 15.2 release-profile PGO+LTO packages. The active rc0 daily driver
remains unchanged.

## Two existing upstream defects

- [Workers 55250](https://zsh.org/workers/55250), upstream commit
  `a8536c612a7fbb8241be60b817ffdfbb98810709`, moves the failed PATH-search
  diagnostic before its filename's heap is released. An unreadable sourced
  file produces a damaged pathname on both pristine Zsh and the preceding psh
  release. The repaired candidate reports the actual filename. Absolute paths,
  successful sourcing, missing files, positional restoration, PATH_DIRS and
  zsh/sh/ksh emulations have separate controls.
- [Workers 55251](https://zsh.org/workers/55251), upstream commit
  `b13bbf2acadb79268311f3dd0683f93992ce69ba`, keeps the final history entry's
  storage alive until the reader finishes using it. Arena-aware Memcheck
  diagnoses invalid history accesses on pristine Zsh; the preceding psh release
  also crashes on a long partial-Meta input with HIST_LEX_WORDS enabled.
  The candidate matches repaired upstream behavior. The tests include ordinary
  and malformed history, EOF, continuation, extended timestamps, UTF-8 and both
  HIST_LEX_WORDS settings.

These are upstream backports, not newly discovered bugs or security claims.
The changes preserve exported interfaces and native layouts. The adopted diffs
match upstream, with offsets for psh's existing changes.

## Making memory tests observe Zsh's arenas

Ordinary Memcheck does not understand every allocation within Zsh's private
heap arenas. The failed-source probe initially produced a visibly corrupt
diagnostic without a Memcheck error. Two isolated builds configured with
`--enable-zsh-valgrind` let Memcheck observe more of those internal lifetimes:
one pristine 5.9.2 negative control and one candidate-source diagnostic build.
Both use `-O2 -g`; neither is used for performance timing or installation.

`check-heap-lifetimes.py` compares complete output, diagnostics and exit status
for the installed candidate and its instrumented counterpart against unmodified
upstream `b13bbf2`. It also retains the preceding release and instrumented
pristine failures. Two locales and 62 fixtures give 124 cases across five hosts.
Expected baseline differences are confined to the explicitly labeled defect
cases; candidate differences fail. History inputs must remain byte-identical.

The first harness shared a history file between concurrent locale workers,
causing a lock error in one oracle run. That failed report is retained. Each
locale now has a separate file; locks left by crashing negative controls are
recorded and removed before the next host runs. A subsequent review also fixed
the listing condition to include single-entry histories. The earlier report is
retained separately rather than presented as the final check.

This is focused lifetime coverage, not comprehensive memory-safety proof.
Zsh's last-arena reuse branch does not issue the same Valgrind trim annotation
as all other branches, so a clean result alone cannot establish safety.

## Temporary glob programs: a lead, not an adopted optimization

Upstream commit `588b37fd70bb9bd42f9abbce4651e1e2dd1d43bd`
([workers 55203](https://zsh.org/mla/workers/2026/msg01050.html)) frees the
temporary program after each shell-code glob qualifier. A screening fixture
compares 100, 1,000 and 10,000 files with short and 1,024-byte qualifier literals.
Every complete filename list matches.

At 10,000 files with the longer literal, maximum resident size is 60,160 KiB
for the preceding psh release and 47,776 KiB for current upstream. These are
different compiler settings and source histories, one observation per case:
they identify a possible memory target, not an isolated saving attributable to
the patch. The first probe's invalid qualifier delimiter is retained as a
failed experiment; the corrected delimiter follows the upstream test syntax.
No elapsed-time claim is made from this screening.

The upstream patch changes exported `parse_list(void)` to `parse_list(int)`.
It is therefore **not applied**. A future isolated trial must retain the old
signature, test ownership across nested qualifiers/functions/traps and native
callers, and compare matched release builds. The current two repairs require
no such interface change.

## Local scope

The existing edits in `Packaging/README.md`, `Packaging/build.py`,
`Packaging/check-ohmyzsh.py`, `Perf/ohmyzsh-session.zsh` and the previously sent
hash-getter bug-report files predate this round. They are excluded from this
round's commit. Package provenance includes the existing build/gate edits.
Historical artifacts, the sent report archive and published rc0 are preserved.

## Verification of the installed candidate

- All 124 final lifetime cases pass against repaired upstream, including
  complete single-entry history contents. Instrumented pristine reports
  Memcheck failures in 36 source and 20 history cases; two additional long
  history cases terminate with SIGSEGV. Both long cases also crash the preceding
  ordinary psh release. The candidate and instrumented candidate have no
  observed errors or leftover locks in this matrix.
- 63 upstream test scripts succeed, with zero failures and two skips. All seven
  core/bundled suites pass, including 190 native zdraw tests.
- `Packaging/verify.py verify` passes 24 genuine interactive OMZ sessions and
  14 native-library observations, plus installed-component loading/rendering,
  module isolation and original startup-filename checks. Its snapshots confirm
  11,829 stable-installation entries and the account login shell are unchanged.
- The final installed executable remains 883,312 bytes, the same size as the
  preceding release. Exported parser/native interfaces are unchanged.

The [evidence index](results/round43/README.md) distinguishes final checks from
the failed harness and initial diagnostic probes. Verification does not imply
that every malformed history format or asynchronous path has been exercised.

## Performance controls

After builds, tests and profilers finished, thirteen customer kernels and five
JSON operations ran with nine alternating samples per shell, CPU 13 and
C.UTF-8. A separate zdraw build/test run was also allowed to finish before
timing. Complete resulting states match in all eighteen workloads.

Customer median elapsed times range from about 0.2% to 2.1% lower; JSON medians
are about 0.2% to 1.2% lower. These small shifts do not establish an application
speedup from the repairs. No performance regression is demonstrated by these
controls, and no new algorithmic optimization is claimed. All samples and cases
are retained in [the timing table](results/round43/timings.md) and raw reports.
