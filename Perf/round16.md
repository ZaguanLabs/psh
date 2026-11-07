# Scalar indexing through guarded ASCII groups — 2026-11-07

This round compares the fifteenth psh (`.work/round15/psh`) with the sixteenth. Packaging work between these rounds left the core source unchanged. Both builds include the separate maintainer fix for scalar-search terminator reads. These ratios isolate this change.

## Profile and change

The preceding zfetch URL-encoding profile spends about 34% of its instructions in `getarg()`, predominantly advancing one character at a time to a numeric scalar index. The encoder repeatedly reads later positions in the same string. zcoder paste also exercises this traversal.

Numeric scalar traversal now advances eight characters together when all eight stored bytes are nonzero ASCII and at least eight logical characters remain. Each byte is tested in address order with short-circuit conditions. A NUL or non-ASCII byte stops the probe before a later address is read. There are no word loads, alignment assumptions, allocation padding requirements, new length scans or caches.

Each eligible group replaces eight iterations that previously advanced the pointer and count by one without calling a converter. Groups can resume after a Unicode character or Meta escape. After each group, `lastcharlen` becomes one; preserving this matters when an ASCII run follows a multibyte character. Other characters retain the original conversion/Meta-width path, and conversion initialization, accessor calls, allocation and signal queue boundaries stay in place.

This applies to positive and negative numeric scalar indexing. Word, array and reverse-pattern search paths retain their implementation. Indexing remains linear; repeated scalar indexing can still be quadratic. Eight is an unroll factor, independent of storage layout.

The [incremental patch](0016-scalar-ascii-blocks.patch) applies after round fifteen. A prefix-only prototype left the malformed-UTF-8 repair control about 6.7% slower in the first run and 8.5% slower in a follow-up. That prototype and its measurements are retained under `results/round16/prefix-only-*`. The accepted implementation handles later ASCII runs too; every final table below uses the same accepted executable.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support and debug assertions. Nine alternating fresh-process samples per build, pinned to CPU 2 in C.UTF-8. Construction, loading and warm-up precede timing; paste reset and binning preparation remain measured. Own builds, tests and profilers were idle during the accepted timings. Outputs and states match.

Customer kernels, milliseconds per complete batch:

| Project / operation | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 116.857 | 119.718 | 0.98x |
| zcoder.zsh/coder-layout | 5.772 | 5.762 | 1.00x |
| zcoder.zsh/coder-wide-layout | 94.335 | 94.680 | 1.00x |
| zchat.zsh/chat-paste | 212.894 | 212.425 | 1.00x |
| zchat.zsh/chat-layout | 5.809 | 5.787 | 1.00x |
| zchat.zsh/chat-wide-layout | 95.023 | 95.515 | 0.99x |
| endgame/endgame-world | 47.807 | 48.068 | 0.99x |
| z3dfx.mario/mario-race | 29.183 | 29.323 | 1.00x |
| z3dfx/shooter-step | 15.005 | 14.922 | 1.01x |
| z3dfx.agy/shooter-step | 14.935 | 14.971 | 1.00x |
| z3dfx.grok/shooter-step | 14.867 | 14.918 | 1.00x |
| zfetch/fetch-encode | 13.853 | 13.183 | 1.05x |
| z3dfx.drawing/drawing-binning | 14.811 | 14.624 | 1.01x |

URL encoding improves by **1.05x**. The zcoder paste median is **2.4% slower** (about 2.9 ms per 10,000-character batch). Other customer medians remain close, with smaller gains and regressions retained. These kernels do not measure application startup, whole interactive sessions or terminal painting.

Warm application/library calls, milliseconds per call:

| Operation | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 100.581 | 101.387 | 0.99x |
| zjson-encode-array | 218.420 | 219.021 | 1.00x |
| zjson | 96.889 | 97.708 | 0.99x |
| navigation | 2.230 | 2.237 | 1.00x |
| html-comment-1m | 160.127 | 129.661 | 1.23x |
| html-prose-100k | 130.653 | 129.318 | 1.01x |
| json-repair-100k | 21.078 | 19.516 | 1.08x |
| html-clean-128 | 100.307 | 101.371 | 0.99x |

**1 MiB comment conversion improves by 1.23x**, and malformed-UTF-8 JSON repair by **1.08x**. Other library medians remain close; the cleaner measures about 1.1% slower. The first application-call run lacked embedded binary/worker hashes. All four application cases were rerun after adding that provenance and source-stability checks; the table uses that complete follow-up. The initial run remains in `application-benchmarks-initial.json`, including its 1.9% slower JSON encoding median.

Selected scalar controls, milliseconds per complete batch:

