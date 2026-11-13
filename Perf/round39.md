# Round 39: floating output without repeated global locale changes

**Historical experiment, withdrawn by [round 40](round40.md).** The native-library
audit found real callback regressions outside Zsh’s module loader. The original
converter is restored; the gains below are not part of the current candidate.

rc1 publication remains on hold. This round investigates a remaining cost in
the actual PGO+LTO release build, using the previous accepted rc1 candidate
`1.0.0-rc1-b0850020f4a1` as the performance baseline. Published rc0, its source
assets, the earlier rc1 source checkpoint and the active daily-driver shell
remain unchanged.

The new candidate is `1.0.0-rc1-a446099eaf93`, GCC 15.2.0 PGO+LTO, with assertions
disabled and separate debug symbols. Its installed executable is 883,312 bytes,
the same size as the preceding rc1 build. Executable SHA-256:
`bab62bd68c5e6cd29bf24d56b3d7ad7202c6467f004460282b1ad8463ad2e4ef`.

## Why this path

A separate Callgrind run of full Moonlit Vigil construction and output records
56,758,083,921 instructions in the preceding optimized release. `convfloat()`
accounts for 14.89% inclusive instructions; `setlocale()` accounts for 10.94%.
These are overlapping inclusive costs, not additive percentages or measured
construction-time savings. The profile includes loading and output serialization.
Its instrumented wall time is not a benchmark sample.

The original converter saves the process LC_NUMERIC name, changes LC_NUMERIC to
POSIX, formats, and restores it for every float. Even an already optimized shell
pays for libc's global locale machinery repeatedly. Arithmetic input already
has a separate locale-object optimization; this round addresses output.

## A rejected prototype and the reason for the native policy

The first prototype used an immutable C locale with `uselocale()` for queued
string conversions. It passed the initial float/state oracle but failed a real
native compatibility reproducer. GNU `register_printf_specifier()` can install
a handler for the standard `f` conversion, including calls through `sprintf()`.
That handler can observe the thread and global locale.

With LC_ALL=C.UTF-8, the old converter's callback sees `global:C.` in the
fixture's output. The unguarded prototype sees `private:C.UTF-8`. Queueing signals
and excluding FILE output are therefore insufficient. The rejected patch and
its failing observations are retained; that build is not accepted or activated.

The guarded converter permits the shortcut only while the native-module
loading policy allows it. The independent optional
`PSH_FLOAT_LOCALE_VERSION` SDK acknowledgment does not imply scope-index
awareness, or vice versa. Unknown code disables the shortcut permanently,
including after unload. Loading is suspended before constructors, with the
loader's existing signal queue. Failed loads and awareness-registry allocation
failures select the conservative path. No public Module layout or flag bit is
changed. Audited stock modules and the three bundled native projects acknowledge
the capability; Vendor patch history and original imports remain recorded.

Preload/audit markers are captured before startup code can clear them. FILE
output, unqueued native calls, existing private thread locales and platforms
without the complete locale-object API retain the original converter. Failed
locale creation or entry also falls back. Successful conversions restore the
original thread locale and errno before queued shell traps can run. Precision
rules, special values and libc's conversion algorithm are unchanged.

