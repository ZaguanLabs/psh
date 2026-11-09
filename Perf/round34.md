# Round 34: live-level scope scanning, not adopted

**The scope scanner is not adopted.** The private pilot improves coder/chat
paste by about 4%, but two complete installed-build groups do not reproduce
that gain. JSON array and validation kernels take about 2–4% more time.
Some layout controls improve by around 1%; that mixed result does not establish
an adequate improvement for the first customer's workloads.

The active daily driver remains `1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted
optimizations. Production source and the developer executable are restored
byte-for-byte to parent `8432071d9d6bc633ad19a2f695b4df6917085416`. No candidate
is activated, no compatibility departure is introduced, and rc0 is retained.

## Bounded implementation

[Round 32](round32.md) established that scope exit walks every parameter-table
bucket and visible node, even for an empty function. This trial specializes
that walk without adding a localization journal or mutation cache:

```c
if (((Param)hn)->level > locallevel)
    scanfunc(hn, 0);
```

The new core helper `scanlocalparams()` lives beside the generic scanners in
`Src/hashtable.c`, where the private scan-status structure is available.
`endparamscope()` changes one call to use it. The helper retains ascending bucket
order, successor tracking for callback deletions/replacements and scan-time
resize suppression. It reads **live** `locallevel` at each node, rather than
caching a threshold. Generated tables receive their original callback and zero
flags through the existing provider. The generic scanners, cleanup callback,
history handling, locale restoration and signal boundaries remain unchanged.

Skipping the private no-op callback for a global does not skip a native setter
or unsetter: the original callback returned before invoking either. Eligible
parameters retain the complete original cleanup path and its level check.
Callbacks that promote, demote or replace an upcoming parameter remain visible.
This approach requires no new parameter-ownership or native-mutation contract.

It still walks **every bucket and node**. Complexity remains
O(scope exits × (bucket capacity + visible parameters)); it is a constant-factor
experiment, not the proposed scope-journal redesign.

The [unapplied five-file proposal](results/round34/proposed-with-fixtures.patch)
contains two production files and three new fixture/benchmark tools. Source
checks remove the new helper and restore the original call to recover the two
complete parent files exactly. Public structures remain unchanged. The SDK adds
one non-`mod_export` core prototype; on this Linux build, the helper nevertheless
appears as one extra ELF export. All 1,056 existing export names/types remain.
There is no supported native ABI removal or changed structure layout. Neither
this declaration nor the helper is retained in production after rejection.

## Profiles and private pilot

Eight matched private-release Callgrind runs retain executable, worker, project
and result hashes, raw profiles, flat views and inclusive caller reports:

| Kernel | Parent instructions | Trial instructions | Reduction | Parent → trial cleanup callbacks |
| --- | ---: | ---: | ---: | ---: |
| coder | 1,387,191,750 | 1,347,247,567 | 2.879% | 3,864,022 → 40,030 |
| chat | 2,363,622,176 | 2,285,211,632 | 3.317% | 7,606,608 → 60,042 |
| endgame | 1,144,450,047 | 1,144,376,472 | 0.006% | 6,642 → 48 |
| json-encode | 2,653,577,740 | 2,590,261,953 | 2.386% | 6,224,907 → 168,006 |

The coder scope-exit inclusive cost drops from 120,916,511 to 80,974,911
instructions; chat drops from 230,482,002 to 152,073,918. Coder still has
20,021 scope exits and chat 40,035. Callback counts fall because global no-op
callbacks disappear; observable restoration callbacks retain their semantics.
The caller extractor deduplicates repeated annotated views of the same edge.
These are whole-process counts, not warm-call latency measurements.

The separate nine-sample private pilot gives coder paste 125.646 → 120.380 ms,
chat paste 225.636 → 215.927 ms, and JSON array encoding 213.001 → 207.806 ms.
It also has slower wide-layout, fetch and drawing controls. Those observations
are retained as `customer-pilot.json` and `library-pilot.json`; their baseline
medians are not substituted into the installed comparison.

## Exact installed measurements

The trial is the inactive package `1.0.0-rc0-9e2e75ec24d7`, SHA-256
`d175ee124c50202e552d71d2025a2ee65b7dde32e4c2217045fec3b020401527`.
Both installed executables are 846,488 bytes. Each case has nine alternating
samples, CPU 13, C.UTF-8 and matching result states. Own builds, tests and
profilers finish before timing; observer modules are prebuilt. The hardware
launcher compiles before its own event measurements. A one-second CPU/sibling
pre-observation reports idle; external activity is not continuously audited.
Positive time change means slower. Customer units are milliseconds per batch;
library units are milliseconds per call.

| Kernel | First parent → trial (ms) | Time change | Repeat parent → trial (ms) | Time change |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 119.544 → 121.263 | +1.44% | 119.667 → 120.632 | +0.81% |
| zcoder.zsh/coder-layout | 5.805 → 5.781 | -0.41% | 5.830 → 5.791 | -0.67% |
| zcoder.zsh/coder-wide-layout | 66.410 → 65.816 | -0.89% | 66.388 → 65.856 | -0.80% |
| zchat.zsh/chat-paste | 216.890 → 219.211 | +1.07% | 215.752 → 216.159 | +0.19% |
| zchat.zsh/chat-layout | 5.813 → 5.812 | -0.02% | 5.807 → 5.797 | -0.17% |
| zchat.zsh/chat-wide-layout | 66.903 → 66.212 | -1.03% | 66.525 → 65.808 | -1.08% |
| endgame/endgame-world | 44.760 → 44.918 | +0.35% | 44.853 → 45.031 | +0.40% |
| z3dfx.mario/mario-race | 20.599 → 20.814 | +1.04% | 20.818 → 20.896 | +0.37% |
| z3dfx/shooter-step | 12.173 → 12.208 | +0.29% | 12.147 → 12.108 | -0.32% |
| z3dfx.agy/shooter-step | 12.325 → 12.141 | -1.49% | 12.215 → 12.237 | +0.18% |
| z3dfx.grok/shooter-step | 12.213 → 12.190 | -0.19% | 12.197 → 12.159 | -0.31% |
| zfetch/fetch-encode | 13.955 → 13.945 | -0.07% | 13.869 → 13.790 | -0.57% |
| z3dfx.drawing/drawing-binning | 13.128 → 13.113 | -0.11% | 13.126 → 13.156 | +0.23% |

| Kernel | First parent → trial (ms) | Time change | Repeat parent → trial (ms) | Time change |
| --- | ---: | ---: | ---: | ---: |
| JSON array | 94.241 → 97.513 | +3.47% | 94.964 → 98.108 | +3.31% |
| JSON array encoding | 210.621 → 209.828 | -0.38% | 210.862 → 211.024 | +0.08% |
| JSON validation | 92.342 → 94.447 | +2.28% | 91.877 → 95.185 | +3.60% |
| navigation | 1.949 → 1.999 | +2.55% | 1.980 → 2.007 | +1.35% |

The installed paste gain disappears. JSON array processing is 3.3–3.5% slower
in both groups; validation is 2.3–3.6% slower. Encoding is essentially flat.
Parser, search and array controls are also retained, including slower cases.
There is no aggregate score or claim about full application startup.

Four installed hardware cases are fully scheduled. Coder instructions fall
from 1,385,395,566 to 1,345,731,737, but median cycles improve only about 0.45%.
Branch misses rise from 1,394,324 to 1,638,879. Mario instructions also fall while
cycles rise about 1%. These counters have whole-process scope and do not prove
a cause for the warm timing differences. No alignment/padding variant is tried.

## Dense and retained-capacity controls

The paired scope driver reuses the existing scope worker and separately compiled
matching-SDK observer modules. It alternates hosts within each case, rotates and
reverses case order across nine samples, verifies table/binding restoration and
retains all 42 cases. Each timer covers 4,000 warm iterations, including dispatch
and body work; setup, warmup, observation and validation are outside the timer.
Cells are parent → trial **microseconds per iteration**:

| Padding | Occupancy | Loop only | Empty | One local | Eight locals | Emulate + local | Nested |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | dense | 0.478 → 0.474 | 3.885 → 3.665 | 4.291 → 4.111 | 6.469 → 6.352 | 5.671 → 5.477 | 8.806 → 8.438 |
| 512 | dense | 0.479 → 0.480 | 5.203 → 4.624 | 5.745 → 5.182 | 7.739 → 7.167 | 6.972 → 6.486 | 11.810 → 10.232 |
| 512 | sparse | 0.476 → 0.476 | 4.117 → 4.067 | 4.543 → 4.465 | 6.584 → 6.582 | 5.932 → 5.821 | 9.201 → 9.218 |
| 4,096 | dense | 0.481 → 0.478 | 15.381 → 12.180 | 16.826 → 12.859 | 18.839 → 14.874 | 18.128 → 14.176 | 37.802 → 25.260 |
| 4,096 | sparse | 0.480 → 0.479 | 5.179 → 5.639 | 5.538 → 5.979 | 7.530 → 8.033 | 6.943 → 7.506 | 11.309 → 12.361 |
| 16,384 | dense | 0.481 → 0.481 | 54.845 → 31.645 | 47.915 → 33.167 | 58.160 → 35.279 | 48.886 → 34.538 | 112.575 → 65.508 |
| 16,384 | sparse | 0.480 → 0.474 | 8.995 → 10.892 | 9.430 → 11.408 | 11.369 → 13.370 | 10.823 → 13.417 | 19.085 → 22.919 |

With 16,384 live globals, the empty-function case improves by about 42%.
After deleting those globals while retaining the enlarged table, the same case
is about 21% slower. Both results matter. The trial retains namespace/capacity
dependence and does not make an empty-function return constant time. These are
controlled namespace perturbations, not a speedup measured in the full apps.

## Compatibility and memory checks

- GCC parent/candidate each pass 63 upstream scripts, zero failures, two skips.
  Clang parent/candidate each pass 63/0/2. The DEBUG candidate passes 62/0/3.
- The new native scope fixture passes **14,112 scenario observations in fourteen
  zero-error Memcheck processes**, leak checking disabled. Each host/locale has
  1,008 scenarios: seven table sizes, three nesting levels, both queued contexts,
  ordinary/generated tables and twelve modes. Independent expected callback
  sequences and counts cover empty/global/mixed tables, higher future levels,
  promotion/demotion, explicit deletion, successor replacement, additions to
  current/future buckets, growth suppression, in-place special restoration and
  nested read-only scans. It does not claim arbitrary nested table destruction
  or unsupported callback mutations are safe.
- The matrix compares preceding GCC, pristine DEBUG, Clang, development DEBUG
  and exact installed builds with per-host SDKs. Repeated observations are not
  that many unique scenarios. Load/unload and queue restoration are checked.
- Existing generic hash-scan tests add 481,248 scenarios in four Memcheck
  processes. Broad comparisons include 192,360 arithmetic, 704,585 scalar,
  5,192 array, 193,236 search, 159,600 pattern, 2,640 substitution and 200,832
  native floating API observations; 20 accessor, 36 completion PTY and 512
  emulation cases also pass. Customer correctness includes 24 project/locale
  kernels and five original project suites. These are focused checks, not a
  complete source audit or universal compatibility proof.
- All seven inactive-package suites pass, including all 190 zdraw tests.
  The exact tested zdraw/zcurl/zmdown objects are staged and package verification
  passes with 24 actual OMZ sessions using re5et/git/highlighter unchanged.
  Installed components, startup identities, invocation modes and split symbols
  pass. No framework code runs as root.

Three setup mistakes are retained under `fixture-errors/`: a fixture identifier
collided with a curses declaration, the installer was initially called with an
invalid action name, and the caller extractor initially received a callee-only
annotation view. Corrected runs pass; no product test failure is hidden or
reclassified. No fresh 32-bit, other-OS or non-multibyte build is certified.

## Restored state and next direction

The inactive trial and private ELF remain available for investigation; active
links never changed. Transient Vendor native outputs are restored from the exact
active payload. All 1,853 canonical input hashes match the active package again,
and the developer returns to its previous SHA-256
`86c7153edc3e45bf994bc02236213dab83a836f00028392c1cbc9bcc8c4acae6`.
It passes 62/0/3 again and another 2,016 scope scenarios under two zero-error
Memcheck processes. Fresh normal-user active-package verification passes with
24 new OMZ sessions and 11,828 protected entries unchanged. The identical active
artifacts reuse their historical seven suite receipts; the inactive trial had
fresh complete suites. Its predecessor's 1,603-entry manifest, `/etc/shells`,
login shell, stable Zsh and personal startup files remain unchanged.

A more structural design could index buckets containing potentially local
parameters, preserving the existing ascending bucket order. It would need to
track every localization path, additions during cleanup, rehashing and opaque
native level changes, with conservative fallback when tracking is uncertain.
The current experiment deliberately adds no such index. Avoiding the whole-table
walk remains a research target; saving callback instructions alone is not an
adequate installed performance case here.

The [evidence index](results/round34/README.md) retains successful and slower
controls, original setup errors and restoration proof. The private rc0 tag,
draft and seven historical assets remain unchanged. No release is published.
