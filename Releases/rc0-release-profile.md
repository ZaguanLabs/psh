# Private rc0 iteration: release build profile

The project version remains **psh 1.0.0-rc0 (zsh 5.9.2)** throughout private
validation. This report describes build `1.0.0-rc0-1d099d21957d`; its
`psh-config --build-id` returns `1d099d21957d`. This iteration adds no Zsh language optimization and
changes no Zsh C implementation or public structure definition.

The subsequent [array-bound optimization](../Perf/round22.md) records the newer
private daily-driver build and its validation, using this same release profile.

The [arithmetic operand-pop iteration](../Perf/round23.md) records the next
private build with the same profile and unchanged rc0 version.

The original `v1.0.0-rc0` tag, draft and source archive remain an initial
checkpoint. Work continues on `main`, identified by source commit and build
digest. Previous installed releases and source artifacts are retained. This
iteration is not a new project version or a public release.

## Configuration and debugger symbols

Daily-driver packaging now defaults to `--profile release`, using upstream's
`--disable-zsh-debug`. `--profile debug` retains assertions for development and
produces a distinct build digest. The separate `Perf/build.py` development
builds retain their assertion-enabled configuration.

Both package profiles use `-O2 -g` and explicit `LDFLAGS=-g`. Upstream configure
otherwise defaults a non-debug build to stripping at link time; our first
trial caught this because GDB could not resolve a source line. That trial was
not activated. Keeping linker symbols permits the existing symbol-splitting
workflow independently of Zsh assertions. The installed stripped executable's
allocated sections and dynamic exports match its unstripped build, and GDB
resolves `zsh_main` through the separate debugger file.

| File or image measurement | Original installed rc0 | Release-profile rc0 |
| --- | ---: | ---: |
| Executable bytes | 891,544 | 846,488 |
| Separate debug file bytes | 1,985,664 | 1,927,816 |
| Code/data/BSS bytes reported by `size` | 960,817 | 915,439 |

System Zsh's executable is 905,856 bytes on this host. These are file/image
measurements, not process RSS. The existing non-PIE configuration remains;
this iteration does not adopt all distribution compiler flags.

## Compatibility checks

The old extra terminal assertion diagnostic is absent. All **60 terminal
runs** (five TERM states, four load/unload scenarios, three interpreters)
match the pristine release build and installed system Zsh, including unset,
empty and invalid TERM values. No output is filtered or diagnostic suppressed
in the test. Both core and installed SDK configurations have DEBUG disabled.
The normal installation verifier now repeats the 40 installed/system terminal
runs automatically, making this an activation check for future release builds.

DEBUG changes the set of exported helpers: `dputs` and `queue_in` disappear,
just as in pristine release Zsh. For GCC and Clang respectively, all **32 public
declaration files and 1,053 exported names/types match the pristine release
build**. `Src/zsh.h` is unchanged. Native modules built for a prior debug SDK
and using those debug exports must be rebuilt against the matching SDK; an
unchanged Zsh version string alone never certified binary interchangeability.
All six bundled packages have been tested against the new installed shell.

- Matched GCC pristine build and exact installed psh: **63 upstream scripts
  pass each**, two expected skips, zero failures.
- Matched Clang pristine and psh builds: **63 upstream scripts pass each**,
  two expected skips, zero failures.
- Installed GCC differential checks: **704,585 scalar**, **110,100 arithmetic**,
  **5,192 array**, **193,236 search**, **159,600 pattern** and **2,640 substitution**
  cases match. Custom accessor and PTY completion checks match too.
- GCC and Clang each pass **200,832 native numeric scenarios under Memcheck**
  across C, C.UTF-8 and French Belgian UTF-8; zero reported memory errors,
  with leak checking disabled. Additional Clang comparisons cover **66,060
  arithmetic**, **281,834 scalar** and **63,840 pattern** cases.
- All **seven package suites** pass, including **190 zdraw tests**, native
  Markdown rendering and zcurl HTTP/TLS/WebSocket and signal tests.