The policy is documented in [COMPATIBILITY.md](../COMPATIBILITY.md). Locale API
semantics are described by [uselocale(3)](https://man7.org/linux/man-pages/man3/uselocale.3.html)
and [newlocale(3)](https://man7.org/linux/man-pages/man3/newlocale.3.html).

## Characterization and compatibility

The native oracle retains the pristine converter with its copyright notice and
compares output plus surrounding state. Before the change it matches both
pristine release Zsh and the preceding accepted psh. The final candidate also
passes the full oracle: 1,555,200 comparisons across both hosts and five global
locales, including three thread-locale contexts for each global locale.

Coverage includes binary64 extremes, signed zero, subnormals, infinities, quiet
and signaling NaNs; nine precision settings through 1024 digits; all four float
flag combinations; four rounding modes; existing errno and sticky FP exceptions;
signal queue depths zero, one and three; strings, unbuffered FILE callbacks and
reentrant FILE callbacks. It compares complete output, errno, FP state, rounding,
global and thread locales, callback observations/counts and queue depth.

The final custom-printf reproducer uses a previously built scope-aware module
without the new acknowledgment. Constructor and normal calls match the old
converter. The loader policy matrix also checks independent capabilities,
unload/reload, sticky fallback after failed/unknown loads, explicit disable,
pending SIGUSR1 traps and preload markers removed before the first script-level
conversion. The compile-time API-absent build passes a five-locale comparison
against pristine Zsh.

Exact release executables pass focused Memcheck comparisons. Valgrind injects
its own LD_PRELOAD libraries, so those production runs intentionally exercise
the conservative fallback. A separate diagnostic build with
`PSH_TEST_FLOAT_ALLOW_PRELOAD` exercises the fast path under Memcheck and links
`--wrap=newlocale,--wrap=uselocale` for controlled API failures. Both failure
modes record positive injection counts and preserve oracle results. Diagnostic
binaries are explicitly distinct from the installed release and supply no timing
samples; the production package contains no preload bypass.

All seven package suites pass, including 63 passing upstream scripts with zero
failures/two skips, zdraw's 190 terminal/component tests and the exact installed
native modules. `Packaging/verify.py verify` passes, including 24 real OMZ
terminal sessions with the user's unchanged re5et/git/highlighter configuration,
completion, history, prompts, async behavior and Ctrl-C.

The twelve broader pristine-versus-candidate groups also pass: arrays, scalar
operations, searches, patterns, substitutions, emulation, arithmetic, stateful
sequences and native array/scope/math memory checks. The scope fixtures retain
their existing behavior without acknowledging the new formatting capability.

## Customer measurement

Results and controls are recorded in [the evidence directory](results/round39/README.md).
Full scene construction uses the actual project sources, alternating fresh
processes, one excluded warmup per host, five measured samples, CPU 13 and
C.UTF-8. The complete palette and material/depth output must match. Compilation,
tests and profiling finish before timing begins. Compiler training still holds
out the customer's scenes and simulations.

The preliminary guarded Moonlit trial measured 5.502268 → 5.042076 seconds,
8.36% less time than the previous optimized rc1, with identical output. That
pilot precedes the early preload-marker capture and final tested-module refresh;
it is retained separately from final measurements.

Final construction medians against the preceding PGO+LTO rc1:

| Scene | Previous → candidate | Less time |
| --- | ---: | ---: |
| Alpine Vigil | 23.807 → 22.925 s | 3.7% |
| Moonlit Vigil | 5.570 → 5.039 s | 9.5% |
| Faerie Pool | 17.776 → 17.189 s | 3.3% |
| Profile Study | 4.908 → 4.885 s | 0.5% |
| Per Arne | 12.656 → 12.566 s | 0.7% |
| Emerald Rings | 15.223 → 15.206 s | 0.1% |

The last three are essentially flat; sub-1% changes do not establish a useful
gain here. All full rendered outputs match. An independent five-sample Moonlit
repeat gives 5.551 → 5.061 seconds, 8.8% less time.

The same-executable control uses an empty shared object with no hooks or
constructors. Its LD_PRELOAD marker alone selects the legacy converter, without
disabling the parameter-scope index. With identical executable and zdraw hashes,
Moonlit measures 5.619 seconds on that fallback versus 5.102 on the ordinary
fast path: 9.2% less time, exact output. This supports attributing the main
Moonlit gain to the converter rather than only compiler layout differences.

Two independent nine-sample comparisons cover all thirteen offline customer
kernels. Their float-heavy simulation results are:

| Customer kernel | Less time, first run | Less time, repeat |
| --- | ---: | ---: |
| z3dfx.mario / mario-race | 8.0% | 10.7% |
| z3dfx / shooter-step | 10.4% | 10.4% |
| z3dfx.agy / shooter-step | 10.6% | 10.3% |
| z3dfx.grok / shooter-step | 9.7% | 9.6% |

Paste improves by roughly 1–2%; layout, Endgame and drawing binning are broadly
flat. The first coder-layout sample set is 0.5% slower and Endgame 0.1% slower;
their repeats reverse direction. Those slower samples remain in the evidence.
All checked states match. These are fixed offline kernels, not a measurement of
complete application startup, cached launches, interactive frame rate or network
throughput. No new universal speedup or cumulative rc0 speedup is inferred.

The accepted [source patch](0039-queued-float-locale.patch) adds the twenty-eighth
core optimization. No previous exported symbol is removed; the five additional
exports are the formatting policy/loader helpers. The 11,829 protected entries,
active rc0 executable, root development executable, account shell, /etc/shells,
public rc0 tag and historical rc1 archive match their recorded checkpoints.

## Limits and release state

This is host-specific coverage on Mageia x86-64, not proof for every platform,
script, asynchronous schedule or arbitrary native extension. Unacknowledged Zsh
modules intentionally lose the shortcut; merely rebuilding a module does not
grant it. An acknowledged module must disable the capability before introducing
unreviewed native observers or standard printf hooks.

The policy covers Zsh's module loader and the recorded process-injection
markers. It does not enumerate every library that libc or a dependency might
load internally. Custom core builds or native integrations outside that loader
must establish the same formatting guarantee or disable the shortcut before
running such code. This is a remaining integration boundary to audit before a
public rc1, rather than a certificate for arbitrary process-wide native hooks.

No shell activation, account-shell change, startup-file edit, release tag,
publication or archive replacement is part of this round. A future release
archive must be prepared from the new final source commit; the earlier prepared
archive remains an immutable historical checkpoint.
