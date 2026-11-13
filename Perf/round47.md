# Round 47: integrate zdraw 0.1.4

This bundles a dependency update and a stock curses safety fix, not another
core-shell optimization. The
parent is `49d8519`; the accepted core optimization count remains 30.

## Pin and import

The public annotated `v0.1.4` tag resolves to commit
`3ab773ca8ecd24c541ca9fc2fdbe739abff5a3f8`; the tag object is
`d549e76c75451175142dca251b5898c2dd58dd97`. `git ls-remote` against the recorded
origin confirms both objects. Import uses `git archive` of that commit, not
uncommitted files in the customer's checkout. All 450 tracked files are retained,
including licences, documentation, regression tests and upstream measurements.
The prior pin was `a6fba85b72b31d1a465d60402f7e329d2991e650` (0.1.3).

The only difference from the tagged sources is the existing conditional
`psh_scope_module_ack(m)` call during native setup. The new C change handles
screen ownership and does not introduce parameter-level promotions, so the
previous cooperation acknowledgment still applies. Its new unpatched/patched
hashes are recorded in `Vendor/sources.json`; the other five vendor entries are
unchanged. Historical float-locale acknowledgment/withdrawal records remain in
Git and the archived prior manifest; neither patch is reintroduced.

The integration patch now includes the curses screen-safety configure probe.
A new isolated package build applies it from clean sources. The normal package
test workflow cleans the old zdraw build cache when the source-root marker changes.
The customer's zdraw checkout and build cache are not modified.

## Native safety behavior

Some ncurses implementations free another screen's windows when deleting one
screen. The new configure probe actually creates/deletes screens using temporary
streams; it does not infer safety from a version number. This host reports
`HAVE_ZDRAW_SAFE_DELSCREEN=1`, preserving coexistence.

On a library which fails the probe, `zdraw init` refuses when another screen is
retained, before allocating its own SCREEN. It returns failure with an explicit
diagnostic and preserves the other owner's state. The documented fallback is a
separate process or a library with the fix/backport. The module's guard does not
change core Zsh syntax or the stock `zsh/curses` implementation. See the imported
[changelog](../Vendor/zdraw/CHANGELOG.md) and [build guide](../Vendor/zdraw/docs/building.md).

The imported suite exercises the real host probe result and builds a module
variant with the safe-screen macro undefined to exercise rejection deliberately.
That verifies the guard on this host; it is not a runtime test against an older
ncurses installation. No system library is replaced or reconfigured.

## Builds and validation method

The preceding installed package is `1.0.0-rc1-126770ba80d2`, shell SHA-256
`41feca1e89521329ca50993bc0a1e801f38fe74364fd02327a77fae16cb05571`.
The final candidate is `1.0.0-rc1-1d2a092078fb`, shell SHA-256
`e01e768aad1ebe37eba242136dbeb36aebf8e8da4ca23a0985322f2a40db130b`.
Both use the release PGO+LTO profile and have 887,408-byte stripped executables;
all 1,070 dynamic core symbol names are retained. The only core C change is the
stock curses readback correction described below.

All native modules are rebuilt/tested with the matching psh codebase. Full
package verification includes the required unchanged-OMZ terminal gate,
native-library compatibility, protected stable installation/account checks and
installed component rendering, including zcoder's change-gutter dependency.
Additional checks use private bridges to the actual installed binary, SDK,
modules and libraries, not the upstream development executable.

The style differential covers 2,000 cases in each of C and C.UTF-8. A stock-curses
comparison covers 600 seeded inherited operations. Lifecycle checks run 100
standalone cycles, 100 coexistence cycles and 100 forced-guard cycles under full Memcheck, requiring no
memory errors or definite/indirect leaks and checking terminal restoration.
Other leak classifications are retained without claiming a universally leak-free
process. Function profiles and timing are separate operations.

