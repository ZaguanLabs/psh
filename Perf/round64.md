# Round 64: validate zsocket descriptors before conversion

The descriptor audit reaches `zsh/net/socket`. Its `atoi()` callers narrowed
before either bounds validation or I/O. On this host, `4294967296 + listener`
accepts a real pending connection on `listener`, and the corresponding wide
`-d` value moves a listener onto an unrelated open file descriptor. Negative
`-d` values also reach `fdtable[fd]` before its empty-table check. See
[the finding](bugs/zsocket-descriptor-narrowing.md).

A private `parse_socket_fd()` now keeps the `zlong` result and rejects values
outside `[0, INT_MAX]` before conversion. Both callers retain their existing
invalid-argument diagnostics and status. It deliberately retains `atoi()`'s
numeric-prefix acceptance, so `3x` still selects descriptor 3. Zero and
nonnumeric errors, option order and ordinary I/O code are unchanged.

Select-only `zsocket -a -t` now also checks `FD_SETSIZE` before its `FD_SET`.
Larger descriptors are rejected before consuming a connection. Without `-t`,
ordinary acceptance still works on high descriptors in both backends. Native
layouts and interfaces are unchanged.

## Evidence

`Perf/check-zsocket-descriptors.py` uses private Unix-domain sockets and files.
For accept cases, a client connects and writes `PING` before the shell accepts;
the accepted descriptor must read that payload. Invalid calls must leave
`REPLY` unchanged. For targets, the parent independently reads a file inherited
as the target; rejection must permit the shell to write `LIVE` to it and must
not create a socket path first.

| Build and matrix | Cases | Failed intended states | Control differences |
| --- | ---: | ---: | ---: |
| Preceding psh, ordinary/range | 56 | 22 | reference |
| Pristine Zsh, ordinary/range | 56 | 22 | 0 |
| Candidate, ordinary/range | 56 | 0 | 0 |
| Candidate ordinary under Memcheck | 56 | 0 | n/a |
| Preceding psh, high descriptors and poll | 12 | 0 | reference |
| Candidate, high descriptors and poll | 12 | 0 | 0 |
| Preceding psh, high descriptors and select | 12 | 4 | reference |
| Candidate, high descriptors and select | 12 | 0 | 0 |
| Candidate select/high under Memcheck | 12 | 0 | n/a |

The ordinary/range matrix covers three live-descriptor aliases, positive int
overflow, a negative descriptor, zero and lexical controls in two locales.
Accept also runs with `-t`; target controls include the legacy
numeric-prefix form and `INT_MAX`'s unchanged duplication failure. Not every
before failure is unintended I/O: some are wrong errors or expected states from
the intended stricter range handling. The failing before states are retained,
not reinterpreted as universal evidence of memory corruption.

The high matrix uses actual descriptors 1023, 1024 and 2048, with and without
`-t`, in two locales. Poll behavior has no differences. Ordinary select accept
matches at all three descriptors. Only select-only `-t` at and above 1024 changes
to an explicit `file descriptor out of range for select` rejection. Its pending
connection and result state are preserved.

`Test/V15socket.ztst` adds lasting local-socket coverage. A wide accept argument
cannot consume the pending connection; the subsequent real accept succeeds and
reads `hello`. A wide target leaves the inherited descriptor writable and yields
`file:intact`, while a negative target is rejected without creating a listener.
The isolated V15 run passes both tests. Initial test-file failures came from
placing a blank line inside a single ZTST code chunk, which separates chunks;
the two scenarios now have their own proper test blocks.

Full upstream validation passes 63 scripts, zero failures and three skips. All
24 unchanged Oh My Zsh terminal sessions match; framework sources are unchanged.
Results are retained with the evidence. This is correctness work with no speedup
claim. Validation uses Linux x86-64 and `FD_SETSIZE=1024`; other platforms and
type widths are not certified. Networking coverage is local Unix-domain sockets,
not TCP/IPv6. Installed rc2 remains unchanged.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-zsocket-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --reference .work/round64/before.json \
  --output .work/round64/candidate.json --require-pass
python3 Perf/check-zsocket-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --memcheck \
  --output .work/round64/memcheck.json --require-pass
python3 Perf/check-zsocket-descriptors.py \
  --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --backend poll --high --reference .work/round64/before-high.json \
  --output .work/round64/candidate-high.json --require-pass
```

For the select-only candidate, configure an isolated build with
`ac_cv_func_poll=no`, use its matching runtime module directory, and replace
`poll`/the ordinary release paths with `select`/those paths. Source identities,
module digests, build commands and raw states are retained under
`Perf/results/round64`.
