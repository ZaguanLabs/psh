# Round 65: validate ztcp descriptors before narrowing

Round 64 corrected Unix-domain `zsocket`; `zsh/net/tcp` retained the same three
unchecked descriptor conversions. A wide `ztcp -c` argument can remove a real
outbound connection from the session table and close it, while `-a` or `-d` can
operate on another listener or target descriptor. See
[the finding](bugs/ztcp-descriptor-narrowing.md).

A private `parse_tcp_fd()` validates the full parsed `zlong` before conversion.
Each caller uses its existing invalid-argument diagnostic and status. Legacy
numeric-prefix handling is retained: `${fd}x` still addresses `fd`. Close, table
lookup, accept, duplication and session ownership paths are otherwise unchanged.
Port-number conversion is separate and was not modified.

Select-only `ztcp -a -t` additionally rejects descriptors at or above
`FD_SETSIZE` before `FD_SET`. Blocking/non-testing high-descriptor acceptance
continues on either backend and does not consume a connection on rejection.

## Evidence

`Perf/check-ztcp-descriptors.py` constructs private IPv4 loopback listeners,
outbound connections and accepted peers. After a close attempt it writes
`ALIVE` through the original outbound descriptor and performs a zero-time read
on the accepted peer. There are no asynchronous handoffs or external hosts.
Kernel-selected ephemeral ports and bounded process deadlines isolate the test.

For the old wrong-close operation the recorded state is:

```text
close:0|write:1|read:1|none
```

For the fixed rejection it is:

```text
close:1|write:0|read:0|ALIVE
```

| Build and matrix | Cases | Failed intended states | Control differences |
| --- | ---: | ---: | ---: |
| Preceding psh, close/target | 30 | 8 | reference |
| Pristine Zsh, close/target | 30 | 8 | 0 |
| Candidate, close/target | 30 | 0 | 0 |
| Candidate close/target under Memcheck | 30 | 0 | n/a |
| Preceding psh/fallback controls, select high | 12 | 4 | reference |
| Candidate, select high | 12 | 0 | 0 |
| Candidate select high under Memcheck | 12 | 0 | 0 |
| Preceding psh, poll high | 12 | 0 | reference |
| Candidate release, poll high | 12 | 0 | 0 |

The close/target matrix covers two positive aliases, a negative-wrap alias,
positive overflow, negative values, zero, nonnumeric inputs and explicit
ordinary/prefix controls in C and C.UTF-8. Target controls include `INT_MAX`'s
unchanged duplication error. Incorrect target redirection is independently
confirmed by the inherited file's final empty contents; the fixed rejection
writes `LIVE` through the original descriptor and leaves `REPLY` unchanged.

Not every prior failure closes a socket: some values already produce an ordinary
unknown-descriptor result. Those states remain separate from the observed wrong
close and redirection. The oracle fails neither quietly nor by deleting such
cases, and the resulting stdout/stderr/status are retained.

High cases use actual descriptors 1023, 1024 and 2048, with and without `-t`,
in both locales. Every ordinary accept receives `PING` and all poll states match.
Select-only `-t` at 1024/2048 now returns the explicit range error; the fallback
ordinary accept in the same fixture immediately receives the preserved `PING`.
Eight non-rejected high controls per backend match their references.

The initial close oracle preserved a sentinel incorrectly: Zsh empties the read
variable on EOF. The final fixture writes `none` for that empty result and all
before/candidate controls were rerun using that identical interpretation.
This was a fixture correction, not a changed product result.

Full upstream validation passes 63 scripts, zero failures and three skips. All
24 unchanged Oh My Zsh terminal sessions match; framework sources are unchanged.
Results are retained with the evidence. This is correctness work with no speedup
claim. Validation uses Linux x86-64, IPv4 loopback and `FD_SETSIZE=1024`. IPv6,
external networking, other operating systems and integer widths are not
certified. Installed rc2 remains unchanged.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-ztcp-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --reference .work/round65/before.json \
  --output .work/round65/candidate.json --require-pass
python3 Perf/check-ztcp-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --memcheck \
  --output .work/round65/memcheck.json --require-pass
python3 Perf/check-ztcp-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --backend poll --high --reference .work/round65/before-high.json \
  --output .work/round65/candidate-high.json --require-pass
```

For the select-only candidate, configure an isolated build with
`ac_cv_func_poll=no`, use its matching runtime module directory, and change
`--backend` to `select` with `--reference .work/round65/select-before-high.json`.
All source identities, module digests, build logs and raw results are retained
under `Perf/results/round65`.
