# Round 87 — scan ASCII runs in character-class lookups

Scanning identifiers and other character classes in `itype_end` accounted
for 4.63% of user-space instructions during zchat paste on round 86.
Giving consecutive ASCII characters their own loop reduced that function's
self instructions from 93.7 million to 76.3 million. Thirteen of the
fourteen customer kernels took less time in both comparisons. Zfetch was
essentially flat.

## Implementation and alternatives

In multibyte mode, `itype_end` initializes the conversion state and consumes
each run of nonzero ASCII bytes with the live character-class table. It
tests the actual requested class mask, including native modifications, and
honors a single-character request after the first match. On reaching a
non-ASCII byte it follows the existing token or conversion path, then
resumes the ASCII loop. End pointers, token widths and conversion state
remain observable through the same native interface. The standalone
byte-mode path, including its POSIX identifier dispatch, is unchanged.
A build configured without multibyte support produced identical
preprocessed scanner bodies for round 86 and both trials.

The first experiment (`ascii`) accelerated only the initial ASCII prefix
of a multi-character scan. It improved several timings but increased the
trained scanner from 1,376 to 2,313 bytes. During zchat paste it raised
the scanner's self instructions to 102.6 million and zfetch was slower in
both timing runs. The accepted version (`runs`) handles subsequent ASCII
runs with the same loop. Its symbol was 1,279 bytes, and GNU size reported
144 fewer text bytes across the entire executable than round 86.

## Customer workloads

Both release binaries used GCC 15.2 with the packaging pipeline's
offline profile training and link-time optimization. The actual customer
kernels were held out. Each run used nine alternating samples per host on
CPU 13 in C.UTF-8, and the repeat started with the opposite host. Each
comparison checked the complete resulting application state. Values below
are medians in milliseconds per batch.

| Workload | Round 86 | Round 87 | Round 86 repeat | Round 87 repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder wide layout | 59.374 | 56.664 | 59.538 | 56.808 |
| zchat wide layout | 59.143 | 56.391 | 59.402 | 56.751 |
| zchat paste | 118.152 | 115.286 | 117.996 | 114.594 |
| Endgame world | 38.120 | 37.227 | 38.067 | 37.102 |
| Drawing binning | 11.343 | 10.885 | 11.273 | 10.898 |
| zfetch encode | 11.294 | 11.297 | 11.275 | 11.303 |

A separate five-sample comparison measured zchat paste at 170.88 ms for
the installed rc2 and 115.66 ms for this build. Against pristine release
Zsh, it took 246.65 and 115.29 ms respectively. These comparisons include
the work of earlier rounds. Separate Callgrind runs on round 86 and round
87 measured whole-process zchat instruction counts of 2.026 billion and
2.009 billion. Endgame fell from 1.068 billion to 1.057 billion, with
scanner self counts falling from 55.9 million to 45.0 million.

Hardware counters measured 5.6% fewer user-space cycles on zcoder wide
layout, 3.4% fewer on zchat paste and 2.2% fewer on Endgame. Retired
instructions fell by about 1% on each. Branch misses fell 15.5%, 14.1%
and 3.3% respectively. These counters cover the whole process, including
loading and validation.

A matched LTO build without profile guidance showed smaller gains.
Zchat paste took 134.59 versus 136.60 ms and 134.68 versus 136.22 ms.
Zcoder wide layout took 65.42 versus 65.64 ms and 65.30 versus 65.87 ms.

## Identifier shape and memory

A focused control made 20,000 indirect parameter reads per batch. Nine
rotating samples per shell verified the resulting name and value. The
short ASCII identifier took 3.684 → 3.825 ms. The 64-character ASCII
identifier took 5.100 → 4.997 ms and a 63-character ASCII prefix followed
by a wide character took 6.860 → 6.398 ms. The all-wide control took
69.451 → 69.819 ms and alternating ASCII and wide characters took
37.531 → 37.693 ms. These are elapsed times for complete shell reads.

Separate memory measurements sampled Linux smaps and process status
with application state live. At cycle 20, across five fresh processes
per shell, private memory in KiB was 1,440 → 1,444 on zchat paste,
2,304 → 2,300 on Endgame and 2,368 → 2,364 on zcoder wide layout.
Anonymous memory was 500 → 504, 1,360 → 1,360 and 1,428 → 1,424.
Virtual size was identical within each pair. Peak RSS went from 4,180 to
4,320 KiB on paste, 4,880 to 4,924 on Endgame, and 5,556 to 5,676
on wide layout. The resident results varied by workload despite the smaller scanner.

A second set of five samples reversed host order. Anonymous memory again
differed by at most 4 KiB. Private memory was 52, 48 and 28 KiB lower
for the candidate on paste, Endgame and wide layout respectively. Peak RSS
moved by −16, +28 and −124 KiB. The two runs support treating the practical
footprint as comparable on this host.

## Compatibility and reproduction

The native classifier fixture compares the returned pointer, the input
bytes and the subsequent conversion result with the original Zsh scanner.
The added case crosses two multibyte characters separated by ASCII. The
expanded fixture passed 1,301,760 checks per shell per locale in C,
C.UTF-8, Japanese EUC-JP, Chinese GB18030 and Taiwanese EUC-TW. Coverage
includes both multibyte option settings, POSIX identifiers, single-character
requests, mutable classification bits and changes to IFS and WORDCHARS.
The C.UTF-8 comparison also passed under Memcheck.

The upstream suite passed 64 scripts with two skips. Both trained builds
passed 24 interactive Oh My Zsh sessions, seven paired native-loader cases,
and 14,237 bundled zjson checks in each of C and C.UTF-8. All builds used
isolated development runtimes.

Run `Perf/customer-benchmark.py` for the application timings and
`Perf/memory-checkpoints.py` for the resident measurements.
`python3 Perf/results/round87/lookup.py --cpu CPU --shell BASE --shell CANDIDATE
--output lookup.json` runs the name-shape controls. For the native comparison
use `Perf/check-itype-module.py` with matching build and source headers.
Build identities, both patches, profiles, raw timing samples and gate results
are in `Perf/results/round87/`.
