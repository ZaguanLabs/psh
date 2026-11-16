# Wide ztcp descriptor arguments close or redirect live sessions

Confirmed locally in pristine Zsh 5.9.2 and psh round 64 on Linux x86-64.
Current upstream Git has not been checked and no report has been sent.

`bin_ztcp()` used `atoi()` for the `-c`, `-a` and `-d` descriptor arguments.
On this host, `4294967296 + fd` becomes `fd`. That alias can close an established
outbound session, select another listener for acceptance, or move a listener
onto an unrelated file descriptor.

## Reproducer

```sh
python3 Perf/check-ztcp-descriptors.py \
  --shell .work/round65/previous-build/Src/zsh \
  --modules .work/round65/previous-runtime/lib/zsh/5.9.2 \
  --output before.json
```

Each close case uses private loopback endpoints owned by one isolated shell.
After the attempted close, the shell writes `ALIVE` through the original
connection and performs a zero-time read on the accepted peer. References with
a wide alias report close status 0, a failed write and no peer data. The fixed
candidate rejects the alias, then preserves both successful peer operations.
An ordinary close and the `fdx` numeric-prefix form still close normally.

Target cases use a private file descriptor and distinguish the wrong redup by
inspecting its bytes. Invalid target arguments return status 1, leave `REPLY`
unchanged and permit `LIVE` to reach the file without creating a listener.

## Correction

Parse each descriptor as `zlong`, reject values outside `[0, INT_MAX]` before
conversion, and keep the legacy numeric-prefix behavior. Close, table lookup,
accept, redup and ownership paths remain otherwise unchanged. Select-only
`ztcp -a -t` additionally rejects `FD_SETSIZE` and above before `FD_SET()`;
ordinary high-descriptor acceptance does not select and remains supported.

Port arguments still have their separate legacy parsing. The network evidence
is private IPv4 loopback, not external hosts or IPv6. See
[round 65](../round65.md) for complete states and validation limits.
