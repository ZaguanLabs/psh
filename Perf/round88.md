# Round 88 — decode short words directly into the shell heap

Zsh packs words of one to three bytes into a wordcode instruction. The
executor previously unpacked these bytes into a static buffer and called
`dupstring`, which measured the length, allocated a heap string, and
copied it. The executor now allocates four bytes and writes the decoded
bytes and terminator there. Each result still has its own writable
storage. All of these sizes occupy the same aligned heap slot in the
release build. The change is confined to `ecgetstr`. Empty words and
longer words follow their existing paths.

## Customer timing

The packaging pipeline built both releases with profile-guided and
link-time optimization. Each comparison used nine alternating samples
per host on CPU 13. The second comparison reversed the starting order.
All 14 workloads produced identical application state. Twelve had lower
median times in both comparisons. The two exceptions were zcoder layout
and Mario race, which were respectively 0.06% and 0.15% slower in the
first comparison and faster in the repeat.

| Milliseconds per batch | Round 87 | Round 88 | Round 87 repeat | Round 88 repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 67.988 | 67.241 | 67.883 | 67.310 |
| zchat paste | 115.316 | 114.609 | 115.532 | 114.698 |
| Endgame world | 37.505 | 37.330 | 37.899 | 37.490 |
| zcoder wide layout | 56.999 | 56.835 | 56.989 | 56.940 |
| Mario race | 16.548 | 16.573 | 16.944 | 16.900 |

In separate five-sample comparisons, zchat paste took 114.47 ms on this
build against 249.99 ms on pristine release Zsh, and 114.41 ms against
172.86 ms on the installed rc2. Those comparisons include gains from
earlier rounds.

Callgrind attributed 640,869 calls into the string copy routine from
`ecgetstr` on round 87 during zchat paste, and 440,532 on round 88.
Eliminating 200,337 copies reduced total process instructions from
2,008,629,301 to 1,998,571,990 (0.50%). Endgame used 0.12% fewer
instructions. Five alternating hardware-counter samples also showed fewer
retired user-space instructions on all three measured workloads, including
a 0.51% reduction on zchat paste. The trained decoder shrank from 326 to
311 bytes.

## Memory

The table shows median KiB from five alternating samples per shell after
20 customer workload cycles. RSS and private memory were measured with
the workload state still live. Peak RSS is the process high-water mark.

| Workload | Retained RSS, 87 → 88 | Retained private, 87 → 88 | Anonymous, 87 → 88 | Peak RSS, 87 → 88 |
| --- | ---: | ---: | ---: | ---: |
| zchat paste | 4,032 → 4,040 | 1,444 → 1,448 | 504 → 500 | 4,388 → 4,208 |
| Endgame world | 4,888 → 4,884 | 2,304 → 2,304 | 1,356 → 1,360 | 4,888 → 4,884 |
| zcoder wide layout | 4,988 → 4,980 | 2,376 → 2,368 | 1,424 → 1,428 | 5,760 → 5,632 |

Virtual sizes matched for each pair. Retained private memory differed by
at most 8 KiB. The allocation count and aligned size are the same, so
these results support treating the footprint as comparable.

## Compatibility

The short-word fixture exercises empty strings, every packed length,
longer words, tokens, high bytes, UTF-8, redirections and a signal trap.
It checks source execution against pristine Zsh and compares NUL-delimited
output for every writer/reader pairing of pristine, round 87 and round 88.
Both read and mmap dumps are loaded after removing the source file.
All 36 compiled-file comparisons matched across C and C.UTF-8.

The upstream suite passed 64 scripts with two skips. All 24 interactive
Oh My Zsh sessions and seven paired native-loader cases passed. The
bundled zjson suite passed 14,237 checks in each locale.

Run `python3 Perf/results/round88/words.py PRISTINE ROUND87 ROUND88` to
repeat the cross-build check. The fixture and raw evidence are in
`Perf/results/round88/`.