The final package passes all seven suites: 63 successful upstream scripts, zero
failures and two skips; 193 zdraw tests; and all zjson, zcurl, zmdown, zhtml2md and
zoup checks. `Packaging/verify.py verify` passes 24 unchanged OMZ sessions and 14
native-library observations. It verifies 11,829 protected entries unchanged and
passes installed change-gutter rendering.

The additional 4,000 style cases match the preceding bundle. All 600 seeded
stock/zdraw operation statuses, cell snapshots and terminal bytes match after
the stock fix. Both corrected backends pass all 64 readback cases under Memcheck.
All three 100-cycle lifecycle runs restore the terminal and report zero Memcheck
errors and zero definite/indirect leaks. The normal coexistence run retains
712 possibly-lost bytes and the forced-guard run 201; those classifications and
reachable allocations remain in the logs. This is not a universal leak-free claim.

The separate installed-release profiles show `_zdraw_ui_property` calls dropping
from 1,001 to zero for the large changing form and from 504 to zero for the large
changing document. Validation now occurs inside the style resolver. Profiled
elapsed times are not used as performance measurements.

## Inherited stock curses buffer bug

The first zdraw-only package, `1.0.0-rc1-ec96430ae35f`, passed all seven package
suites and the OMZ/native gates. The additional seeded stock/zdraw oracle then
failed on attributes, despite identical terminal bytes. The preceding psh
package reproduced the same missing `underline` attribute. These failed results
and the superseded package identity remain archived under `first-package/`.

The stock `querychar` helper supplies one `wchar_t` to `getcchar`, which writes a
terminated string. A diagnostic relocation of that exact one-character capacity
into a heap allocation exposes the overflow under pristine Zsh and Memcheck.
The ordinary pristine build happens to produce correct visible output; stack
layout determines the symptom. See the [bug note](bugs/curses-querychar.md) for
the minimal reproducer and the distinction between the diagnostic and unchanged
stock execution. ASan could not link on this host and provides no evidence here.

The final package queries the full cell capacity and allocates it in the shell
arena. Its public result remains the first character, with colors and attributes.
The regression covers 16 C-locale and 48 UTF-8 cases per backend, including spaces,
wide characters and combining sequences. The preceding psh stock backend fails
12/16 and 36/48 respectively; its zdraw backend passes. Pristine stock passes the
visible matrix. No check is removed to make the original 600-operation oracle
pass, and no ABI or deliberate language difference is introduced.

## Timing scope

The new `Perf/zdraw-components-benchmark.py` reuses upstream's real-PTY driver
and common fixture while selecting each release's installed psh, native module
and companion libraries. Each case compares complete cell snapshot hashes,
terminal byte streams and resource records. Source, bytecode-cache, binary and
native module fingerprints are checked before/after; mtimes are included for
cache eligibility. The source fixture and driver hashes are retained too.

Two nine-sample comparisons alternate the packages on CPU 13. Each process uses
30 measured frames after the fixture's two warmup frames, C.UTF-8,
`xterm-256color`, and a 24×80 PTY. All 28 workload/size/change combinations remain,
including canvas, surfaces, spans and prepared draws as controls. Component work,
staging and presentation are recorded separately. These are widget workloads,
not whole zcoder launches or emulator paint latency measurements.

## Results

Both nine-sample runs match complete rendered snapshots, terminal streams and
resource records in all 28 cases. Component work takes 9.9–15.9% less time for
charts, 12.0–14.0% less for forms and 9.8–13.7% less for documents. Canvas takes
0.0–1.1% less time. The small native controls are mixed: changing-small prepared
draws go from 6.1% faster in the first run to 3.1% slower in the repeat, an absolute
change of roughly one microsecond per measured frame in the latter. Changing-small
spans are 1.9% slower in the repeat. These controls do not establish a general
native rendering improvement.

Median component work milliseconds per frame; positive percentages mean time
saved. Raw nine-sample timings, stage/present measurements, identities and states
are archived in `results/round47/components*.json.gz`.

