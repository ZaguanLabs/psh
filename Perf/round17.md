# Round seventeen: count complete-boundary ASCII runs

The saved zcoder paste profile still spends about 10.1% of its instructions
inside `mb_metastrlenend()`. The helper already counts each ASCII byte directly,
but repeats Meta decoding, state tests and bookkeeping around every byte.
This experiment scans raw nonzero ASCII at a complete-character boundary,
then enters the existing conversion loop. It resumes the scan after completed
multibyte handling, including invalid-character recovery.

The [incremental patch](0017-character-count-ascii.patch) applies after round
sixteen. The only production change is in `Src/utils.c`; the other patched file
adds an upstream-format regression. There is no new allocation, cache, public
symbol, representation or module interface. Traversal remains linear.

## Boundaries and retained behavior

The original conversion loop, Meta decoding, incomplete-sequence recovery and
width rules remain intact. In particular, the released ASCII path counts each
control byte as one even in width modes; this optimization preserves that quirk.
The byte-mode/single-byte-locale early return is unchanged, including its raw
byte-distance result for an explicit endpoint.

The scan only runs while a complete-character boundary is known. It consumes
one checked byte at a time and increments the same counter once per character.
The bounded variant checks `ptr < eptr` before each additional read. Conversion
state is neither reset nor advanced by ASCII scanning. After the run,
`laststart` identifies the same boundary as in the original implementation.

After a Meta escape decoding to ASCII, including an embedded NUL, the old loop
continues until multibyte handling completes. This deliberately retains the
cheap repeated-NUL path. A NUL followed by a long ASCII tail therefore does not
receive the new scan's benefit. There is no change to the original outer loop's
endpoint access pattern: native bounded tests keep endpoint sentinels
addressable. These tests do not establish general bounds safety for every API
input or complete-shell behavioral equivalence.

Two prototypes inserted scanning inside the existing ASCII branch. They made
the repeated-NUL count about 92% and 63% slower respectively. They were rejected;
all their application/control samples and source diffs remain under
`results/round17/unguarded-*` and `nul-guard-*`. The earlier bounded-loop pilot
is also retained. Every final table below uses one accepted executable.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and debug assertions. Nine alternating fresh-process samples per build, pinned
to CPU 2 in C.UTF-8. Own builds, tests and profilers were idle during timing.
Construction, loading and warm-up precede timing; paste reset and binning
preparation remain measured. Outputs and states match. Binary, worker, source
hashes and every sample are retained in [the results](results/round17/).

Customer kernels, milliseconds per complete batch:

| Operation | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 119.278 | 116.192 | 1.03x |
| zcoder.zsh/coder-layout | 5.754 | 5.764 | 1.00x |
| zcoder.zsh/coder-wide-layout | 94.343 | 94.976 | 0.99x |
| zchat.zsh/chat-paste | 209.797 | 208.011 | 1.01x |
| zchat.zsh/chat-layout | 5.756 | 5.744 | 1.00x |
| zchat.zsh/chat-wide-layout | 95.154 | 94.676 | 1.01x |
| endgame/endgame-world | 47.966 | 47.756 | 1.00x |
| z3dfx.mario/mario-race | 29.009 | 29.008 | 1.00x |
| z3dfx/shooter-step | 14.721 | 14.976 | 0.98x |
| z3dfx.agy/shooter-step | 14.765 | 14.886 | 0.99x |
| z3dfx.grok/shooter-step | 14.800 | 14.951 | 0.99x |
| zfetch/fetch-encode | 13.078 | 13.184 | 0.99x |
| z3dfx.drawing/drawing-binning | 14.600 | 14.498 | 1.01x |

The zcoder paste median improves by **2.6%** (about 3.1 ms per 10,000-character
batch), and zchat paste by **0.9%**. Most other customer medians remain close.
The main shooter median is **1.7% slower**, and URL encoding is **0.8% slower**;
AGY/Grok and wide zcoder layout also have small slower medians. All are retained.
These kernels do not measure application startup, complete interactive sessions
or terminal painting. No aggregate project score is used.

Warm library calls, milliseconds per call:

| Operation | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 99.695 | 98.566 | 1.01x |
| zjson-encode-array | 215.098 | 215.334 | 1.00x |
| zjson | 96.062 | 95.788 | 1.00x |
| navigation | 2.169 | 2.170 | 1.00x |
| html-comment-1m | 129.497 | 130.131 | 1.00x |
| html-prose-100k | 128.637 | 128.629 | 1.00x |
| json-repair-100k | 19.539 | 19.519 | 1.00x |
| html-clean-128 | 101.164 | 100.461 | 1.01x |

Library results remain close: JSON array parsing improves about 1.1%, while the
large HTML-comment median is about 0.5% slower. These small differences are not
presented as separately established mechanisms.

Focused character-count batches, milliseconds for **100 calls**:

| Operation | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| count-ascii | 63.564 | 23.111 | 2.75x |
| count-wide | 24.371 | 24.558 | 0.99x |
| count-mixed | 3.637 | 3.254 | 1.12x |
| count-nul | 0.669 | 0.665 | 1.01x |
| count-nul-tail | 0.661 | 0.666 | 0.99x |
| count-meta | 11.931 | 12.817 | 0.93x |
| count-invalid | 0.767 | 0.269 | 2.85x |
| count-incomplete | 0.662 | 0.265 | 2.50x |

`count-ascii` uses 1,000,000 characters; the other count cases use 10,000.
`count-wide` repeats é; `count-mixed` uses `abcdefgé`. `count-nul-tail` starts
with one embedded NUL. `count-meta` repeats raw byte 0x83, correctly metafied
before counting. `count-invalid` starts with 0xff followed by ASCII;
`count-incomplete` ends an ASCII prefix with an incomplete UTF-8 leader.
Each sample independently checks the expected character count.

