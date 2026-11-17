# Round 77 — glibc allocation reuse in repeated layout work

Round 76 recorded about 116 KiB of anonymous resident growth between the first
and twentieth coder wide-layout cycles. This round tests how much of that
footprint responds to glibc's per-thread allocation cache (tcache), and what the
change costs on the user's projects.

The release and development binaries each served as their own control. A
private launcher set `glibc.malloc.tcache_count` before exec. The comparison
launcher used the default allocator settings. A small C probe under glibc
2.42 allocated 64 blocks of 256 bytes, freed every other block, then sampled
`mallinfo2().uordblks`. Reported allocated bytes fell by 6,800 under the
default, 8,432 with a one-entry limit, and 8,704 with zero entries. Explicitly
selecting seven reproduced the default. This independently checks that the
allocator responded to the setting. Shell measurements include all effects of
the allocation policy, including fragmentation and reuse across size classes.

## Customer memory and speed

Each 20-cycle comparison used three fresh processes per setting and alternated
launch order. The checkpoint driver verified the complete output after the
initial workload and at cycles 1, 5 and 20. The table shows median anonymous
resident memory at cycle 20, in KiB. Each arrow compares the same binary with
its own control.

| Workload | Installed release, default → zero | Round 76, default → zero | Round 76, default → one |
| --- | ---: | ---: | ---: |
| Coder wide layout | 1,396 → 1,304 | 1,396 → 1,304 | 1,396 → 1,348 |
| Chat wide layout | 1,384 → 1,308 | 1,384 → 1,308 | 1,388 → 1,332 |
| Endgame | 1,320 → 1,316 | 1,320 → 1,316 | 1,320 → 1,328 |
| Coder ASCII layout | 932 → 900 | 912 → 904 | 916 → 940 |

Peak and retained quantities differ. On round 76, the median coder wide-layout
RSS high-water mark at the last checkpoint was 5,360 KiB with the default and
5,372 KiB with zero entries. Retained private memory fell from 2,312 to
2,216 KiB. Virtual size went from 92,568 to 92,540 KiB. Each pair uses one binary. The release and development builds differ in the
amount of file-backed memory counted as private.

Each candidate had a separate timing run on CPU 13 with seven alternating
samples of all thirteen workloads. Complete result states matched. With zero
entries, median coder wide-layout batch time increased from 66.05 to 69.82 ms,
chat wide layout from 65.66 to 69.73 ms, and drawing from 12.79 to 14.42 ms.
With one entry those comparisons were 66.49 to 66.78 ms, 66.20 to 66.85 ms,
and 12.93 to 13.07 ms. Endgame went from 45.96 to 45.78 ms with one entry.
The two comparisons each have their own default samples.

## Longer sessions

The checkpoint driver now accepts `--cycles N`. It checks the complete live
result at cycles 1, 5, each multiple of 20, and the final cycle, when reached.
The default still exercises twenty cycles. A separate default invocation
confirmed the original checkpoint sequence. The 101-cycle comparison used
three processes per mode on round 76, reversing the three-host order on the
middle sample. All checkpoint outputs matched.

| Coder wide layout, anonymous KiB | Cycle 1 | Cycle 20 | Cycle 40 | Cycle 60 | Cycle 80 | Cycle 101 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Default | 1,276 | 1,392 | 1,392 | 1,392 | 1,392 | 1,392 |
| Zero entries | 1,264 | 1,328 | 1,328 | 1,260 | 1,312 | 1,348 |
| One entry | 1,276 | 1,348 | 1,352 | 1,356 | 1,356 | 1,356 |

Default anonymous residency had already plateaued at the twentieth cycle.
Zero entries fluctuated with reuse. Its observed saving fell to 44 KiB at
cycle 101, compared with 36 KiB for one entry. The short comparison and the
extended driver use slightly different shell harnesses, so compare settings
within each table. A brief default-protocol smoke check shared the development
binary during the last long-run sample. This can affect accounting for shared
file pages. The table reports anonymous residency.

## Decision

Keep the default allocator policy. In a repeat with nine alternating samples
and the initial host order reversed, zero entries again cost about 6–7% on
the wide layouts and 13% on drawing. One entry cost about 0.6–0.9% on those
three workloads. It saved 36 KiB at the end of the longer coder session and
increased anonymous residency in the ASCII control at twenty cycles. That
workload dependence and the small absolute saving do not justify changing
allocator behavior throughout the shell and its child processes.

The development change is the longer checkpoint protocol and its diagnostic
evidence. The suite compared application states across runs. Interpreter,
packaging and interactive compatibility gates apply when changing the shell
or preparing a build for activation.

## Reproduction

The compressed JSON under `Perf/results/round77/` contains the individual
samples, source identities and state hashes. `hosts.json` records the exact
private launchers and underlying binary hashes. To repeat the comparison,
create the launchers from those strings and make them executable. The short
memory series used the checkpoint driver from commit `233b890`. For the
extended run with the current driver:

```sh
python3 Perf/memory-checkpoints.py \
  --shell .work/round77/dev-default --shell .work/round77/dev-uncached \
  --shell .work/round77/dev-one --case zcoder.zsh/coder-wide-layout \
  --cycles 101 --samples 3 --labs /home/stig/dev/ai/zaguan/labs \
  --challenge /home/stig/dev/challenge --output /tmp/psh-101.json
```

Build the allocator accounting probe with
`cc -O2 -Wall -Wextra -Werror Perf/tcache-probe.c -o /tmp/psh-tcache-probe`.
The program prints the change in allocated bytes. Run it in fresh processes
with the default environment and the three `GLIBC_TUNABLES` values listed above.
