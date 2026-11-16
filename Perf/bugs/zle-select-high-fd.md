# Select-only ZLE watchers exceed their descriptor sets

Confirmed locally in pristine Zsh 5.9.2 and psh round 62, both rebuilt with
`ac_cv_func_poll=no` on Linux x86-64. Current upstream Git has not been checked
and no report has been sent.

`raw_getbyte()` puts every watched descriptor into fixed-size `fd_set` objects.
Its select-only path calls `FD_SET()` and later `FD_ISSET()` without checking
`FD_SETSIZE`. `bin_zle_fd()` accepted an arbitrary nonnegative int, so a real
high descriptor reached those operations when ZLE next waited for input.

## Reproducer

```sh
python3 Perf/check-zle-highfd.py \
  --shell .work/round63/previous-build/Src/zsh \
  --modules .work/round63/previous-runtime/lib/zsh/5.9.2 \
  --backend select --output select-before.json
```

The fixture opens private `/dev/null` descriptors, obtains a pipe with a real
high descriptor, registers a handler, and waits for a result file written by
that handler at the interactive prompt. It also sends `abc` and invokes a ZLE
widget to observe the resulting buffer. Ordinary descriptor callbacks work;
the tested high-descriptor callback is not delivered in either select-only
reference. The ordinary release `poll` path passes the same high descriptor.

## Correction

When `poll` is unavailable, reject `fd >= FD_SETSIZE` during `zle -F` argument
validation, before any watcher state changes. The error includes the actual
descriptor and the build-specific select limitation. Ordinary select callbacks
and all poll-path operations are unchanged.

This covers shell-managed watcher registration. Arbitrary native mutation of
private watcher state and high terminal descriptors are separate questions.
See [round 63](../round63.md) for complete states, build identity and limits.