| Case | Run 1: old → new (time saved) | Run 2: old → new (time saved) |
| --- | --- | --- |
| chart repeated small | 2.4064 → 2.0230 (+15.9%) | 2.4128 → 2.0360 (+15.6%) |
| chart repeated large | 2.9439 → 2.5433 (+13.6%) | 2.9336 → 2.5562 (+12.9%) |
| chart changing small | 2.9421 → 2.5458 (+13.5%) | 2.9538 → 2.5449 (+13.8%) |
| chart changing large | 3.9066 → 3.5086 (+10.2%) | 3.9151 → 3.5294 (+9.9%) |
| canvas repeated small | 1.8239 → 1.8037 (+1.1%) | 1.8315 → 1.8126 (+1.0%) |
| canvas repeated large | 6.0340 → 6.0006 (+0.6%) | 6.0273 → 5.9951 (+0.5%) |
| canvas changing small | 7.3568 → 7.3071 (+0.7%) | 7.3603 → 7.3316 (+0.4%) |
| canvas changing large | 21.4314 → 21.3534 (+0.4%) | 21.4012 → 21.3954 (+0.0%) |
| form repeated small | 4.7403 → 4.0999 (+13.5%) | 4.7572 → 4.0922 (+14.0%) |
| form repeated large | 9.3352 → 8.1626 (+12.6%) | 9.3244 → 8.1473 (+12.6%) |
| form changing small | 5.4367 → 4.7387 (+12.8%) | 5.4261 → 4.7403 (+12.6%) |
| form changing large | 10.1548 → 8.9197 (+12.2%) | 10.1289 → 8.9093 (+12.0%) |
| document repeated small | 4.3311 → 3.7363 (+13.7%) | 4.2725 → 3.7080 (+13.2%) |
| document repeated large | 5.9691 → 5.3717 (+10.0%) | 5.9490 → 5.3556 (+10.0%) |
| document changing small | 4.4308 → 3.8232 (+13.7%) | 4.4329 → 3.8381 (+13.4%) |
| document changing large | 5.9292 → 5.3475 (+9.8%) | 5.9441 → 5.3542 (+9.9%) |
| surfaces repeated small | 0.0292 → 0.0291 (+0.3%) | 0.0295 → 0.0292 (+1.0%) |
| surfaces repeated large | 0.0446 → 0.0446 (+0.1%) | 0.0459 → 0.0443 (+3.5%) |
| surfaces changing small | 0.0354 → 0.0354 (+0.1%) | 0.0356 → 0.0352 (+1.1%) |
| surfaces changing large | 0.0505 → 0.0500 (+0.9%) | 0.0505 → 0.0503 (+0.3%) |
| spans repeated small | 0.0411 → 0.0408 (+0.8%) | 0.0414 → 0.0412 (+0.6%) |
| spans repeated large | 0.0824 → 0.0818 (+0.7%) | 0.0811 → 0.0817 (-0.7%) |
| spans changing small | 0.0475 → 0.0472 (+0.6%) | 0.0459 → 0.0468 (-1.9%) |
| spans changing large | 0.0873 → 0.0869 (+0.4%) | 0.0874 → 0.0865 (+1.0%) |
| prepared repeated small | 0.0316 → 0.0313 (+1.0%) | 0.0317 → 0.0305 (+3.8%) |
| prepared repeated large | 0.0532 → 0.0523 (+1.6%) | 0.0537 → 0.0524 (+2.4%) |
| prepared changing small | 0.0349 → 0.0328 (+6.1%) | 0.0347 → 0.0358 (-3.1%) |
| prepared changing large | 0.0574 → 0.0574 (+0.0%) | 0.0570 → 0.0570 (-0.1%) |

The matching profiles explain the widget gains through eliminated helper-call
costs. No full-app launch or scene-construction speedup is claimed here.

No release is published or activated. The active rc0, stable Zsh, personal startup
files and account login shell remain untouched. Pre-existing packaging/OMZ edits
and the sent hash-getter report remain outside this update's commit; package
provenance includes the existing packaging/gate edits.
