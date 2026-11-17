# Round 73: memory baseline and reclaimable allocator retention

Memory footprint is now an explicit development objective alongside speed and
compatibility. `AGENTS.md` records the preference. This round establishes
measurements and a concrete reclamation opportunity; it makes no production
allocator change and claims no adopted memory saving.

## Actual customer footprint

The existing fresh-process customer driver measures peak RSS using GNU time.
Five alternating samples per host cover all thirteen kernels, on CPU 13 in
C.UTF-8. All full resulting states match. The actual installed PGO+LTO release
is compared descriptively with the corrected round-71 GCC-LTO development
build; different compiler profiles and paths mean this is not a controlled
source-change performance or memory comparison.

Installed-release median peak RSS ranges from **3,652 to 5,664 KiB** across
these kernels. These small offline kernels do not represent the full interactive
applications, OMZ sessions, large real documents, GPU allocations or child-process
memory. Timing samples remain in the report, but memory conclusions are not
inferred from timing and no compiler speedup is claimed.

`Perf/memory-checkpoints.py` adds Linux `/proc/PID/smaps_rollup` and status
snapshots while a shell waits at explicit protocol checkpoints. It records RSS,
PSS, anonymous pages, private/shared pages and high-water values separately.
The wrapper sources the existing customer worker, retains its live results,
then repeats reset/operation/validation twenty times in the same process.
Every recorded full state matches across phases, samples and shells.

Three samples cover the installed release, round-71 GCC build and the available
pristine GCC debug build. The latter is a behavioral/reference observation,
not an identically configured memory baseline. Median installed-release RSS and
anonymous resident pages are:

| Kernel | RSS after initial work -> after 20 more batches, KiB | Anonymous pages, KiB |
| --- | ---: | ---: |
| Coder paste | 3,876 -> 3,876 | 460 -> 460 |
| Coder wide layout | 4,772 -> 4,892 | 1,276 -> 1,396 |
| Endgame world | 4,776 -> 4,788 | 1,308 -> 1,320 |

Paste is flat in this window; the other two retain small amounts. This does
not establish leak freedom or explain the lifetime of every allocation.
Project state remains live, so retained memory is not automatically waste.
Private/PSS totals depend on whether other processes share executable/library
pages; a lower private total for the installed binary is not itself an
allocator improvement. Phase deltas and anonymous pages are more useful here.

## A concrete reclamation opportunity

A separate synthetic burst creates a local array of 20,000 strings, each 1,024
bytes, checks its shape, then returns from the function. It repeats this twice
in the same shell. All three builds show the same basic behavior: RSS rises
from about 3.7 MiB to 24 MiB while live and settles around 14 MiB after release.
The installed release retains about 10 MiB of additional anonymous memory even
though the local array has gone out of scope. The second burst reuses memory
and does not grow without bound in this two-burst observation.

To distinguish reclaimable allocator pages from still-live shell data,
`Perf/memory-trim-probe.c` supplies a glibc-only diagnostic builtin calling
`malloc_trim(0)`. It is compiled separately against each tested shell's matching
SDK and loaded only into private test processes. It is not linked into psh,
installed, or called by an ordinary shell session.

In three samples of each of the installed and development builds, trimming
after the first release reduces RSS by **10,316 KiB** (about 10.1 MiB). For
example, installed-release RSS goes **14,216 -> 3,900 KiB**, while private
memory goes **10,788 -> 472 KiB**. The next burst still passes its checks and
trimming releases a similar amount again. Module load/unload succeeds.

This supports allocator retention as a substantial part of the observed
post-burst footprint; it is not evidence of a leak or a psh-specific regression.
It suggests investigating bounded reclamation after unusually large bursts or
at idle boundaries. Unconditional trimming after every command is not adopted:
its allocation/page-fault/latency cost has not been measured, and this glibc
mechanism is not portable. No claim is made that these synthetic savings occur
in the small customer kernels above.

## Allocation attribution, not misleading virtual-memory totals

After native measurements, Massif profiled the actual installed release's coder
wide-layout kernel twice, with ordinary malloc accounting and page accounting.
Both runs produce the same complete state. Customer source/bytecode metadata
matches the earlier before/after benchmark record at the end of profiling.

Ordinary Massif's largest recorded combined heap snapshot contains 710,226 bytes
of requested heap and 310,294 bytes of allocation overhead. This excludes Zsh's
mmap-backed arenas. The page-accounting peak is 99,532,800 bytes, but 87,478,272
bytes are a mapped locale archive, not resident private shell data. Zsh arena
mappings account for about 1.17 MB at that snapshot. The native RSS measurements
above are only a few MiB; treating all mapped address space as consumed RAM
would select the wrong target. Raw allocation trees and both profiles are retained.

## Next experiments and limits

The measured priorities are:

1. Evaluate selective reclamation after large temporary allocations, with
   subsequent allocation latency and unchanged OMZ idle/async behavior checked.
2. Investigate temporary expansion copies and small-allocation overhead using
   larger real input fixtures; preserve lazy evaluation and native ownership.
3. Give any future arithmetic plan cache an explicit memory budget and lifetime
   policy, rather than buying speed with unbounded retained state.

No runtime setting, framework feature, history size, completion behavior or
startup file is changed. There is no new activation or native ABI. Full upstream
and OMZ gates need to run for any eventual interpreter candidate; running them
against unchanged production code would not certify a future trimming policy.
The current tools pass Python compilation, Zsh syntax checking, all checkpoint
protocol checks and full customer result comparisons. The original checkpoint
sources are retained compressed because the optional trim probe was added after
the initial matrix; their hashes match that matrix's recorded identities.

## Reproduction

```sh
python3 Perf/memory-checkpoints.py \
  --shell /usr/local/psh/releases/1.0.0-rc2-b80aa8a9db05/bin/psh \
  --labs /home/stig/dev/ai/zaguan/labs --challenge /home/stig/dev/challenge \
  --case burst --case zcoder.zsh/coder-paste \
  --case zcoder.zsh/coder-wide-layout --case endgame/endgame-world \
  --samples 3 --output /path/to/memory.json
```

Repeat `--shell` to compare hosts; sample order reverses on alternating samples.
For the diagnostic trim run, use one shell, only `--case burst`, and
`--trim-module /path/to/memory_trim.so`. Exact matching-SDK compiler commands
are in `results/round73/identity.json`; do not reuse a module across SDKs.
All raw observations and failed/absent-state conditions are checked explicitly.
The tools read user-project sources but do not modify them. The active release
and its artifact history remain unchanged.
