# Customer project benchmark coverage

The first customer is the author of these projects. Changes to psh are chosen
and assessed using their real functions and workloads. Small synthetic loops
help explain a cost and test boundaries; project measurements decide whether
the change is useful. This table tracks all twenty supplied projects without
treating their different workloads as one aggregate score.

The current suite exercises kernels from **twelve projects**. These are offline
calls to actual project libraries, with results checked and source hashes
recorded. They measure shell work without live service traffic or a displayed
terminal. They do not measure complete interactive applications or visible
frame rates. Original project sources are read only.

| Project | Current evidence or next representative workload |
| --- | --- |
| zcoder.zsh | 10,000-character bracketed paste and forced editor layout through the real input/util libraries. Existing `tests/benchmark.zsh` and `tests/benchmark_json.zsh` also provide context, payload, streaming and redraw fixtures to integrate next. |
| zchat.zsh | The same paste/layout workload through its own libraries; its input implementation differs from zcoder's. Native grapheme and actual terminal paths remain separate coverage. |
| endgame | Generate the complete 72×38 world with `ew-new`, including real creature/adventure initialization. Check map size and game state; battles, save/load and 3D client remain separate future workloads. |
| z3dfx.mario | 120 race simulation steps through the real track and engine libraries. Check elapsed simulation time and speed; retain player, AI and coin state. Rendering is excluded. |
| z3dfx | 60 active simulation steps, with its input library supplying focus state, plus the existing navigation-rebuild workload. Assert simulation time advanced and navigation covers the map. |
| z3dfx.agy | Run the same active simulation fixture against this checkout and record its independent source/state hashes. Similar code does not make it an independent kind of workload. |
| z3dfx.grok | Run the same active simulation fixture against this checkout, with independent hashes and results. |
| z3dfx.drawing | Actual `paint-flush` geometry binning from the project's 122-triangle clipping/boundary fixture; compare every tile's commands with its brute-force oracle. Raster submission and presentation are excluded. |
| zfetch | Actual URL encoding with a 2 KiB ASCII prefix, UTF-8, punctuation and newline; compare exact expected percent-encoded bytes. HTTP round trips remain a separate integration workload. |
| zjson | Parse/validate 2,000 numbers, encode 4,000 strings and repair a 100,000-byte invalid-UTF-8 value; existing library suite supplies correctness checks. |
| zhtml2md | Complete comment-heavy and prose conversion; 1 MiB comment and 100 KiB of complete HTML units. Its test driver requires the explicit child-shell override. |
| zoup | Actual cleaner on 128 authored HTML sections, plus cleaner/stream correctness suites. |
| zanimation | Existing `benchmarks/scene.zsh` and Python drivers provide deterministic CPU/GPU and presentation workloads. Add matching-host module builds before timing psh. Keep native rendering, encoding and shell orchestration costs separately attributable. |
| universe | Existing deterministic scene/frame and headless/PTY benchmarks. Launchers intentionally re-exec the private module host: selecting psh on the command line alone does not select the measured shell. Needs matching-host integration and pixel/state verification. |
| zdraw | Existing native text, layout, input and presentation fixtures. Requires its matching host/module ABI and an explicitly owned PTY for terminal work. Geometry binning in the drawing application does not stand in for a native zdraw benchmark. |
| zmdown | Existing Markdown C benchmark and module fixtures. Add representative shell/module calls with fixed source, terminal width and output verification; C-core timings alone do not show an interpreter improvement. |
| zcurl | Existing header benchmark and deterministic local HTTP fixtures. Build the module for the selected hosts and run loopback traffic explicitly; separate parsing/boundary cost from waiting for sockets. |
| zbrowser | Existing integration fixture combines fetching and conversion. Current zfetch/zhtml2md kernels cover parts; add the complete local-fixture pipeline before claiming browser gains. |
| zchatd | A Go proxy/server. Treat it as a service integration partner; its internal Go CPU time is outside psh interpreter optimization. |
| zdist | A separate compiler/runtime experiment, mainly Python/C. Use its Zsh interpreter workloads where relevant; compiled-runtime gains are a separate result. |

## Reproduce the additional project kernels

```sh
python3 Perf/customer-benchmark.py /path/to/previous/psh ./psh --cpu 2 \
  --labs /path/to/labs --challenge /path/to/challenge \
  --output .work/logs/customer-benchmarks.json
```

The driver launches the requested binaries directly, alternates order across
nine fresh-process samples, and pins the configured CPU. Loading, fixture
construction, warm-up and simulation reset precede timing. Paste reset and
binning submission preparation are part of the measured operation. Time is
reported per complete batch, with its operation count retained. Each sample
checks explicit expectations and hashes resulting state. Project sources are
hashed before and after each case; a source edit during measurement is an error.
`--case project/operation` selects individual cases without silently skipping
missing projects. Keep builds, tests and profilers idle while timing.

The shooter fixture explicitly checks that `world_time` advances. A preliminary
harness omitted the input library, leaving focus unset and exercising the
early return instead of the simulation. That was corrected before final
timings; those preliminary samples are not accepted results.

Mario's `track-build` also accumulates `track_length` across calls to
`race-reset`. The harness restores that global's fresh-launch value before
warm-up and measurement, outside timing, and checks the resulting track bounds.
The corrected final worker and timings supersede the retained preliminary
reset samples. See the [application bug reproducer](bugs/mario-track-reset.md).

The native graphics and terminal cases above are pending work. A launcher that
switches binaries, a mock renderer, or an unverified foreign module must not
be presented as an end-to-end psh benchmark. State these limits beside gains
so the remaining coverage is clear.
