# Round 40: native-library audit and formatter withdrawal

The audit finds a real regression in round 39. Its thread-locale output
shortcut is withdrawn, and the original `convfloat()` body is restored exactly.
The 27 earlier core optimizations and compiler-profile work remain. Published
rc0, the historical source archive and the active daily-driver shell are untouched;
rc1 publication and activation remain held.

The replacement candidate is `1.0.0-rc1-519928894f02`, GCC 15.2.0 PGO+LTO,
release assertions disabled, separate debug symbols. The installed executable
remains 883,312 bytes, SHA-256
`c2dbffe4df42f9adfc77a5946685804ba2c14f4e1cd731ae66a8567c12245421`.

## What the module guard missed

The source audit identifies these distinct native entry paths:

| Path | Core entry points | Evidence |
| --- | --- | --- |
| Zsh modules | `Src/module.c` dynamic loader | Round 39 guarded this path before constructors. |
| User/group services | `getpwuid`, `getpwnam`, `getpwent`, `getgrnam`, `getgrgid` in init, options, utilities, globbing and native modules | Calls can reach NSS providers; identified in source and documented by libc, without injecting a custom NSS provider here. |
| Character conversion | `wctomb()` in `getkeystring()`, conditional `iconv_open()` paths in `Src/utils.c` | Actual gconv constructor injection through ordinary Zsh Unicode conversion. |
| ELF process startup | The program interpreter's `--preload` option | Actual constructor injection without an LD_PRELOAD environment marker. |

GNU libc supports [user-supplied conversion modules](https://www.sourceware.org/glibc/manual/2.43/html_node/Generic-Conversion-Interface.html)
and [separate NSS providers](https://sourceware.org/glibc/manual/latest/html_node/Adding-another-Service-to-NSS.html).
Its printf extension interface also permits
[redefining standard conversions](https://sourceware.org/glibc/manual/2.25/html_node/Registering-New-Conversions.html).
The gconv fixture uses those interfaces without modifying Zsh's parameter table
or registering a Zsh module.

The test library implements transparent Latin-1 conversion. Its constructor
registers an `f` handler that reports the current thread/global locale context.
An ordinary script performs Unicode conversion and prints a float:

```zsh
printf '%b\n' '\u0041\u00e9'
typeset -F 4 value=1.25
print -r -- "$value"
```

With a private GCONV_PATH and Latin-1 locale, both pristine Zsh and the earlier
compiler-only rc1 print the Latin-1 characters followed by `global:C.`. Round 39
instead prints a private-thread context such as `private:ISO-8859-1`. Character
bytes still match; the float callback observes changed state. All processes
exit successfully, so startup success and ordinary output checks missed this.

Later locale changes can load the codec after shell initialization. Removing
the path marker after loading does not unregister the callback. Separately,
launching through the ELF interpreter's `--preload` loads the same observer with
no LD_PRELOAD variable. Five of the seven fixture cases fail on round 39;
ordinary-C and unused-codec controls pass. The marker file proves which cases
actually loaded the library.

Reproduce the old candidate's failure with:

```sh
python3 Perf/check-convfloat-loaders.py \
  --candidate /path/to/round39/psh --reference /path/to/pristine/zsh \
  --output .work/logs/old-native-loaders.json
```

That command returns nonzero and retains a `passed: false` report. The fixture,
configuration and marker files are private to the selected output directory;
system NSS, loader, locale and startup configuration are not edited.

## Correction and native ABI

The formatter's locale-saving, POSIX switch, libc conversion, spelling,
precision handling and restoration sequence are restored verbatim from the
pre-experiment source commit `f3eca9092d7e73a8cb920cf17b04178a8afade5e`.
The formatting registry, temporary thread locale and preload-marker policy
are removed. This fixes the observed contexts without trying to enumerate every
library that could install a formatter. Merely adding another marker would not
establish that guarantee for the whole process.

The five optional `psh_float_*` exports remain for already-built SDK clients.
Tracking always returns zero; acknowledgment, disable and loader begin/end calls
are inert. The SDK feature macro denotes API availability, not an active
optimization. An actual module binary built against the round-39 SDK loads,
runs and unloads on the replacement core. Scope indexing keeps its original
separate protocol. No public Module layout changes, and no old exports are removed.

Bundled modules no longer acknowledge formatting safety. Vendor provenance
retains both the prior patch and its withdrawal. The faulty inactive candidate's
local activation receipt is revoked, with the original saved separately. Its
earlier passing tests and performance data remain historical evidence in round 39;
they no longer justify release or activation of that build.

## A required native-library gate

`Packaging/verify.py verify` now runs the normal-user native-library fixture in
addition to the existing package and unchanged-OMZ gates. On this host it checks
seven cases across system Zsh and the candidate: ordinary C, direct preloading
in C/C.UTF-8, unused codec, startup codec, late codec, and marker clearing.
Every process's status, output bytes, stderr and actual library-load marker must
match. Non-GNU libc and missing locale coverage are classified explicitly.
ELF preloading here requires a GNU interpreter with `--preload` support.

Activation consumes evidence matching the exact candidate binary/path and
current runner/fixture source hashes. Data-only checks reject missing, failed,
wrong-binary, wrong-shell and stale-source reports; no activation command is
executed by those checks. Existing releases can refresh the evidence with
`Packaging/verify.py native-loaders --build PATH`. Both the active rc0 and earlier
safe rc1 pass this new gate. Test sources and verification/installation code now
participate in the build's source fingerprint.

The replacement passes all seven package suites, 63 upstream scripts with zero
failures/two skips, zdraw's 190 terminal/component tests and 24 unchanged OMZ
sessions. The full native float oracle again passes 1,555,200 comparisons across
five global locales and three thread-locale contexts. Exact-release Memcheck,
the retired-capability matrix, old-SDK printf handlers and all twelve broader
pristine comparisons also pass. The new loader fixture passes against both
system Zsh and the separate pristine release build.

## Performance and release state

The round-39 additional gains are withdrawn. They are not added to the current
rc1 release claims. The separate, earlier compiler-profile measurements remain
valid for their recorded checkpoint; no new core speedup is claimed here.

Fresh alternating Moonlit and thirteen-kernel customer comparisons check the
replacement against the safe pre-experiment PGO+LTO rc1. A separate Moonlit
comparison against the withdrawn build records the cost of correction. Builds,
tests and profilers finish before timing. All checked output and states match.

| Moonlit comparison | Baseline → replacement | More time |
| --- | ---: | ---: |
| Safe compiler-only rc1, five samples | 5.544 → 5.632 s | 1.6% |
| Independent safe-baseline repeat, five samples | 5.513 → 5.563 s | 0.9% |
| Withdrawn round 39, three samples | 5.117 → 5.645 s | 10.3% |

The small differences from the safe baseline are retained without a speedup
claim. Two nine-sample comparisons of all thirteen customer kernels are broadly
similar to that baseline: individual median changes range from about 1.6% less
time to 1.4% more. Coder paste reverses direction between runs; small slower
chat/shooter samples remain in the evidence. Restoring the original converter
does not establish identical compiled layout or identical timings.

The cost against the faulty candidate is real. It is accepted as correction of
an accidental behavior difference, not reclassified as an intentional script
incompatibility. [Raw evidence](results/round40/README.md) retains both outcomes,
the exact rejected-build failures and all previous round-39 measurements.

The original experiment's native oracle did not cover all ways that libc can
load code. This audit closes the demonstrated regression by restoring behavior;
it is not proof for every platform, native library or asynchronous schedule.
Native context-changing output shortcuts need stronger grounds before any
future adoption. rc1 remains unpublished and inactive.
