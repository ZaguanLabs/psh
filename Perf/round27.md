# Round 27: prefilter option entries during emulation

This accepts optimization 25, relative to parent
`45d9520b21e92068cb4e9620cf748875874bd75a`, while retaining
`psh 1.0.0-rc0 (zsh 5.9.2)`. Repeated customer measurements show 4.6–4.9%
less time in chat paste and 3.0–4.6% less time in JSON array parsing.
The repeated wide coder layout was 2.2% slower. This is a focused option-table
change, with no new intended compatibility difference. Existing differences
remain in [COMPATIBILITY.md](../COMPATIBILITY.md).

## Change and compatibility reasoning

`installemulation()` now passes existing selection masks to `scanhashtable()`:
require `OPT_EMULATE` for partial emulation and reject `OPT_ALIAS` in both modes.
Full emulation still needs the callback's `!OPT_SPECIAL || OPT_EMULATE` condition.
The setter `setemulate()` is byte-identical to release Zsh 5.9.2; its checks stay
in place because generated table scanners can ignore masks and visit every
entry. Both ordinary and generated tables retain the original predicate.

The generic hash scanner is unchanged. Bucket order, preloaded next pointers,
mutation tracking, live entry flags and nested-scan handling remain its existing
responsibility. No cached list, unchecked setter, signal-queue guard, new
allocation, public declaration or structure-layout change is introduced.
This round makes no new supported native-module interface; the test module
calls an already-exported internal entry point solely for regression testing.

The source check reconstructs the five-file incremental patch, verifies all
1,847 pristine files and 1,853 package inputs, compares the original setter and
normalized fixture oracle with pristine source, and verifies unchanged public
headers and generated option declarations. See
[source checks](results/round27/source-checks.json) and
[patch](0027-option-emulation-prefilter.patch).

## Profiles and rejected experiment

Profiles of the actual previous daily-driver release located repeated emulation
work in the customer's JSON and chat paths. Matched parent/candidate release
profiles used identical customer source and resulting-state fingerprints:

| Profile | Parent instructions | Candidate instructions | Reduction |
| --- | ---: | ---: | ---: |
| JSON encode | 2,865,291,600 | 2,812,486,404 | 1.84% |
| Chat paste | 2,396,641,920 | 2,363,618,604 | 1.38% |

JSON setter calls fell from 6,304,985 to 2,592,613; chat calls from 3,943,152 to
1,621,504, approximately 58.9% fewer calls. Setter self-instructions fell from
61,866,303 to 33,703,567 and 38,691,566 to 21,079,150 respectively. These are
instrumented instruction counts, separate from wall-time measurements.

The first prototype selected a separate unchecked callback only while signals
were queued and no generated scanner existed. Native checks passed, but matched
customer profiles never called that callback. GDB observed queue level zero at
the real emulation entries, so the guard missed the workload and total profile
instructions increased slightly. It was rejected before wall timing. Its source
diff, profile output and native receipts remain in
[queued-only](results/round27/queued-only/). The selected implementation retains
the original callback and needs no queue-level assumption.

## Wall-time measurements

GCC release builds use dynamic modules, multibyte and PCRE support, DEBUG off,
`-O2 -g` and explicit `LDFLAGS=-g`. Both builds use the same settings and private
runtime directories. Nine alternating fresh-process samples per pair run on
CPU 2 in `C.UTF-8`. Own builds, tests and profilers were finished before timing;
there was no continuous audit of unrelated system activity. Setup and warmup
are outside the warm operation timers. Output/state fingerprints matched.
Tables show medians in milliseconds; a positive change means more time.
Small differences and mixed controls do not establish a universal benefit.

### Customer kernels

