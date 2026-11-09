# Round 29: grouped string hashing, not adopted

**Neither prototype is adopted.** The installed daily driver remains
`1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted optimizations. Production
source is restored to parent `605e124852ff4a8ed61a01ab0b7bba7b77440176`;
the developer executable is byte-for-byte identical to its preceding accepted
build. No activation or new compatibility difference is introduced.

The selected prototype reduces total JSON-encoding instructions by 1.03% and
chat-paste instructions by 0.95%. Native hashing of long keys takes up to about
42% less time in the final length controls. Actual installed-build application
results are less compelling: chat paste takes 1.1–1.5% less time, coder paste
is essentially flat, and JSON encoding takes 0.6–0.9% more time. These mixed
customer results do not justify replacing the accepted implementation.

## Profiles and implementation

Fresh profiles of the actual accepted release cover Endgame, chat paste, JSON
array encoding and JSON validation. Generic `hasher()` accounts for about
3.2–3.5% of instructions in the chat/JSON profiles. Endgame remains dominated
by arithmetic parsing/evaluation, which is a separate research lead.

The original hash starts at zero and applies `h = 33*h + byte` using unsigned
arithmetic. Four steps can be combined as:

```text
h_next = 1185921*h + 35937*a + 1089*b + 33*c + d
```

The coefficients are 33^4, 33^3, 33^2 and 33. Unsigned wraparound preserves the
original result; hash values, collision buckets and table traversal order are
intended to remain identical. Both prototypes still load individual unsigned
characters and check NUL before reading the next one. There are no word-width
memory loads, strlen prepass, alignment requirement, new allocations, cache,
locale dependency, public declaration or signal-boundary change.

The first prototype groups all blocks. Its native length controls show a
16.8% slower two-byte key and smaller one/three/four-byte regressions. Its two
private-build customer groups do show promising coder-paste gains of 4.2–4.9%,
with mixed controls. Those measurements remain in
[grouped-initial](results/round29/grouped-initial/); this variant was not packaged
for a direct installed-binary performance comparison. Its initial application
gains are not proof of an installed-release benefit.

The second prototype peels the first four-byte block, allowing short keys to
return without arithmetic involving an initial zero accumulator. This largely
removes the two-to-four-byte native regression; one-byte hashing remains 8.7%
slower in the final installed comparison. Its source remains reviewable as an
[unapplied experimental patch](results/round29/peeled-source.patch).

Matched private-build instruction profiles have identical project source and
resulting-state fingerprints:

| Kernel | Parent instructions | Peeled instructions | Reduction |
| --- | ---: | ---: | ---: |
| JSON array encoding | 2,653,578,305 | 2,626,359,221 | 1.03% |
| Chat paste | 2,363,622,174 | 2,341,198,461 | 0.95% |

Hash-function self instructions fall from 88,521,563 to 61,303,090 for JSON
encoding and 74,999,240 to 52,575,433 for chat. Instrumented instructions are
not wall time. [Receipts](results/round29/matched-profiles.json), complete flat
reports and compressed raw profiles retain the commands and fingerprints.

## Final installed-release measurements

The decisive comparison uses the exact installed old release and inactive trial
`1.0.0-rc0-e1f66a23cf65`, both release-profile builds with DEBUG off, dynamic
modules, multibyte/PCRE support, `-O2 -g`, explicit `LDFLAGS=-g`, and split symbols.
The machine-code bytes of each measured hash function match its corresponding
private build used for profiling. This check binds the leaf routine, not every
address or byte of the two differently configured executables.

Nine alternating fresh-process samples per pair run on CPU 13. Customer,
library, parser, search, hardware and hash-length groups use C.UTF-8; the array
control driver uses C. Own builds, tests and profilers have completed before
timing. One pre-run observation found CPU 13 idle and its sibling at 1% busy;
that is not a continuous audit or a claim that unrelated work was absent.
Warm timers exclude startup, loading and fixture construction. Output/state
fingerprints match. Positive percentages below mean more time; small or mixed
differences do not establish a useful general benefit.

### Customer kernels

| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 119.713 | 119.581 | -0.1% | 120.662 | 121.173 | +0.4% |
| zcoder.zsh/coder-layout | 5.808 | 5.793 | -0.3% | 5.847 | 5.824 | -0.4% |
| zcoder.zsh/coder-wide-layout | 66.414 | 65.896 | -0.8% | 66.711 | 66.207 | -0.8% |
| zchat.zsh/chat-paste | 216.686 | 213.433 | -1.5% | 221.365 | 218.935 | -1.1% |
| zchat.zsh/chat-layout | 5.778 | 5.789 | +0.2% | 5.866 | 5.843 | -0.4% |
| zchat.zsh/chat-wide-layout | 66.378 | 66.053 | -0.5% | 67.225 | 66.457 | -1.1% |
| endgame/endgame-world | 44.772 | 44.392 | -0.8% | 44.910 | 44.678 | -0.5% |
| z3dfx.mario/mario-race | 20.805 | 20.893 | +0.4% | 20.843 | 21.018 | +0.8% |
| z3dfx/shooter-step | 12.077 | 12.048 | -0.2% | 12.159 | 12.185 | +0.2% |
| z3dfx.agy/shooter-step | 12.154 | 12.115 | -0.3% | 12.183 | 12.113 | -0.6% |
| z3dfx.grok/shooter-step | 12.067 | 12.044 | -0.2% | 12.177 | 12.157 | -0.2% |
| zfetch/fetch-encode | 13.905 | 13.918 | +0.1% | 13.968 | 13.807 | -1.2% |
| z3dfx.drawing/drawing-binning | 13.122 | 13.193 | +0.5% | 13.166 | 13.174 | +0.1% |

### Library operations

| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zjson-array | 94.424 | 96.423 | +2.1% | 94.049 | 94.457 | +0.4% |
| zjson-encode-array | 207.809 | 209.095 | +0.6% | 209.144 | 210.930 | +0.9% |
| zjson | 92.348 | 94.321 | +2.1% | 93.676 | 92.406 | -1.4% |
| navigation | 1.961 | 1.965 | +0.2% | 1.964 | 1.976 | +0.6% |

### Parser controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| html-comment-1m | 132.247 | 133.208 | +0.7% |
| html-prose-100k | 132.417 | 132.426 | +0.0% |
| json-repair-100k | 19.976 | 19.821 | -0.8% |
| html-clean-128 | 103.372 | 101.397 | -1.9% |

### Search controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| tiny-first | 17.430 | 17.213 | -1.2% |
| first | 1.761 | 1.741 | -1.1% |
| middle | 13.328 | 13.339 | +0.1% |
| last | 26.646 | 26.625 | -0.1% |
| missing | 26.647 | 26.682 | +0.1% |
| start-middle | 0.899 | 0.893 | -0.7% |
| start-last | 0.897 | 0.887 | -1.1% |
| start-beyond | 0.871 | 0.860 | -1.3% |
| negative-start | 19.228 | 19.107 | -0.6% |
| backward | 19.100 | 19.209 | +0.6% |

### Array controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| first / size 10 / iterations 20000 | 10.119 | 10.465 | +3.4% |
| first / size 1000 / iterations 20000 | 10.181 | 10.471 | +2.8% |
| first / size 10000 / iterations 20000 | 10.157 | 10.430 | +2.7% |
| first / size 100000 / iterations 20000 | 10.152 | 10.504 | +3.5% |
| middle / size 10 / iterations 20000 | 10.211 | 10.511 | +2.9% |
| middle / size 1000 / iterations 20000 | 13.726 | 13.977 | +1.8% |
| middle / size 10000 / iterations 20000 | 44.451 | 44.758 | +0.7% |
| middle / size 100000 / iterations 20000 | 376.447 | 373.642 | -0.7% |
| last / size 10 / iterations 20000 | 10.296 | 10.552 | +2.5% |
| last / size 1000 / iterations 20000 | 13.725 | 13.952 | +1.7% |
| last / size 10000 / iterations 20000 | 44.419 | 44.693 | +0.6% |
| last / size 100000 / iterations 20000 | 375.777 | 374.521 | -0.3% |
| slice / size 10 / iterations 20000 | 18.095 | 18.267 | +1.0% |
| slice / size 1000 / iterations 20000 | 18.111 | 18.280 | +0.9% |
| slice / size 10000 / iterations 20000 | 18.026 | 18.303 | +1.5% |
| slice / size 100000 / iterations 20000 | 18.130 | 18.195 | +0.4% |
| append / size 0 / iterations 16000 | 8.255 | 8.260 | +0.1% |
| scalar / size 10000 / iterations 20000 | 9.084 | 9.599 | +5.7% |
| prefix / size 100000 / iterations 20000 | 10.494 | 10.733 | +2.3% |
| past-prefix / size 100000 / iterations 20000 | 376.113 | 373.290 | -0.8% |

### Native key-length controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| 0 bytes / 3000000 calls | 8.066 | 8.108 | +0.5% |
| 1 bytes / 3000000 calls | 7.402 | 8.049 | +8.7% |
| 2 bytes / 3000000 calls | 8.126 | 8.100 | -0.3% |
| 3 bytes / 3000000 calls | 8.880 | 8.770 | -1.2% |
| 4 bytes / 3000000 calls | 9.475 | 9.443 | -0.3% |
| 7 bytes / 3000000 calls | 11.538 | 11.149 | -3.4% |
| 8 bytes / 3000000 calls | 12.215 | 11.540 | -5.5% |
| 15 bytes / 1600000 calls | 10.009 | 7.496 | -25.1% |
| 16 bytes / 1500000 calls | 9.853 | 8.244 | -16.3% |
| 31 bytes / 774193 calls | 11.337 | 8.120 | -28.4% |
| 32 bytes / 750000 calls | 11.325 | 7.782 | -31.3% |
| 63 bytes / 380952 calls | 12.554 | 8.144 | -35.1% |
| 64 bytes / 375000 calls | 12.593 | 7.716 | -38.7% |
| 257 bytes / 93385 calls | 15.642 | 9.429 | -39.7% |
| 4096 bytes / 10000 calls | 27.383 | 16.027 | -41.5% |

The native table times repeated hot external calls with checked unsigned
checksums; allocation, module loading and interpreter dispatch are outside its
timers. The fixture is prepared before the first timed call, with no concurrent
build. It is an isolated length control, not a shell or application speed score.

### Hardware controls

These user-space counters cover exec through exit, setup and inherited tasks,
which differs from warm timers. All events were fully scheduled.

| Case | Parent cycles | Trial cycles | Parent instructions | Trial instructions |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 707,145,706 | 701,372,776 | 1,385,395,531 | 1,374,238,077 |
| endgame/endgame-world | 402,313,458 | 400,739,133 | 1,143,872,473 | 1,137,200,975 |
| z3dfx.mario/mario-race | 184,749,478 | 184,466,442 | 430,135,749 | 426,561,252 |
| z3dfx.drawing/drawing-binning | 165,952,146 | 165,245,307 | 421,900,120 | 418,581,488 |

### Earlier noisy pass

An earlier CPU-2 pass of the peeled private build has large swings in unchanged
parent controls: coder paste is 130.226 ms, chat paste 240.930 ms and agy shooter
23.956 ms. Some pairwise changes range from 31.5% less time to 20.2% more time.
The parent ELF, worker and customer source fingerprints match the first pass.
One later aggregate observation records 18% activity on CPU 2's sibling; it
does not establish the cause of the earlier variations.

All nine groups and samples remain under
[peeled-noisy](results/round29/peeled-noisy/). They are not used to adopt a change.
The final pass changes both CPU and executable scope to actual installed builds;
its medians are not substituted into the earlier groups. The data do not isolate
whether code layout, configuration paths, host activity or other factors explain
the differences between private and installed measurements. In particular, the
installed peeled result does not directly measure the first grouped prototype.

## New native coverage and validation

The committed [native fixture](hash-module.c) compares the public hash function
with the exact original release recurrence, checking unchanged errno. Per
host/locale it runs 538,428 counted inputs:

- 522,248 empty and exhaustive nonzero one/two-byte inputs at eight offsets;
- 2,744 selected triples at eight offsets;
- 8,256 exact-sized allocation cases, lengths 0–257 with four content patterns;
- 1,084 protected/read-only mapping cases, including lengths through 65,535;
- 4,096 deterministic buffers with possible embedded NULs and varying offsets.

The page-boundary strings end immediately before an inaccessible page; read-only
mapping checks also reject writes to those inputs. Heap cases under Memcheck
exercise the terminator at the allocation boundary. Long cases exercise unsigned
wraparound. These are focused raw-byte checks, not a proof of all shell behavior.

**5,384,280 checks across ten Memcheck processes pass** for the peeled prototype:
pristine/GCC in C and UTF-8, Clang old/new in UTF-8, pristine/DEBUG in UTF-8,
and exact old/new installed releases in UTF-8. Leak checks are disabled; there
are zero memory errors. This repeats the matrix across hosts/locales, rather
than representing five million distinct strings. A further 1,076,856 Memcheck
checks pass for pristine and the restored accepted developer binary in UTF-8.
Initial smoke receipts remain separate from these final receipts.

The peeled candidate also passes:

- GCC release: 63 upstream scripts, zero failures, two skips. Clang parent and
  candidate each pass 63/0/2. The DEBUG developer build passes 62/0/3; its
  default configuration lacks PCRE. The restored DEBUG build passes 62/0/3 again.
- Eleven broad groups: arrays 5,192; search 193,236; patterns 159,600; scalars
  704,585 across five encodings; substitution 2,640; arithmetic syntax 110,100;
  native floating-point 200,832 scenarios under Memcheck; accessor 20; PTY
  completion 36; emulation frontend 512; and customer correctness, including
  24 kernel/locale pairs plus five original project suites.
- Seven newly built inactive-package suites, including all 190 zdraw tests,
  rebuilt native modules, login/startup/component checks and 24 genuine
  interactive Oh My Zsh sessions with re5et, git and syntax highlighting.
- Exact source/oracle comparison, public declaration/header and dynamic-export
  comparisons. Only the experimental hash function changes in the candidate
  production source. The scanner and array implementation remain unchanged.

Those passes establish correctness evidence for the exercised cases. They do
not override mixed customer performance or make the prototype an accepted
optimization. Other operating systems and a fresh non-multibyte build were not
certified here. The structural index reported partial coverage; exact source
reads and comparisons support the focused source claims.

## Restored state

Active prefix: `/usr/local/psh/releases/1.0.0-rc0-56f97a85e8cb`.

Active ELF SHA-256: `9981ba37c0d6b467e11cb7ce8aacd10a89f95133b7958c7e3aad654cb47e0b72`.

All 1,853 current packaged inputs match that accepted release;
production source matches the parent byte-for-byte. The developer ELF is also
byte-for-byte restored, SHA-256 `86c7153edc3e45bf994bc02236213dab83a836f00028392c1cbc9bcc8c4acae6`.

The normal-user verifier passes again on the unchanged active release,
including a fresh 24-session OMZ gate. Its historical seven-suite receipts are
reused because the exact accepted executable and payload are unchanged; these
are not presented as seven newly rerun suites on the restored release.

The first restored-package verification attempt correctly rejected local Vendor
build outputs left from the inactive trial. The exact previously tested active
module bytes were copied back into those transient build paths, with the trial
bytes preserved in its inactive prefix. No verification check was weakened and
neither installed release was modified. The failed log, hashes and successful
rerun remain in the evidence. A source-only helper also initially required a
not-yet-produced final hardware receipt; that dependency was moved to full
closeout, with no production change.

All 1,603 active-release entries and 11,828 protected stable-Zsh/startup
entries remain unchanged. `/etc/shells`, the account login shell, personal startup
files and framework sources are untouched. Package `latest.json` points back to
the active accepted build. No activation was performed. The inactive trial
`1.0.0-rc0-e1f66a23cf65` is retained for research, with ELF SHA-256
`fdd423343ef1bcdc417dbb75de6b2c3a68c689c3363813db6cc8c4fa3279e354`. Both stripped executables are 846,488 bytes and retain
the same 1,056 dynamic exported names/types.

The project stays `1.0.0-rc0`; the original rc0 tag, draft and seven historical
assets remain unchanged and the repository stays private. There is no new
accepted source patch or release archive from this round. The current accepted
optimization report remains [round 28](round28.md).

[The evidence index](results/round29/README.md) distinguishes proposed/inactive
receipts from restoration proof. It retains every slower control, prototype
and timing pass, with compressed raw profiles. Local-only protected-file and
previous-release snapshots are excluded. The source audit remains incomplete;
arithmetic parsing/evaluation is still a substantial future target in Endgame.
