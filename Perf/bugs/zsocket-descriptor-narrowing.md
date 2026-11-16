# zsocket narrows accept and target descriptors

Confirmed locally in pristine Zsh 5.9.2 and psh round 63 on Linux x86-64.
Current upstream Git has not been checked and no report has been sent.

`bin_zsocket()` used `atoi()` for both the listener passed to `-a` and the target
passed to `-d`. On this host, `4294967296 + fd` becomes `fd`. A wide listenfd
therefore accepts an actual pending connection on the wrong argument, and a wide
target listener can take over an unrelated open file descriptor. A negative
`-d` value also passes the `fd <= max_zsh_fd` test and reads before `fdtable`.

## Reproducer

```sh
python3 Perf/check-zsocket-descriptors.py \
  --shell .work/round64/previous-build/Src/zsh \
  --modules .work/round64/previous-runtime/lib/zsh/5.9.2 \
  --output before.json
```

The fixture creates private Unix-domain listeners, connects a client and writes
`PING` before invoking the accept operation. A returned and successfully read
payload proves which descriptor was acted on without a polling race. The target
cases inherit a private file; after a rejected target operation `LIVE` must be
written through the original descriptor and no socket path must be created.

## Correction

Validate the parsed `zlong` before integer conversion, returning an invalid
descriptor for negative or wider-than-int values. Keep the historical numeric-
prefix behavior: the conversion deliberately does not require complete lexical
consumption. The existing invalid-argument diagnostics, zero handling, option
ordering and I/O code are otherwise unchanged.

For select-only `zsocket -a -t`, additionally reject `fd >= FD_SETSIZE` before
its `FD_SET`. Ordinary accept does not use `select` and remains supported on
high descriptors. See [round 64](../round64.md) for matrix details and limits.