Long ASCII counts improve by **2.75x**, mixed counts by **1.12x**, the single
invalid-byte plus ASCII case by **2.85x**, and the incomplete-ending case by
**2.50x**. Repeated NULs remain close. The repeated invalid-Meta control is
**7.4% slower**; the all-Unicode control is about **0.8% slower**. This is a
focused ASCII optimization, with those costs retained rather than hidden.
The [complete scalar results](results/round17/slice-benchmarks.json) also retain
all 23 prior slice/index controls; their slowest median is about 1.7% slower.

Matched Callgrind instruction totals include startup, library loading,
construction and warm-up:

| Kernel | Previous instructions | New instructions | Reduction |
| --- | ---: | ---: | ---: |
| coder | 1,545,302,255 | 1,440,165,716 | 6.8% |
| chat | 2,591,160,528 | 2,486,024,121 | 4.1% |

Self instructions in `mb_metastrlenend()` fall from 156,567,862 to 51,431,425
in zcoder, and from 157,068,162 to 51,931,725 in zchat. This supports the
bookkeeping reduction. Instructions are not CPU cycles or warm-call wall time.
[Commands, hashes and matching state](results/round17/accepted-profile-commands.json),
compressed raw profiles and flat reports are retained.

## Compatibility evidence

- Development build: **62 upstream scripts pass, zero failures, three expected
  skips** (privileged, PCRE and GDBM). The new regression also passes on pristine
  Zsh, as does the existing focused subscript regression.
- The [native fixture](mb-length-module.c), compiled with pristine configured
  headers, compares with the [original release counter](mb-length-reference.c).
  **20,463,680 scenarios across ten Memcheck processes** pass in C, C.UTF-8,
  EUC-JP, GB18030 and EUC-TW, using pristine and candidate hosts. **Zero memory
  errors**, leak checking disabled. Each locale tests multibyte on/off, widths
  -7/0/1/2/7, four allocation alignments, whole strings and explicit endpoints.
  It checks complete buffer bytes and observable continuation of private
  conversion state, both initially clear and seeded with an incomplete sequence.
- Native inputs include 19 plain ASCII lengths through 1,024, mixed strings
  exceeding 2,000 bytes, every raw byte after four ASCII boundaries, embedded
  NUL/Meta, controls/DEL, valid/invalid/incomplete UTF-8 and actual locale-encoded
  wide characters. Short strings exercise every explicit endpoint; long strings
  exercise selected interior boundaries and both ends. Whole strings end at
  exact allocations; bounded spans retain addressable endpoint sentinels.
- **704,585 five-encoding scalar comparisons**, **5,192 array comparisons**,
  **193,236 search comparisons**, **159,600 five-encoding pattern comparisons**
  and **2,640 substitution comparisons** match pristine behavior. Twenty custom
  accessor/API cases and 36 real PTY completion buffers match.
- The no-multibyte build passes its available substitution and conditional
  scripts, matches pristine in **281,834 scalar comparisons**, and passes the
  existing matching-header scalar-index Memcheck fixture.
- Twenty-four customer kernel/locale comparisons match pristine output/state.
  zjson, zoup, z3dfx, Endgame and AGY/Grok suites pass with matching status and
  diagnostics; all 307 zhtml2md checks pass with its explicit child-shell override.
- All **1,847 pristine hashes**, the complete preceding snapshot, **1,055 dynamic
  exported names/types** and six generated public declaration files are verified.
  The incremental patch reconstructs accepted sources from round sixteen.
  These are focused compatibility checks, not a complete source audit.

## Installed daily driver

The accepted source is installed and active as **`5.9.2-38c0e71e2244`** under
`/usr/local/psh/releases/`. Its **63 core scripts pass**, with two expected
skips, along with all six bundled project suites, including **190 zdraw tests**.
It retains all 37 stock modules, PCRE2, private SDK/function/script paths, and
the six pinned projects with matching native modules. Installed component
loading and native change-gutter rendering pass, as does login startup in a PTY.

A further **8,187,680 reference scenarios across four Memcheck processes**
pass in C and C.UTF-8 using pristine and packaged hosts: **4,093,840 per host**,
zero memory errors, leak checking disabled. Package/source/module hashes and
suite status are in [the installation record](results/round17/installed-package.json)
and [the package API results](results/round17/package-count-api.json). The
production binary differs from the development timing binary because its
paths and module configuration differ.

All **11,828 protected Zsh/startup entries**, the account login shell and
`/etc/shells` are unchanged. The previous release is verified against its full
recorded file manifest and remains intact for existing sessions and rollback.
The two production binaries retain identical exported names/types. Start a new
psh process to use this release; an existing session keeps its own release.
Full private logs remain under `.work/logs/round17/` and
`.work/package/5.9.2-38c0e71e2244/`.

Development timing binary SHA256:
`4b4ed9e3baca23c896bb76ad6f28b6c997fdf8625794a86ea75809b9e4a1bc98`.

## Reproduce the focused checks

After [building the pristine and candidate trees](README.md), run:

```sh
python3 Perf/check-mb-length-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/count-api.json
python3 Perf/slice-benchmark.py /path/to/previous/psh ./psh \
  --indices --counts --cpu 2 --samples 9 --output .work/logs/count-timings.json
```

Keep builds, tests and profilers idle while timing. The native fixture requires
the five installed locales listed above; repeat `--locale` to select a subset.
