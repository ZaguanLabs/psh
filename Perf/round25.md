# Round twenty-five: merge the ASCII and token classification branches

The twenty-third accepted optimization merges two identical branches in
`itype_end()`. A stored ASCII byte can reach the live classification test
without first testing its internal-token flag. Non-ASCII tokens still take the
same one-byte path; other non-ASCII input retains the original converter.

The [incremental patch](0025-classification-branch-merge.patch) applies after
`5cdb994b00ed4c49bc57a115ca29b71d1193fb2d`. The version remains **1.0.0-rc0**.
No new language difference, native ownership rule or public layout is intended.

## Profile and source review

Fresh profiles of the actual installed `1.0.0-rc0-1ad2ab786b8a` attribute
81,308,914 self instructions to `itype_end()` in Endgame, **6.95%** of the whole
process. The helper also accounts for 144,366,765 instructions, **4.14%**, in
JSON validation. That function-level count includes paths outside this change;
it is not all removable work.

Round fourteen had added an ASCII branch after the existing token branch.
Both branches set width one and apply exactly the same live `zistype()` test.
Their conditions can be merged and ASCII tested first. This preserves behavior
even if a native module has changed the public classification table so that
an ASCII byte carries the token bit. The current table still decides membership.

GCC disassembly confirms that ASCII avoids the token-mask test and its branch,
along with redundant byte-extension work. The helper's matched Endgame self
instructions fall from **81,308,914 to 66,906,410**, about **17.7%**. The first
conversion-state initialization, `once` handling, terminator check, byte-mode
path and all wide-character/converter branches remain unchanged. No additional
read, allocation, cache, converter call or signal boundary is introduced.

This is a narrower optimization than replacing the character classifier. It
does not change arithmetic syntax, numeric conversion, identifier rules or
array representation. Generic scope-table scans remain a separate target;
round eighteen's rejected scanner variants remain rejected.

## Measurements

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0, release assertions disabled,
`-O2 -g`, explicit `LDFLAGS=-g`, multibyte and PCRE enabled. The immutable
reference is the preceding commit with the same configuration and its own
private runtime. Each run uses nine alternating fresh-process samples per
binary, CPU 2, C.UTF-8. Own builds and profilers finished before timing;
validation and further builds started after the full timing sequence ended.
External system activity was not exhaustively audited.

All resulting states/output hashes match. Loading, construction and warm-up
precede warm timers; resets/preparation retain the existing workload definitions.
These are offline batches, not UI startup, terminal frame rate, GPU or network
measurements. Every sample and slower control is retained.

### Customer kernels

| Kernel | First before → after ms | Repeat before → after ms |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 113.663 → 112.387 | 113.115 → 112.187 |
| zcoder.zsh/coder-layout | 5.457 → 5.455 | 5.476 → 5.441 |
| zcoder.zsh/coder-wide-layout | 63.105 → 62.279 | 62.959 → 62.313 |
| zchat.zsh/chat-paste | 202.556 → 201.613 | 202.578 → 202.484 |
| zchat.zsh/chat-layout | 5.475 → 5.445 | 5.453 → 5.414 |
| zchat.zsh/chat-wide-layout | 62.808 → 62.571 | 62.810 → 62.413 |
| endgame/endgame-world | 43.268 → 42.411 | 43.127 → 42.246 |
| z3dfx.mario/mario-race | 19.820 → 19.479 | 19.707 → 19.439 |
| z3dfx/shooter-step | 11.449 → 11.450 | 11.487 → 11.408 |
| z3dfx.agy/shooter-step | 11.561 → 11.582 | 11.570 → 11.515 |
| z3dfx.grok/shooter-step | 11.553 → 11.538 | 11.537 → 11.451 |
| zfetch/fetch-encode | 13.324 → 13.289 | 13.020 → 13.054 |
| z3dfx.drawing/drawing-binning | 12.514 → 12.350 | 12.573 → 12.429 |

Endgame takes **2.0% less time in both runs**; Mario takes **1.7% and 1.4% less**.
Coder paste takes **1.1% and 0.8% less**, wide coder layout **1.3% and 1.0% less**,
and drawing **1.3% and 1.1% less**. Other changes are smaller: the first AGY run
is about 0.2% slower; repeated URL encoding about 0.3% slower. Shooter controls
are near unchanged initially and improve modestly on repeat. No aggregate
application score or universal speedup is claimed.

### Customer libraries

| Operation | First before → after ms/call | Repeat before → after ms/call |
| --- | ---: | ---: |
| zjson-array | 92.434 → 92.884 | 91.272 → 90.563 |
| zjson-encode-array | 208.730 → 206.303 | 206.546 → 205.848 |
| zjson | 86.900 → 88.785 | 87.814 → 87.077 |
| navigation | 1.850 → 1.860 | 1.834 → 1.827 |

Array parsing is **0.5% slower initially**, then **0.8% faster**. JSON validation
is **2.2% slower initially**, then **0.8% faster**. Encoding improves **1.2% and
0.3%**. Navigation is **0.6% slower initially**, then slightly faster. The mixed
library results do not establish a repeatable parsing/validation improvement.
Matched instruction evidence below also shows validation barely changes.

### Parser and search controls

| Parser operation | Before → after ms/call |
| --- | ---: |
| html-comment-1m | 125.297 → 125.239 |
| html-prose-100k | 127.556 → 128.808 |
| json-repair-100k | 19.056 → 18.871 |
| html-clean-128 | 97.422 → 97.289 |

HTML prose conversion is about **1.0% slower**; malformed-UTF-8 repair about
**1.0% faster**. Comment conversion and cleaning remain close. No separate causal
mechanism is assigned to these small whole-binary changes.

