# Round 63: guard select-only ZLE watchers

Round 62 left the select-only high-descriptor path explicit. `raw_getbyte()`
used `FD_SET()` and later `FD_ISSET()` for every watcher without checking the
fixed descriptor-set capacity. On a build with `poll` disabled, a valid high
descriptor could therefore access outside its `fd_set`.

`Perf/check-zle-highfd.py` exercises this at a genuine interactive PTY. Private
`/dev/null` fillers place a real pipe at descriptors 12, 1023, 1024 and 2056.
Its callback consumes a complete result, records it, unregisters the watcher,
closes the descriptor and redraws. A separate ZLE widget verifies that `abc`
can still be edited afterward. Loaded module paths and executable/module hashes
are recorded. See [the finding](bugs/zle-select-high-fd.md).

On both pristine Zsh 5.9.2 and round 62 rebuilt with `ac_cv_func_poll=no`, the
ordinary callbacks work but tested high-descriptor callbacks are not delivered.
The candidate now rejects `fd >= FD_SETSIZE` at registration when `poll` is
unavailable. It emits `file descriptor out of range for select: FD`, returns
status 1 and leaves watcher state unchanged. Existing poll support is unchanged.

## Evidence

The complete matrix runs each boundary in C and C.UTF-8. It asserts the exact
descriptor allocated by the private fixture, registration status, callback
result, post-operation ZLE buffer and clean shell exit. For successful callbacks
the recorded result is `CALLBACK`; safe rejection has no callback and still
allows the `abc` buffer capture.

| Build and backend | Cases | Failed intended states | Control differences |
| --- | ---: | ---: | ---: |
| Preceding psh, select | 8 | 4 | reference |
| Candidate, select | 8 | 0 | 0 |
| Candidate select under Memcheck | 8 | 0 | n/a |
| Pristine Zsh, select subset | 4 | 2 | n/a |
| Preceding psh, poll | 8 | 0 | reference |
| Candidate release, poll | 8 | 0 | 0 |

All four ordinary/low select controls match the preceding build, including
descriptor 1023 on the select side of the boundary. Both poll builds also match
at descriptors 1024 and 2056. High-select references install the handler but do
not produce its result; this finding does not attribute that missing callback
to a particular stray bit beyond the confirmed unchecked fixed-set access.
The candidate's round-62 parser matrix also passes all 14 cases with no control
differences.

The select fixture rejects high descriptors before taking ownership in ZLE;
its caller closes the rejected pipe. Successful callbacks unregister before
closing. The initial Memcheck attempt failed to launch Valgrind because the
driver used non-searching `execve`; the corrected driver uses `execvpe` and a
child-only immediate error exit. No failed instrumented launch is used as
product evidence.

Full upstream validation passes 62 scripts, zero failures and three skips. All
24 unchanged Oh My Zsh sessions match, including real async callbacks,
completion, history, prompts, syntax highlighting and interruption. This is a
correctness fix with no speedup claim.

The validation covers shell-managed watchers on Linux x86-64 with
`FD_SETSIZE=1024`. Arbitrary native mutation of private watcher state and a high
terminal descriptor itself are not addressed here. Other descriptor sizes,
operating systems and native layouts are not certified. Installed rc2 remains
unchanged.

## Reproduction

For a select-only build, configure in a separate build directory with
`ac_cv_func_poll=no` in its environment. Then run:

```sh
python3 Perf/check-zle-highfd.py --shell /path/to/select/Src/zsh \
  --modules /path/to/select-runtime/lib/zsh/5.9.2 --backend select \
  --reference .work/round63/select-before.json \
  --output .work/round63/select-candidate.json --require-pass
```

Use `--backend poll` with matching release builds for the ordinary high-FD
controls, and add `--memcheck` for the select-only candidate matrix. No personal
startup files are sourced, no descriptor limit is changed and no installation
is performed by this probe.