- **24 customer kernel/locale cases** match pristine, and five additional
  original Endgame/shooter suites pass with matching output/status.
- Exact installed component paths, change-gutter rendering, inherited FPATH,
  invocation option states, version identity and private login startup pass.

The first trial also failed one zcurl shared-poll signal/reentry expectation.
Its original failure is retained. The unchanged original installed rc0 control
and final candidate each pass the full zcurl suite; three additional alternating
PTY runs per build also pass, using immutable installed shells and modules.
The original failure's cause was not isolated; it is not silently discarded or
claimed as fixed by the linker setting. No vendored source or test was changed.
General asynchronous signal schedules remain outside a universal guarantee.

[Recorded results](results/rc0-release-profile/) include commands, binary/module
hashes, exact samples, fixture hashes, both compiler receipts and the initial
failures. These are bounded compatibility evidence; the experimental status
and [compatibility policy](../COMPATIBILITY.md) still apply.

## Customer performance comparison

Nine alternating fresh-process samples, CPU 2, C.UTF-8, on the existing Mageia
x86-64/GCC 15.2.0 host. Own builds, profilers and test suites were idle during
these measurements. The comparison is the original installed psh debug profile
versus the new installed release profile, with the same nineteen accepted
language optimizations. It is not a fresh comparison against system Zsh.
Loading/construction/warm-up occur before each warm timer; every checked final
state matches. These offline kernels do not cover full interactive sessions,
terminal rendering or live network service latency.

| Customer batch | Original rc0 ms | Release profile ms | Ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 117.274 | 116.448 | 1.007x |
| zcoder.zsh/coder-layout | 5.795 | 5.733 | 1.011x |
| zcoder.zsh/coder-wide-layout | 97.556 | 93.994 | 1.038x |
| zchat.zsh/chat-paste | 213.582 | 215.224 | 0.992x |
| zchat.zsh/chat-layout | 5.794 | 5.682 | 1.020x |
| zchat.zsh/chat-wide-layout | 97.937 | 94.482 | 1.037x |
| endgame/endgame-world | 45.225 | 45.398 | 0.996x |
| z3dfx.mario/mario-race | 20.535 | 20.186 | 1.017x |
| z3dfx/shooter-step | 11.976 | 11.865 | 1.009x |
| z3dfx.agy/shooter-step | 11.982 | 11.899 | 1.007x |
| z3dfx.grok/shooter-step | 11.918 | 11.819 | 1.008x |
| zfetch/fetch-encode | 14.154 | 13.179 | 1.074x |
| z3dfx.drawing/drawing-binning | 14.699 | 14.203 | 1.035x |

Library controls, milliseconds per call, also nine alternating samples:

| Operation | Original rc0 ms | Release profile ms | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 100.555 | 99.657 | 1.009x |
| zjson-encode-array | 215.836 | 214.789 | 1.005x |
| zjson | 96.678 | 95.010 | 1.018x |
| navigation | 2.007 | 2.041 | 0.983x |

The wide editor layouts and URL-encoding batch improve in this run. Paste,
Endgame and navigation include slower results. Small differences in this one
paired run are not established repeatable effects; no aggregate speedup or
application-startup claim is made. All samples and slower controls are retained.

## Installation and source artifacts

The validated release profile is active through `/usr/local/bin/psh`.
All **11,828 protected Zsh/startup entries**, `/etc/shells`, the account login
shell and the previous installed rc0 release remain unchanged. Existing shells
keep their original release paths; start a new process to use this build.

Use [the private package workflow](../Packaging/README.md) to reproduce the
installation. Separate source artifacts for this iteration are created with
`Packaging/source-release.py --ref HEAD --output <fresh-directory>`, preserving
the earlier archive. The source checker builds outside Git, tests the
assertion-enabled development core, and independently stages both release and
debug packages with distinct IDs and verified DEBUG settings. It does not
install those disposable rebuilds. Its report belongs beside the exact archive.
