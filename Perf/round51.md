# Round 51: error-path compatibility and select descriptor safety

This round follows the user's request to understand the consequences of old
behavior before replacing it. It documents the script-visible effects of the
post-rc2 system-module corrections, expands error-path tests, and characterizes
timeout behavior on both compiled backends. The only new production C change
guards select's fixed-size descriptor set.

## Error contexts

`Perf/check-system-error-paths.py` runs 280 cases: sysseek, sysread, and systell
as both an arithmetic command and an arithmetic expansion, under plain
execution, if, &&, ZERR, ERR_EXIT, ERR_RETURN and always, in C and
C.UTF-8. A known negative descriptor supplies the established failure behavior
for each context. FD zero supplies a valid control. Three wide descriptors
exercise the newly rejected cases, including a value that previously aliased
a closed descriptor rather than stdin.

All 168 wide-input cases in the candidate follow the corresponding negative-FD
error path. Pristine and rc2 differ in all 168, demonstrating the intentional
behavior change. The remaining 112 controls match both references. Comparisons
include process status, diagnostic class, trap/cleanup output, variables and
file offsets. Raw ERRNO observations are retained but explicitly excluded from
the equality check: it has no parameter-error contract. Argument text in the
existing integer diagnostic is normalized; other diagnostic text is retained.
The seek probe distinguishes command-argument expansion (which still runs)
from arithmetic inside sysseek (which early rejection skips). Separate systell
forms exercise the difference between a failed arithmetic command and an
error in expansion of a command argument.

`COMPATIBILITY.md` now describes changed statuses, skipped sysseek arithmetic,
affected result/count variables, arithmetic aborts and error-control flow. It
also documents filename migration concerns from round 48. These are unreleased
corrections, not claims that arbitrary scripts remain unaffected.

Historical context: the [2003 introduction](https://www.zsh.org/mla/workers/2003/msg00616.html)
already narrowed in getposint; the [2015 addition](https://www.zsh.org/mla/workers/2015/msg01788.html)
already converted systell arguments before validation. The latter describes
the math-function interface as convenient. Neither patch explains wraparound
as an intended feature; that absence does not prove author intent.

## Timeout characterization

`Perf/probe-system-timeouts.py` records 58 cases per build: ready data, delayed
pipe input, EOF, arithmetic side effects/errors, and real SIGUSR1 interruption.
The child emits READY before calling sysread; the parent bounds every wait,
retains raw output/status/ERRNO, and kills overdue children. These are behavior
observations, not performance measurements or proof of precise timeout duration.

Pristine, rc2 and the preceding candidate match all 58 observations. Selected
negative-timeout behavior already differs between the poll and select paths:

| Timeout | Poll, with delayed input | Select, with delayed input |
| --- | --- | --- |
| `-1` | waits and reads the byte | status 2 / EINVAL |
| `-0.0001` | immediate poll, status 4 | status 2 / EINVAL |
| `-0.001` | waits and reads the byte | status 2 / EINVAL |

The instrumented poll module reports 16 timeout-conversion diagnostics; the
instrumented select module reports 10. These remain unresolved findings. The
select descriptor guard preserves the 58 timeout observations (sanitizer source
locations change and are excluded from that comparison; raw logs are retained).
No global negative-timeout policy or long-timeout cap is introduced.

Initial timeout probes omitted enabling the initially unset ERRNO parameter
and used buffered stderr for the handshake. Their reports are retained as
initial attempts. Final probes initialize ERRNO and use unbuffered pipes so
reading READY cannot prefetch and lose subsequent diagnostic bytes.

## New correction: select FD_SET bounds

The fallback attempted FD_SET on valid OS descriptors outside its representable
set. Instrumented pristine and preceding-candidate builds both report an
out-of-bounds access. The guard rejects these descriptors before constructing
the set or evaluating timeout arithmetic. See [the finding](bugs/sysread-select-fdset.md).

The independent high-FD oracle covers 18 cases. Both old select builds fail
eight; the corrected select build passes all 18. Poll builds and untimed reads
retain high-FD support. Descriptor allocation is isolated inside each harness
process. The fallback is forced in a private source copy on Linux; this is not
cross-platform certification. The test module's path and hash are checked.

The full upstream suite passes 62 scripts, with zero failures and three skips
(privileged/optional-module coverage). All 24 unchanged OMZ terminal sessions
pass. The instrumented select module also passes the V14 system-module suite.
Results are retained with the other evidence under `Perf/results/round51/`. The normal
release-profile build is reused; no installed release or startup file changes.
The complete packaging/native gate is still required before activation.

## Reproduction

```sh
python3 Perf/check-system-error-paths.py --shell /path/to/reference --output reference-errors.json
python3 Perf/check-system-error-paths.py --shell .work/release-candidate/Src/zsh --output candidate-errors.json --reference reference-errors.json --require-pass
python3 Perf/probe-system-timeouts.py --shell .work/release-candidate/Src/zsh --output timeouts.json
python3 Perf/check-sysread-select-fds.py --shell .work/release-candidate/Src/zsh --backend poll --output poll-fds.json --require-pass
```

To exercise select, undefine HAVE_POLL after the configuration headers in a
private system.c copy, compile it against matching generated headers and
errnames..o with sanitizers, and pass its containing module directory via
`--modules`. The high-FD harness then needs `--backend select` and the build's
FD_SETSIZE (default 1024). Exact compiler argument lists and source hashes are
retained; no system packages or system configuration are changed.