| Case | Parent | Candidate | Change | Repeat parent | Repeat candidate | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 114.195 | 114.134 | -0.1% | 114.085 | 111.927 | -1.9% |
| zcoder.zsh/coder-layout | 5.475 | 5.404 | -1.3% | 5.480 | 5.450 | -0.5% |
| zcoder.zsh/coder-wide-layout | 62.545 | 62.658 | +0.2% | 64.294 | 65.738 | +2.2% |
| zchat.zsh/chat-paste | 211.968 | 202.207 | -4.6% | 215.356 | 204.859 | -4.9% |
| zchat.zsh/chat-layout | 5.430 | 5.440 | +0.2% | 5.446 | 5.436 | -0.2% |
| zchat.zsh/chat-wide-layout | 62.117 | 62.307 | +0.3% | 63.560 | 63.163 | -0.6% |
| endgame/endgame-world | 41.828 | 41.929 | +0.2% | 42.698 | 42.512 | -0.4% |
| z3dfx.mario/mario-race | 19.509 | 19.151 | -1.8% | 20.012 | 19.694 | -1.6% |
| z3dfx/shooter-step | 11.384 | 11.245 | -1.2% | 11.406 | 11.265 | -1.2% |
| z3dfx.agy/shooter-step | 11.360 | 11.341 | -0.2% | 11.342 | 11.366 | +0.2% |
| z3dfx.grok/shooter-step | 11.409 | 11.248 | -1.4% | 11.441 | 11.240 | -1.8% |
| zfetch/fetch-encode | 12.915 | 12.869 | -0.4% | 12.819 | 12.887 | +0.5% |
| z3dfx.drawing/drawing-binning | 12.426 | 12.306 | -1.0% | 12.344 | 12.368 | +0.2% |

### Library operations

| Case | Parent | Candidate | Change | Repeat parent | Repeat candidate | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zjson-array | 93.807 | 89.503 | -4.6% | 91.992 | 89.228 | -3.0% |
| zjson-encode-array | 208.000 | 203.738 | -2.0% | 209.544 | 201.454 | -3.9% |
| zjson | 91.104 | 86.217 | -5.4% | 91.487 | 87.506 | -4.4% |
| navigation | 1.820 | 1.814 | -0.3% | 1.871 | 1.858 | -0.7% |

### Parser controls

| Case | Parent | Candidate | Change |
| --- | ---: | ---: | ---: |
| html-comment-1m | 124.763 | 125.255 | +0.4% |
| html-prose-100k | 126.482 | 123.531 | -2.3% |
| json-repair-100k | 18.689 | 18.600 | -0.5% |
| html-clean-128 | 98.174 | 95.507 | -2.7% |

### Search controls

| Case | Parent | Candidate | Change |
| --- | ---: | ---: | ---: |
| tiny-first | 15.956 | 16.349 | +2.5% |
| first | 1.596 | 1.636 | +2.5% |
| middle | 12.401 | 12.391 | -0.1% |
| last | 24.493 | 24.814 | +1.3% |
| missing | 24.489 | 24.682 | +0.8% |
| start-middle | 0.833 | 0.835 | +0.2% |
| start-last | 0.830 | 0.840 | +1.2% |
| start-beyond | 0.793 | 0.799 | +0.8% |
| negative-start | 17.752 | 17.919 | +0.9% |
| backward | 17.798 | 17.862 | +0.4% |

Search controls include a 2.5% slower tiny-first median and 2.5% slower
first-position median. The HTML-comment median is 0.4% slower. Coder paste is
essentially flat in the first group and faster in the repeat. These results are
retained alongside the stronger chat and JSON gains; they are not hidden or
recast as universal startup or full-UI improvements.

### Hardware controls

These counters cover user-space exec through exit, including setup and inherited
tasks, so their scope differs from the warm timers. All events were fully
scheduled. Raw events, source hashes and nine alternating samples remain in
[hardware.json](results/round27/hardware.json).

| Case | Parent cycles | Candidate cycles | Parent instructions | Candidate instructions |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 720,590,637 | 711,076,657 | 1,387,634,748 | 1,387,634,677 |
| endgame/endgame-world | 404,399,142 | 402,179,972 | 1,144,171,422 | 1,144,138,194 |
| z3dfx.mario/mario-race | 186,112,287 | 184,908,206 | 431,511,266 | 430,231,492 |
| z3dfx.drawing/drawing-binning | 167,079,887 | 166,685,903 | 422,759,804 | 422,759,559 |

## Validation

- GCC release candidate: 63 upstream scripts passed, zero failures, two skips.
  Clang 20.1.8 parent and candidate: each 63 passed, zero failures, two skips.
  The refreshed DEBUG developer build: 62 passed, zero failures, three skips
  (its default configuration lacks PCRE).