| Operation | Size parameter | Calls | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| prefix | 32 | 2000 | 1.219 | 1.192 | 1.02x |
| prefix | 1000000 | 2000 | 20.110 | 20.120 | 1.00x |
| middle | 1000000 | 20 | 6.744 | 4.465 | 1.51x |
| suffix | 1000000 | 20 | 13.212 | 8.716 | 1.52x |
| full | 1000000 | 20 | 15.092 | 12.749 | 1.18x |
| mb-suffix | 1000000 | 20 | 13.242 | 8.727 | 1.52x |
| late-unicode | 10000 | 20 | 10.187 | 10.397 | 0.98x |
| mixed-suffix | 10000 | 20 | 1.260 | 1.231 | 1.02x |
| nul-suffix | 10000 | 20 | 0.689 | 0.357 | 1.93x |
| negative | 1000000 | 20 | 18.221 | 9.623 | 1.89x |

Large late ASCII reads improve by about 1.5x; the selected negative read improves by 1.89x, and the NUL-containing suffix case by 1.93x. The late-Unicode control is about 2.1% slower. All 23 cases and every sample are retained in [the scalar results](results/round16/slice-benchmarks-final.json). No separate mechanism was isolated for the small slower medians.

Paired Callgrind instruction totals include startup, loading, construction and warm-up:

| Kernel | Previous instructions | New instructions | Reduction |
| --- | ---: | ---: | ---: |
| fetch | 341,715,830 | 295,875,625 | 13.4% |
| coder | 1,563,372,375 | 1,545,302,153 | 1.2% |
| repair | 2,075,804,509 | 1,756,095,547 | 15.4% |
| html | 20,825,298,882 | 14,921,292,745 | 28.4% |

Instruction totals support the focused traversal reduction; they are not CPU cycles or measured warm-call timings. In particular, zcoder paste executes fewer instructions while its wall-time median is slower. Commands, environments, binary/worker/source hashes and matching output hashes are in [the profile record](results/round16/accepted-profile-commands.json).

## Compatibility evidence

- Development build: **62 upstream scripts pass, zero failures, three expected skips** (privileged, PCRE and GDBM). Both new upstream-format subscript/Unicode regressions also pass on the untouched release.
- Another **384 extreme integer-index reads** (through signed 64-bit boundaries) match pristine behavior.
- **704,585 scalar comparisons** match pristine Zsh across C, C.UTF-8, EUC-JP, GB18030 and EUC-TW. Cases include reads and isolated assignments, native/ksh/sh emulation, multibyte on/off, block boundaries, NUL/Meta/high bytes, converted wide characters, incomplete endings and ASCII tails. A separate no-multibyte build matches in **281,834 comparisons**, and passes the available substitution/conditional scripts with its expected Unicode skip.
- Pristine-header native fixture: **1,532,544 API checks across eight Memcheck runs**, using both shells, both locales and matching multibyte/no-multibyte builds. **Zero errors**, leak checking disabled. Checks exercise exact-ending allocations at eight alignments, lengths 0–65 and nine larger boundaries through 1,025 bytes, every raw byte after six ASCII boundaries at two alignments, and valid UTF-8 followed by ASCII. Original converter boundaries are the oracle. Getter call counts, full input bytes, positive/negative reads, off-end handling and module cleanup match.
- **5,192 array**, **193,236 search**, **159,600 five-encoding pattern**, and **2,640 substitution comparisons** match pristine behavior. Twenty custom-accessor/API cases and 36 actual PTY completion buffers match.
- Twenty-four customer kernel/locale comparisons match pristine output and state. zjson, zoup, z3dfx, Endgame and AGY/Grok suites pass with matching diagnostics/status; all 307 zhtml2md checks pass with its explicit child-shell override.
- All **1,847 pristine source hashes** and the preceding snapshot are verified. All **1,055 dynamic exported names/types** and six sets of generated public declarations match pristine Zsh. The incremental patch reconstructs the accepted sources from round fifteen.

## Installed daily driver

The accepted source is installed as `5.9.2-c31cc9d65fda` under `/usr/local/psh/releases/`. That build retains all 37 existing stock modules, enables PCRE2, and bundles the six projects with matching native builds. Its **63 core scripts pass** with two expected skips; all project suites pass, including **190 zdraw tests**. Installed reusable component loading and native change-gutter rendering pass, along with login startup in a PTY.

An additional **766,272 pristine-header API checks** pass under Memcheck against the packaged host, with zero errors. Its binary is distinct from the development executable used for the timing tables because its paths and module configuration differ; hashes and native results are recorded in [installed-package.json](results/round16/installed-package.json) and [package-index-api.json](results/round16/package-index-api.json).

All 11,828 protected Zsh/startup entries, the account login shell and `/etc/shells` remain unchanged. The previous psh release remains intact for existing sessions and rollback. Start a new psh process to select this release. Full logs stay under `.work/logs/round16/` and `.work/package/<release>/`.

These are focused compatibility checks and local measurements, not proof of complete shell equivalence or a completed source audit.
