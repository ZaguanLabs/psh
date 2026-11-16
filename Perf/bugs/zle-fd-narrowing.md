# zle -F narrows watcher descriptors before validating them

Confirmed locally in pristine Zsh 5.9.2 and psh through round 61 on Linux
x86-64. Current upstream Git has not been checked and no report has been sent.

`bin_zle_fd()` converted `zstrtol()`'s `zlong` result to `int` before checking
it. With a 32-bit `int`, `4294967296 + fd` becomes `fd`. The wrapped value then
selects the real descriptor's watcher for addition, replacement, listing or
removal. This affects the descriptor API used for asynchronous prompt/plugin
callbacks, not just a numeric status display.

## Reproducer

```sh
python3 Perf/check-zle-fd.py \
  --shell .work/baseline/Src/zsh \
  --modules .work/baseline-runtime/lib/zsh/5.9.2 \
  --output pristine-zle-fd.json
```

The wide cases replace and remove descriptor 3's handler, list it through the
alias, or install a handler on descriptor zero. The candidate rejects the wide
argument with the existing `Bad file descriptor number for -F` diagnostic;
the original watcher remains listed and can be removed through descriptor 3.

## Correction

Keep the parsed result as `zlong` and reject values outside `[0, INT_MAX]`
before converting. The watcher array, native structures and dispatch code are
unchanged. The tested release uses `poll`, which supports high descriptors.
The unsafe capacity of a select-only build's fixed descriptor sets was not
recharacterized here and remains a separate audit target. See
[round 62](../round62.md) for evidence.
