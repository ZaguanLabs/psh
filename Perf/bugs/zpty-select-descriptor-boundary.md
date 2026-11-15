# zpty nonblocking reads exceed select's fixed descriptor set

Confirmed in the local pristine Zsh 5.9.2 release source and the preceding
psh development module. This is not a claim about the current upstream Git tip.

`ptyread()` uses `FD_SET(cmd->fd, &foofd)` without checking the descriptor against
`FD_SETSIZE`. A valid PTY master can exceed that bound when enough files are
already open. On Linux x86-64, a descriptor of 1024 indexes past the 16-element
`__fd_mask` array; larger descriptors continue past it. This is memory access
outside a stack object, not an ordinary unsupported-descriptor error.

## Reproducer and observation

The maintained reproducer is `Perf/check-zpty-readiness.py`. It opens private
`/dev/null` descriptors, passes them to a fresh shell, creates a PTY, and runs
`zpty -rt`. The child waits on input so the no-data case is deterministic. No
limits, configuration files, installed binaries or account settings are changed.
Use a matching instrumented module to stop at the first invalid access:

```sh
UBSAN_OPTIONS=halt_on_error=1:exitcode=86 \
python3 Perf/check-zpty-readiness.py \
  --shell .work/baseline/Src/zsh \
  --modules .work/round56/pristine-ubsan \
  --backend legacy --counts 1020 --output pristine-zpty.json
```

The harness verifies the loaded module path/hash and actual descriptor. The
private build commands are retained under `Perf/results/round56`.

For the pristine module, descriptor 1024 gives:

```
Src/Modules/zpty.c:611:6: runtime error: index 16 out of bounds for type '__fd_mask [16]'
```

The initial single-case probe also reproduced at descriptor 1054. In the final
200-case matrix, both pristine and preceding psh instrumented modules fail all
108 nonblocking-read cases at descriptors 1024, 1025 and 2048. All other 92
cases pass, including blocking reads at those high descriptors. The ordinary
pristine release module matches all 80 below-boundary controls.

## Candidate

Use `poll()` where available, with zero timeout and the same existing read,
pattern and fallback logic. This supports the actual PTY descriptor without a
fixed descriptor set. Builds with only select reject an oversized descriptor
before consuming buffered output, compiling a pattern or assigning a result.
They return status 1 with a range diagnostic. Reads without `-t` still work
with high descriptors. See [round 56](../round56.md) for compatibility evidence
and validation limits. This finding has not been sent or published by the agent.
