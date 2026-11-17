# Round 75: bounded trim skipping, not adopted

This tests reducing round 74's repeated prompt-time trimming while preserving
its fragmented-workload memory savings. The candidate passes the exercised
correctness gates and reduces unchanged-prompt latency, but it is rejected:
chat paste is about 3% slower and several customer game kernels about 2% slower
in two alternating comparisons. Production `Src/utils.c` remains byte-identical
to the accepted round-74 source.

## Private policy trial

The existing 8 MiB/free-majority eligibility test remains. After a trim, the
candidate remembers minor/major page-fault counters and reported free arena
space. A subsequent eligible prompt can skip trimming if neither counter has
changed and free space has grown by less than 1 MiB. At most fifteen consecutive
eligible trims can be skipped; the next is forced. Failed resource queries and
builds lacking the required API use round 74's unconditional eligible trim.

This is a process-local memory-policy hint, not ownership proof or a claim that
page-fault counters completely describe allocator activity. The bounded fallback
is necessary. There is no parameter-pointer cache, native ABI change, changed
shell evaluation, timer callback, startup modification or framework workaround.
The trial adds private static bookkeeping and additional allocator/resource
queries. It was built only in `.work/round75/source`, with a matching private
GCC 15.2.0 `-O2 -g -flto` build/runtime. No core patch was promoted into the
working source tree or active installation.

## Actual call counts and memory

`Perf/trim-call-trace.c` is a Linux/glibc diagnostic preload library. It forwards
`malloc_trim()` to libc and logs each call, preserving the result and errno.
It also supports forcing `getrusage(RUSAGE_SELF)` to fail. This library is
neither installed nor used in any elapsed-time measurement.

`Perf/check-trim-cadence.py` drives the existing PTY helper, preserves sparse
results, counts calls at prompt boundaries and checks surviving string contents.
The helper now accepts explicit diagnostic environment overrides; its ordinary
invocation retains the original clean environment.

| Observed boundary | Round 74 cumulative calls | Candidate | Failed resource query |
| --- | ---: | ---: | ---: |
| First fragmented burst | 1 | 1 | 1 |
| 16 unchanged prompts | 17 | 2 | 17 |
| 64 unchanged prompts | 65 | 5 | 65 |
| Second fragmented burst | 66 | 6 | 66 |

The candidate therefore skips repeated work, forces the bounded revisit, and
trims immediately after renewed allocation activity in this fixture. Query
failure restores the existing behavior instead of disabling reclamation.
Frozen initial probe sources are retained because failure injection was added
after the first recorded before/candidate pair; the final probe reconfirms the
candidate counts.

Three uninstrumented memory samples per host cover small and large releases,
sparse survivors, fully live allocations and idle prompts. The sparse case
retains round 74's approximately 19 MiB saving: anonymous resident memory after
the first burst is 856 -> 860 KiB, and after three bursts plus thirty idle
prompts 852 -> 864 KiB. Fully live data is unchanged at 21,356 KiB after the third
cycle. All status, shape and complete survivor-content checks pass. These small
page-count differences are not a claim of additional memory savings.

## Prompt benefit versus customer regression

Both prompt timing runs use nine alternating sessions on CPU 13, with no own
builds, tests, instrumentation or profilers running. Memory sampling is disabled
in timing mode. The sparse case's unchanged-prompt median improves from
41.06 -> 29.06 microseconds, and from 42.25 -> 30.74 microseconds in the repeat.
The corresponding observed 95th percentiles improve from 48.21 -> 44.35 and
50.25 -> 44.54 microseconds. Each run has 270 idle-prompt observations per host;
these include PTY transport and scheduling, not solely the allocator call.

Repeated 20 MiB burst times are essentially flat to slightly slower: the second
sparse burst is 80.255 -> 80.309 ms, then 79.765 -> 80.405 ms. There is no new
burst-throughput improvement. Small/no-op/live controls remain in the raw data.

Two separate serial comparisons exercise all thirteen customer kernels with
nine alternating samples each and matching complete results. Selected costs:

| Customer workload | First, round 74 -> trial ms | Repeat ms |
| --- | ---: | ---: |
| Coder paste | 114.701 -> 115.466 | 114.842 -> 116.445 |
| Chat paste | 208.974 -> 214.616 | 209.078 -> 215.271 |
| Shooter (agy) | 11.822 -> 12.059 | 11.836 -> 12.081 |
| Shooter (grok) | 11.888 -> 12.195 | 11.845 -> 12.071 |

All slower and faster controls are retained. Endgame improves slightly in the
repeat and wide coder layout is roughly flat; neither cancels the repeatable
paste/game regression. These noninteractive kernels do not invoke the new
prompt policy. The observation is a whole-binary regression; no particular
compiler/code-layout explanation is asserted without evidence. The 11–12
microsecond prompt saving does not justify these primary-workload costs.

After all timing finished, matched Callgrind profiles of chat paste record
exactly 2,135,438,140 instructions on both binaries and the same complete state
hash (`f29df9212fefb9dda43261da27d6e3f2c44dcfdbb19c8821a793a63227553caf`).
Thus this observed slowdown is not accompanied by more executed instructions
in the profiled workload. Instruction equality does not establish equal cache,
branch-prediction or stall behavior, nor identify the cause. These profiles are
of the measured development pair, not the installed PGO release.

## Validation and reproduction

The private candidate passes 64 upstream scripts (zero failures, two skips), all
24 unchanged OMZ terminal sessions and all 14 native-loader observations. These
include genuine ZLE/completion/history/prompt/highlighting/async behavior; the
separate allocator PTY harness deliberately disables ZLE for synchronization.
The diagnostic C library compiles with `-Wall -Wextra -Werror`, and Python tools
pass compilation. Full results and matching binary identities are retained.
This is tested coverage, not a new package certificate or a proof covering all
possible allocation histories.

```sh
cc -O2 -g -shared -fPIC Perf/trim-call-trace.c -ldl -o /path/to/trace.so
python3 Perf/check-trim-cadence.py --shell /path/to/zsh \
  --preload /path/to/trace.so --output /path/to/calls.json
# Add --fail-rusage to exercise the conservative failure path.
python3 Perf/prompt-memory.py /path/to/round74/zsh /path/to/trial/zsh \
  --mode memory --samples 3 --output /path/to/memory.json
```

Only after all builds/tests/profilers finish, use `--mode timing --samples 9`
for the prompt timer and `Perf/customer-benchmark.py` for customer kernels.
The rejected patch, private build identities, raw results and compressed gate
logs remain under `Perf/results/round75`. No acceptance count, installation,
package, tag, release archive or repository visibility changes. Round 74 remains
the accepted memory policy.
