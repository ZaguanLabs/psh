# Round 66: validate TCP ports before endpoint I/O

Round 65 deliberately left `ztcp` port parsing unchanged. Its listener and
outbound connectors used `htons(atoi(argument))`: on this host, `65536 + port`
therefore reaches the existing `port`, not the value requested by the caller.
Negative and wider wraparound values can likewise select an unrelated valid
endpoint. See [the finding](bugs/ztcp-port-narrowing.md).

Numeric ports are now parsed as `zlong` and must be in `1..65535` before
conversion and socket creation. Invalid numeric values use the existing
`bad service name or port number` diagnostic and status 1. Service-name lookup,
default-port selection and legacy numeric prefixes are unchanged. Negative
listener ports can no longer become port 65535. Zero/nonnumeric outbound errors
retain their prior path rather than receiving an unrelated new validation
diagnostic. Descriptor parsing and all public/native structures are unaffected.

## Evidence

`Perf/check-ztcp-ports.py` tests both directions in C and C.UTF-8. Listener cases
start a shell listener, place its status in a completed-state file, then let an
independent Python client connect to the actual untruncated port. Outbound cases
reverse the roles: Python owns the actual listener and observes a connection.
The two sides therefore cannot accidentally agree on the same misread port.

| Build | Cases | Failed intended states | Control differences |
| --- | ---: | ---: | ---: |
| Preceding psh | 32 | 14 | reference |
| Pristine Zsh | 32 | 14 | 0 |
| Candidate release | 32 | 0 | 0 |
| Candidate under Memcheck | 32 | 0 | n/a |

Each direction tests the actual port, its legacy numeric-prefix form, aliases
plus 65536 and 131072, a negative-wrap alias, `-1`, zero and a nonnumeric word.
Before correction, independent endpoint connections succeed through wide
aliases in both directions and both locales. The candidate rejects those with
`1|unchanged`, no endpoint connection and no new session passed to the caller.
Other numerical errors with no before/after connection change are recorded as
controls rather than mislabeled as wrong-endpoint evidence.

Valid actual/prefix connections, zero/word errors and process results match the
preceding build exactly in ordinary runs. Round-65's 30 close/target descriptor
cases also pass the new module with no control differences. No new descriptor
or readiness behavior is being claimed here.

The first instrumented run produced only timing-sensitive fixture failures:
four valid outbound control connections arrived after its 500 ms listener
deadline under concurrent test/profiler load; its result was `0|3`, with zero
Memcheck errors. The final probe retains bounded deadlines but allows a valid
instrumented connection to arrive rather than treating profiler startup as a
fast-path requirement. The failed and passing reports are both retained.

An initial OMZ run ended in a reference session that rejected the fixture's
`zle -f keepsuffix`, after the configured candidate sequences had passed. No
framework or product change was made to accommodate that result. The isolated
rerun passes all 24 unchanged reference/candidate sessions. Both logs are
retained; this report claims a clean final gate and documents, rather than
erases, the earlier transient failure.

Full upstream validation passes 63 scripts, zero failures and three skips.
Validation is Linux x86-64 with private IPv4 loopback sockets and bounded process
deadlines. IPv6, external networking, other platform sizes and service-database
configurations are not certified. This is a correctness fix with no speedup
claim. Installed rc2 remains unchanged.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-ztcp-ports.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --reference .work/round66/before.json \
  --output .work/round66/candidate.json --require-pass
python3 Perf/check-ztcp-ports.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --memcheck \
  --output .work/round66/memcheck.json --require-pass
```

The fixture binds no fixed privileged port, contacts no external host, and does
not install anything. Source and module identities, raw connection states and
build/validation logs are retained under `Perf/results/round66`.
