# Round 50: checked systell conversion, including floating-point arguments

The next descriptor boundary is the `systell()` math function in `zsh/system`.
It narrowed integers and converted floating values before testing negativity.
This allowed integer aliases and undefined floating-to-integer conversions.
The fix validates the original value, retaining fractional truncation and the
existing arithmetic error path. See [the finding](bugs/systell-conversion.md).

## Evidence

| Build | Failed checks / 218 | Compatibility controls / 134 |
| --- | --- | --- |
| Pristine Zsh 5.9.2 | 16 | Exact match |
| Installed rc2 | 16 | Exact match |
| Round-49 candidate | 16 | Exact match |
| Instrumented round-49 system module | 76 | Exact match |
| Round-50 candidate | 0 | Exact match |
| Instrumented round-50 system module | 0 | Exact match |

The 218 cases comprise 84 rejection cases and 134 controls. Of the 76 failures
in the instrumented preceding module, 60 produce sanitizer diagnostics and 16
are integer aliases. Inputs include NaN, infinities, upper/lower bounds,
fractions, and expression side effects. Tests run under ordinary arithmetic,
FORCE_FLOAT and C_PRECEDENCES in two locales. Python checks that both shared
file positions remain unchanged. Pipe and closed-FD cases retain `-1` results.
Normal controls compare complete outputs and exit statuses with all references.

Instrumented builds use `-O1 -g -fsanitize=undefined,float-cast-overflow` on
`system.c`, linked with the matching generated `errnames..o`. The shell itself
is not instrumented. The first attempt omitted that object, allowing fallback
to the regular module; its result is retained as an unsuccessful setup attempt.
The corrected harness prevents fallback and verifies the loaded module path.
The preceding source and module are retained privately before rebuilding.

The normal candidate uses the release-profile build. The V14 module regression
passes; round 49's 90 integer rejection checks and 114 compatibility controls
also pass unchanged. The full upstream suite passes 62 scripts with zero
failures and three skips (privileged/optional-module coverage); all 24 unchanged
OMZ terminal sessions pass. Evidence is retained under `Perf/results/round50/`.
No performance improvement is claimed.

## Timeout findings retained separately

Bounded pipe probes show `sysread -t 4294967296` returning timeout status 4
before input arrives, while a one-second control reads the supplied byte.
Pristine, rc2 and the candidate behave alike. Source inspection explains this:
the seconds value is narrowed before multiplication by 1000. The instrumented
candidate also diagnoses signed multiplication overflow at `-t 2147484` and
floating-to-integer overflow at `-t 1e300`.

These timeout observations are not benchmarks or an exhaustive timing oracle.
The probe keeps an empty pipe's writer open briefly before providing data, and
kills children on excessive delay. Its source and observations are retained
with the evidence. Timeout handling is unchanged in this patch: a future fix
must characterize negative-timeout behavior, long finite waits, interruption,
and the alternate select implementation before choosing rejection, clamping,
or chunked waiting. `zselect`'s descriptor narrowing is another separate lead.

## Reproduction

```sh
python3 Perf/check-systell.py --shell /path/to/reference --output reference.json
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-systell.py --shell .work/release-candidate/Src/zsh --output candidate.json --reference reference.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output ohmyzsh.json
```

For instrumented reproduction after building, link `Src/Modules/system.c` with
`.work/release-candidate/Src/Modules/errnames..o` into a private `zsh/system.so`,
using the generated and source include directories, `-DHAVE_CONFIG_H -DMODULE`,
`-shared -fPIC -O1 -g -fsanitize=undefined,float-cast-overflow`. Pass its parent
module directory via `--modules` to the oracle. Build commands are retained in
the evidence. Standalone autoload functions must already be staged privately
with `make -C .work/release-candidate install.fns` for the OMZ gate.

Installed rc2, system Zsh, startup configuration and account login shells remain
untouched. Full isolated packaging/native validation is required before any
activation; this candidate is neither installed nor published.