- Native emulation oracle: 56,722 scenarios per host/locale, 567,220 scenario
  executions across ten Memcheck processes: GCC release in C and UTF-8,
  Clang release in UTF-8, pristine/developer DEBUG in UTF-8 and exact installed
  previous/new releases in UTF-8. Each scenario compares original-predicate and
  candidate installations. Both queued and unqueued cases run; zero Memcheck
  errors, with leak checks disabled. This is a repeated matrix, not 567,220
  distinct inputs.
- The native matrix covers canonical and synthetic tables, collisions, empty
  tables, aliases with negative indices, duplicates, disabled and special flags,
  generated reverse scanners, output sentinels, and modes including integer
  extremes. Output buffers aliasing later option-node flag storage exercise
  live eligibility changes; generated scanner callback counts/order/arguments
  match the oracle. Global options and original table are restored afterward.
- Frontend differential: 512 cases across C and UTF-8, four starting and target
  emulations, option profiles, local/full/sticky/autoload/nested/trace contexts,
  complete option listings, output/status and scope restoration.
- Eleven broader validation groups passed: arrays 5,192; search 193,236;
  patterns 159,600 and scalar cases 704,585 across five encodings; substitution
  2,640; arithmetic syntax 110,100; native floating-point 200,832 scenarios
  under Memcheck; accessor 20; PTY completion 36; and customer correctness.
  Customer evidence includes 24 kernel/locale checks and five original project
  suites. Detailed per-group counts and commands remain in the JSON receipts.
- Seven installed package suites passed, including all 190 zdraw tests and
  rebuilt zdraw, zmdown and zcurl native modules. Normal-user package verification
  passed before activation, including 24 real interactive Oh My Zsh sessions
  with re5et, git, syntax highlighting, completion, history, prompts and async
  behavior. This is evidence for the exercised configurations, not proof for
  every possible OMZ installation.

The first DEBUG native run diagnosed a fixture error: forcing queue level zero
with `restore_queue_signals(0)` violated its DEBUG queue protocol. The pristine
baseline emitted the same diagnostic. The driver rejected its nonempty stderr;
that run was not counted as a pass. The corrected fixture drains with
`dont_queue_signals()` under the real table before restoring the requested
level. Every final native group was rerun successfully. Initial fixture source,
receipts and logs remain in `fixture-queue-setup/`. Production code did not
change in response. An initial Clang setup script referenced an archived helper
at its old work path; the missing-helper log is also retained. No compiler result
was inferred from that failed setup.

## Installed checkpoint and limits

Active release: `/usr/local/psh/releases/1.0.0-rc0-e84bb6129d9e`.
Installed ELF SHA-256:
`e9bad634912ddc66e8625ecad40c9c7cb706654e31a3c06bc456489c4c51e84c`.
The stripped executable remains 846,488 bytes and has the same 1,056 dynamic
export names/types as the preceding release. DEBUG remains off in the installed
release; the separate developer build retains DEBUG.

Post-activation checks confirm all 1,603 entries of previous release
`1.0.0-rc0-1ca5fc1448c0` remain unchanged for rollback, along with 11,828 protected
stable-Zsh/startup entries. `/etc/shells` and the account login shell are unchanged.
No personal startup files or framework sources were edited. The package is
activated only through the isolated installer and its matching OMZ certificate.

The repository remains private. The original rc0 tag, draft and seven historical
assets remain untouched; this iteration is identified by its commit, build digest
and binary hash. No new archive is presented as the original tagged release.

This is a focused audit of emulation and its scanner, not completion of the
whole Zsh audit. The structural index reported partial coverage, so exact source
reads and original-source comparisons underpin this change. Other operating
systems and a new non-multibyte build were not certified in this round. Existing
native-array contract differences remain documented separately.

Reproduction commands and compiler/profile drivers are retained under
[results/round27](results/round27/README.md). Large raw Callgrind profiles are
compressed without dropping samples. The evidence manifest hashes all archived
files except itself. Local-only protected startup and previous-release snapshots
are deliberately excluded from the repository evidence.
