# Round 86 — clear reused arenas up to their previous extent

Zcoder's 10,000-byte paste cleared 25 MiB of temporary arena storage, down
from 313 MiB with round 85. Paste elapsed time fell 2.4–2.7% in two
comparisons. The 64 KiB transcript fixture retained 12 KiB less private
memory after 100 writes. The gain in resident footprint is much smaller
than the reduction in repeated stores.

## Which bytes need clearing

The shell retains at most two 16 KiB anonymous mappings. On a fresh list
the allocator knows that the entire payload starts at zero. Each arena's
`used` field gives the end of the allocated prefix, but resetting a heap
can lower that field while leaving previously used bytes behind.

Round 86 remembers the largest payload extent seen before a rewind on the
current list. At retirement it clears the header and the larger of the
current arena extent and that saved bound, capped at the mapping size.
The list-wide bound can overestimate how far a particular arena was used.
Restoring or switching heap lists, or resizing an existing allocation,
selects full clearing. A fresh list starts with a zero bound. The state
takes one internal `size_t` under the existing signal queue. Ordinary
allocation and the public heap layout keep their previous implementation.

A separate diagnostic build inspected the whole 16 KiB mapping after each
clear and before adding it to the spare list. It also counted the bytes
passed to `memset`. The diagnostic reads touch pages, so the resident and
timing results below come from separate, uninstrumented binaries.

| Workload | Retained arenas checked | Partial clears | Round 85 full-clear bytes | Round 86 cleared bytes |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 20,023 | 20,023 | 328,056,832 | 26,237,976 |
| zchat paste | 40,037 | 20,025 | 655,966,208 | 345,092,904 |

The diagnostic then ran all fourteen customer kernels. Every observed retired
mapping compared equal to zero and each final project state matched round 85. The native probe
also wrote 12,000 bytes, rewound the heap, used another 128 bytes, popped
the scope and checked the surviving prefix. The diagnostic verified the
retired mapping after that sequence.

## Time on customer projects

Both GCC 15.2 release builds used profile-guided and link-time optimization
with the packaging training recipe. The fourteen real project kernels were
held out of training. Each comparison used nine alternating samples per host
on CPU 13 in C.UTF-8, and the repeat started with the other host. All
resulting states matched. These are median elapsed milliseconds per batch.

| Workload | Round 85 | Round 86 | Round 85 repeat | Round 86 repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 71.31 | 69.61 | 71.57 | 69.67 |
| zchat paste | 120.54 | 118.08 | 119.55 | 117.40 |
| zcoder skill folding | 8.96 | 8.62 | 8.96 | 8.62 |
| zfetch encode | 11.25 | 11.30 | 11.23 | 11.34 |
| Drawing binning | 11.31 | 11.40 | 11.31 | 11.38 |

The repeat showed about 1% more time for zfetch and 0.6% more for drawing.
The largest consistent saving was 3.7–3.8% on skill folding. Separate
five-sample comparisons put zchat paste at 170.70 ms on the installed rc2
versus 117.90 ms on this build, and 232.91 ms on pristine release Zsh
versus 117.82 ms. These two comparisons include earlier rounds.

A separate LTO build without profile guidance confirmed the direction.
Zcoder paste took 79.13 and 79.21 ms versus 81.44 and 81.75 ms with
round 85. Zchat paste took 135.97 and 135.86 ms versus 138.67 and
139.08 ms. Callgrind on the trained builds counted 2.639 billion user
instructions for the round 85 zchat batch and 2.026 billion for round 86.

## Resident and peak memory

Linux smaps and process status were sampled with the verified application
result live. Each cell gives median KiB for round 85 followed by round 86.
Five samples per binary alternated in both the 20-cycle customer runs and
the 100-cycle transcript run.

| Workload | Anonymous | Private | RSS | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: | ---: |
| zchat paste | 504 → 500 | 1,448 → 1,440 | 4,028 → 4,048 | 4,180 → 4,180 | 91,664 → 91,664 |
| zcoder paste | 504 → 492 | 1,448 → 1,448 | 4,052 → 4,044 | 4,052 → 4,044 | 91,664 → 91,664 |
| zcoder skill folding | 428 → 416 | 1,372 → 1,360 | 4,012 → 3,972 | 4,012 → 3,972 | 91,664 → 91,664 |
| Endgame world | 1,360 → 1,360 | 2,300 → 2,300 | 4,920 → 4,912 | 4,920 → 4,912 | 92,472 → 92,472 |
| 64 KiB zcoder transcript | 1,120 → 1,108 | 2,060 → 2,048 | 4,660 → 4,648 | 6,176 → 6,148 | 92,296 → 92,296 |

At 200 nested calls, private growth from startup fell from 2,024 to
2,008 KiB at maximum depth and from 1,236 to 1,220 KiB after return.
In a separate five-sample page-fault comparison, zchat paste went from
380 to 371 minor faults and zcoder paste from 280 to 274.

## Other experiments

Each trial started independently from round 85 and retained the two-spare
limit. Each ran both nine-sample comparisons across all fourteen kernels.

- **Discard pages on retirement.** Linux `madvise(MADV_DONTNEED)` reduced
  private memory on zchat paste by 36 KiB at cycle 20. Across five fresh
  processes the median minor-fault count rose from 382 to 40,420. Paste
  took 16.3–16.5% more time, and skill folding took 21.4–21.6% more.
- **Scan 4 KiB blocks.** Clearing the first block and checking the rest
  for zero saved 12–40 KiB of anonymous memory across four 20-cycle
  workloads. Zchat paste took 0.4–0.7% more time. The accepted variant
  avoids reading discarded payloads and improved both paste timings.
- **Track each allocation.** Updating a scope-wide maximum on every
  allocation gave nearly the same clearing volumes as recording rewinds.
  Drawing took 8.9–9.6% more time, and Endgame took 5.5–6.0% more.
  This comparison motivated keeping the bookkeeping off the ordinary
  allocation path.

## Verification and reproduction

All four trained experiments passed the upstream suite, with 64 scripts
passing and two skipped per build. Each completed 24 interactive Oh My
Zsh sessions on the user's configured stack and passed all seven paired
native-loader cases. The two extent-tracking builds passed the 14,237
bundled zjson checks in each of C and C.UTF-8. The scope and scalar-append
fixtures matched pristine output. Native scope probes passed directly and
under Memcheck. The real zchat paste and zcoder skill-folding workloads
also completed under Memcheck on each trial with matching results and
zero reported errors. GCC produced identical optimized
allocator assembly to round 85 for both the non-mmap and instrumented
Valgrind paths.

The experiment patches, build identities, profiles and raw samples are in
`Perf/results/round86/`. The directories are `drop` for page discard,
`scan` for block scanning, `bound` for per-allocation tracking and
`rewind` for the accepted change. Each patch applies independently to
`fcbe9ca`. The diagnostic patches apply on top of their respective
experiment. They check the retired mapping before insertion into the
spare list and report the number and total size of clears.

Use `Perf/customer-benchmark.py` for elapsed timing,
`Perf/memory-checkpoints.py` for live memory and
`python3 Perf/results/round86/faults.py --shell BASE --shell CANDIDATE
--labs LABS --output faults.json` for whole-process page faults. The
trained candidates used isolated development runtimes. Activation is
a separate packaging operation.
