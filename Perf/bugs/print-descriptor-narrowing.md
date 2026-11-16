# print -u narrows the descriptor before using it

Confirmed in the local pristine Zsh 5.9.2 release build and psh through round
60 on Linux x86-64. This is inherited behavior. Current upstream Git has not
been checked and no report has been sent.

`bin_print()` converted `zstrtol()`'s `zlong` result to `int` before `dup()`.
With a 32-bit `int`, `4294967296 + fd` becomes `fd`, so output intended for an
invalid wide descriptor is written to the live descriptor instead. Independently
inspecting the output file confirms that the write occurs, rather than merely
an incorrect diagnostic or status.

## Reproducer

Use a private temporary output file and an inherited descriptor:

```sh
python3 Perf/check-print-descriptor.py \
  --shell .work/baseline/Src/zsh --output pristine-print-fd.json
```

The wide alias cases write `SENTINEL` to that file. The fixed candidate rejects
them with status 1 and `file descriptor out of range`, leaving the file empty.
A later valid `print -u` still writes to the actual descriptor.

## Correction

Keep the parsed value as `zlong`. Reject values outside `[0, INT_MAX]` before
narrowing, then retain the existing `dup()` and `fdopen()` path. Lexical errors,
ordinary descriptors, closed but representable descriptors, coprocess output
and the undocumented `-up` spelling retain their previous behavior. See
[round 61](../round61.md) for validation and compatibility details.
