# Round 74: selective reclamation at interactive prompts

This adds a small system-allocator reclamation policy to development. On glibc
2.33 or later, and only when Zsh's optional internal allocator is disabled,
`preprompt()` queries `mallinfo2()` after existing hooks. If reported free arena
space is at least 8 MiB and at least as large as allocated arena space, it calls
`malloc_trim(1 MiB)`. The padding argument applies to the allocator's top-of-heap
policy; it is not a promise to retain exactly 1 MiB in every arena.

The policy runs at interactive prompts, not in noninteractive command loops.
It preserves errno and queues signals across the allocator operations. All
existing hooks retain their order, no shell value is discarded, and no native
structure/signature or user/framework configuration is changed. Unsupported
libc versions and internal-allocator builds keep the old path. Validation is
Linux x86-64/glibc on this host; the excluded platforms are not certified.

## Correcting the interpretation of round 73

Round 73 observed about 10 MiB retained after a local array was released while
its enclosing script was still running. A genuine prompt boundary is different:
ordinary loop/heap cleanup has occurred. A simple 20 MiB local-array burst
already returns to roughly 4 MiB RSS at the next prompt without this change.
That observation alone would not justify prompt trimming.

The useful case is fragmentation: during a 20,000-string, 1,024-byte-per-string
burst, retain one string in a global result array every 1,000 iterations. Only
20 KiB of results survive, yet the preceding build retains about 20 MiB of
anonymous pages at the prompt. The candidate releases roughly **19 MiB** of
those pages. Pristine Zsh also exhibits the retention; it is not a psh-specific
regression or evidence that the surviving objects have leaked.

`Perf/prompt-memory.py` runs a real PTY shell with ZLE disabled for explicit
command-to-prompt synchronization. Its separate memory mode reads `/proc` only
outside timing. The final three-sample matrix checks small releases, large
releases, sparse survivors, fully live allocations and no-op controls. Every
operation checks status and array structure, then the final live/sparse controls
check every surviving string's complete content. Shell exit is checked too.

Median anonymous resident memory after the first burst, in KiB:

| Case | Preceding GCC-LTO | Candidate GCC-LTO |
| --- | ---: | ---: |
| Small released array | 560 | 560 |
| Large released array | 556 | 560 |
| Large array with 20 sparse survivors | 20,176 | 852 |
| Fully live large array | 21,200 | 21,204 |

After three fragmented bursts and thirty idle prompts, the sparse case is
20,172 -> 848 KiB. The fully live allocation remains intact. A separate pristine
Zsh memory/state reference shows 20,164 -> 856 KiB in the first sparse cycle.
That reference is a debug GCC build, not a matched performance control.

## Explicit latency cost

Two clean runs use nine alternating fresh sessions per host/case on CPU 13.
Each session runs three allocation cycles followed by thirty no-op prompts.
The timing path does not sample `/proc`; builds, upstream/OMZ/native tests and
profilers are absent during these runs. Reported elapsed time includes the PTY
round trip, command evaluation and next prompt, not solely the allocator call.

| Sparse-survivor burst | First run, previous -> candidate ms | Repeat ms |
| --- | ---: | ---: |
| First allocation/release | 78.977 -> 79.166 | 78.487 -> 79.648 |
| Second allocation/release | 78.163 -> 79.312 | 77.857 -> 79.781 |
| Third allocation/release | 77.500 -> 79.093 | 76.966 -> 79.801 |

This is a measured tradeoff: around 19 MiB reclaimed for up to about 2.8 ms
additional time on the repeated 20 MiB burst in these medians (about 3.7%).
It is not a speed optimization. Idle prompts after sparse allocation cost about
0.028 -> 0.041 ms in the first run and 0.029 -> 0.042 ms in the repeat: roughly
13 microseconds extra, even when pages are already released. The threshold is
based on allocator free space, not current page residency, so it can request
trimming again at later prompts. No cooldown or unbounded tracking cache is
introduced. Fully live-array idle prompts add around 4 microseconds, reflecting
the statistics-query cost even without qualifying for trimming.

Small/released-large/fully-live operation controls are essentially flat in
these runs. Two additional serial comparisons retain all thirteen customer
kernels and nine alternating samples each. Every full state matches. Primary
coder paste is 113.139 -> 114.730 ms, then 113.347 -> 113.448 ms; chat paste is
206.901 -> 207.922 ms, then 206.088 -> 204.952 ms. Other changes are small and
mixed, with slower controls up to roughly 1.6%. Those noninteractive kernels do
not execute the new policy; they are whole-binary controls, not demonstrations
of reclamation benefit. No memory-saving claim is made for those small kernels.

The change is retained for the substantial fragmented-workload memory reduction
under the user's explicit memory-footprint objective, with the latency costs
above documented rather than hidden behind a performance aggregate.

## Compatibility and provenance

- Full upstream suite: 64 successful scripts, zero failures, two skips.
- Unchanged OMZ terminal gate: all 24 sessions match, including real ZLE,
  completion, prompt, history, syntax highlighting, async and interrupt behavior.
- Native-library gate: all 14 reference/candidate observations pass.
- Final PTY memory/content matrix and pristine reference pass.
- Both customer comparisons preserve every sample's full resulting state.

The candidate was built from an isolated source copy with GCC 15.2.0,
`-O2 -g -flto`, multibyte and PCRE, plus its matching private runtime. Historical
controls remain intact. The final source was promoted into `Src/utils.c`; only
the explanatory trial comment changed. Rebuilding that final source produces
an identical executable SHA-256, so the upstream/OMZ/native evidence still
matches the final bytes. Source and binary hashes are in `identity.json`.

The initial configure invocation used the wrong working directory and failed
before compilation; the corrected invocation built successfully. The first
prompt timing attempt overlapped the tail of upstream testing and is retained
as `prompt-timing-overlapping-tests.json`, excluded from all conclusions. The
initial memory matrix lacked the later sparse-survivor case. Frozen driver
versions preserve those earlier observations; final content validation is in
`prompt-memory-final.json`. None of these setup iterations is hidden or
presented as successful production evidence.

## Reproduction and remaining scope

```sh
python3 Perf/prompt-memory.py /path/to/preceding/zsh /path/to/candidate/zsh \
  --mode memory --samples 3 --output /path/to/memory.json
# Run only after builds, tests and profilers finish:
python3 Perf/prompt-memory.py /path/to/preceding/zsh /path/to/candidate/zsh \
  --mode timing --samples 9 --cpu 13 --output /path/to/timing.json
```

The committed patch, raw samples, frozen drivers and compressed build/gate logs
are under `Perf/results/round74`. An application that stays inside one long
command does not gain prompt-time reclamation until it returns; round 73's
within-script retention is not fixed here. Other allocators, large real-world
interactive datasets and long-duration sessions remain broader coverage targets.

The change is committed for development, not activated. The actual installed
release, stable Zsh, personal startup files, account shell and published release
artifacts remain unchanged. Packaging and `Packaging/verify.py verify` are still
required before activation of any release containing this change.