| Search case | Before → after ms/batch |
| --- | ---: |
| tiny-first | 15.987 → 15.826 |
| first | 1.611 → 1.591 |
| middle | 12.381 → 12.380 |
| last | 24.873 → 24.845 |
| missing | 24.763 → 24.711 |
| start-middle | 0.816 → 0.811 |
| start-last | 0.821 → 0.812 |
| start-beyond | 0.795 → 0.784 |
| negative-start | 17.810 → 17.742 |
| backward | 17.994 → 17.897 |

These controls retain their original algorithms, including round twenty-four's
forward-start prefix reuse. Their complete samples remain in the evidence.

## Instruction and hardware evidence

Matched Callgrind totals include startup, preparation, cold discoveries and
warm-up. Source and final state hashes match within each pair.

| Profile | Before instructions | After instructions | Reduction |
| --- | ---: | ---: | ---: |
| endgame | 1,169,346,849 | 1,154,944,301 | 1.232% |
| json-encode | 2,877,017,951 | 2,867,284,435 | 0.338% |
| json-validate | 3,490,322,895 | 3,490,287,369 | 0.001% |

The Endgame reduction is concentrated in the revised classifier. Validation's
near-unchanged instruction count limits interpretation of its variable warm
latency. Instruction reductions alone do not establish lower elapsed time.

The Linux counter launcher measures user-space events from exec through exit,
including inherited tasks and preparation, unlike warm timers. All events are
fully scheduled.

| Kernel | Before → after cycles | Instruction reduction |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 714,612,022 → 716,978,095 | 1.22% |
| endgame/endgame-world | 417,455,757 → 409,038,852 | 1.23% |
| z3dfx.mario/mario-race | 189,616,031 → 187,512,523 | 2.24% |
| z3dfx.drawing/drawing-binning | 170,056,523 → 167,781,106 | 1.73% |

Coder paste's cycle median is about **0.3% higher** despite fewer instructions
and lower warm duration. Endgame cycles fall **2.0%**, Mario **1.1%**, and drawing
**1.3%**. Different boundaries and small timing effects remain visible.

## Compatibility and native checks

- GCC and both Clang release builds pass **63 upstream scripts**, zero failures,
  two expected skips. The refreshed debug build passes **62 scripts**, zero
  failures, three expected skips (its default configuration disables PCRE).
- Expanded native classification coverage passes **28,588,032 checks across
  22 Memcheck processes**, with zero memory errors, leak checks disabled.
  GCC release runs in C/C.UTF-8/EUC-JP/GB18030/EUC-TW; Clang release, pristine
  versus debug development, and the exact installed pair each run C/C.UTF-8.
  Every host/locale performs 1,299,456 checks against the original release
  function, including converter state after each call and unchanged input bytes.
- Cases include all raw/metafied byte values, exact-ending allocations at two
  alignments, more prefix lengths through 1,024, runtime multibyte and POSIX
  identifier settings, changed word/separator sets, mutated public `typtab`,
  combined and zero class masks, and `once` values 0/1/−7/INT_MAX.
  Masks classifying the terminating NUL (including −1) are excluded by the
  fixture’s existing byte-mode guard; no negative-class-mask coverage is claimed.
- Other release comparisons pass **110,100 arithmetic syntax**, **704,585
  scalar**, **5,192 array/append**, **193,236 search**, **159,600 pattern** and
  **2,640 substitution** checks, 36 PTY completion buffers, 20 native accessor
  cases and **200,832 native numeric scenarios** under Memcheck. Twenty-four
  customer kernel/locale states and five original project suites match.
- All **1,056 dynamic exported names/types** remain. No public header or native
  structure changes. The existing pristine snapshot and installed core inputs
  are checked, and the incremental patch is reconstructed from the parent.

The first classifier attempt used the driver's hardcoded pristine debug SDK
against a release executable, causing module loading to fail on the debug-only
`queue_in` export before any classifier test ran. The driver now accepts explicit
configured build/source header paths; release checks use matching release SDKs.
The failed receipt/log remains alongside corrected successful receipts.
This is a harness configuration correction, not a new native ABI exception.

These checks establish focused coverage, not universal platform or script
compatibility. A no-multibyte build and other operating systems are not newly
certified by this round. The unchanged byte-mode branch remains covered in
runtime-multibyte-off comparisons.

## Installed daily driver

The isolated package **`1.0.0-rc0-d9a609a3adc3`** is active through
`/usr/local/bin/psh`. Its stripped executable remains **846,488 bytes**, SHA-256
`c23354279fbccaf9dd3f230b8fdf25b0ef92e2bd5cab26a6610bd242622f7cb3`.
The preceding `1ad2ab786b8a` release remains available for rollback.

All seven package suites pass, including **190 zdraw tests**. Normal-user
verification passes genuine login PTY checks, installed reusable components
and **24 unchanged Oh My Zsh sessions**, with the existing re5et theme, git
plugin and syntax highlighter. The installer consumes the matching exact-shell
certificate before activation. Post-activation inventories confirm **11,828
stable Zsh/startup entries**, **1,603 preceding-release entries**, `/etc/shells`
and the account login shell remain unchanged.

The private repository, rc0 version, original annotated tag, release draft and
seven existing assets remain in place. This iteration publishes no release.

[All evidence](results/round25/) retains complete gains, slower controls, the SDK
setup failure, commands and source/binary hashes. The source-wide audit remains
incomplete; option emulation, scope cleanup and arithmetic parsing remain
profiling targets.
