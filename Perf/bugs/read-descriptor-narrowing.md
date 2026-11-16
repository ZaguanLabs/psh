# read -u narrows the descriptor before using it

Confirmed in the local pristine Zsh 5.9.2 release build and the preceding psh
candidate on Linux x86-64. This is inherited behavior. No claim is made about
the current upstream Git tip, and no report has been sent.

`bin_read()` converted `zstrtol()`'s `zlong` result to `int` before checking
it. With a 32-bit `int`, `4294967296 + fd` becomes `fd` and reads that
descriptor. `read -t` then calls `read_poll()`, which used `FD_SET` without
checking `FD_SETSIZE`. Descriptor `2147483647` indexes past the fixed set and
the process receives SIGSEGV. A plain `read -k` of that value does not crash;
the timeout path does.

## Reproducer

Use a private temporary file and an inherited descriptor. Do not point this at
application input.

```sh
python3 Perf/check-read-descriptor.py \
  --shell .work/baseline/Src/zsh \
  --output pristine-read-fd.json
```

The alias cases consume one byte from the inherited descriptor. The candidate
rejects them before reading. The same shell also faults on:

```zsh
read -u 2147483647 -t 0 -k 1
```

## Correction

Keep the parsed value as `zlong`. Reject values outside `[0, INT_MAX]` with
the new diagnostic `file descriptor out of range` and status 1. Lexical
errors keep the existing `number expected` diagnostic. For a representable
descriptor that `select` cannot store, use `poll` when it is available so a
real high descriptor still works. A select-only build returns an error before
`FD_SET`. Ordinary descriptors below `FD_SETSIZE` stay on the existing
`select` path, including its timeout arithmetic.

`print -u` has the same conversion and can write to the aliased descriptor.
That caller is separate and is not changed here.
