# Round 60: validate read -u before narrowing

The next boundary after the flock arithmetic fix is the builtin `read -u`
parser. It cast a `zlong` to `int` before checking the range. On this host,
`read -u $((4294967296 + fd))` reads `fd`. `read -t` then calls `read_poll()`,
whose `FD_SET` faults when the narrowed descriptor is `2147483647`. Both
pristine Zsh 5.9.2 and the preceding psh candidate show this. See
[the finding](bugs/read-descriptor-narrowing.md).

The parser now keeps the `zlong`, rejects values outside `[0, INT_MAX]`, and
only then converts. The diagnostic is `file descriptor out of range`. Lexical
errors, the undocumented `-up` spelling, and coprocess input are unchanged.
`read_poll()` uses `poll` for a descriptor at or above `FD_SETSIZE` when
`poll` is available. Descriptors below that bound stay on `select`, with the
existing timeout arithmetic. A select-only build returns `EINVAL` before
`FD_SET` instead of indexing past the set. `print -u` has the same narrowing
and is left for a separate change.

## Evidence

`Perf/check-read-descriptor.py` inherits a private file descriptor and checks
its offset after each call. The matrix covers C and C.UTF-8, three alias
forms, five other invalid values, and seven lexical or ordinary controls.

| Build | Range checks | Failures | Control differences |
| --- | ---: | ---: | ---: |
| Pristine Zsh | 16 | 16 | reference |
| Candidate | 16 | 0 | 0 |

The pristine failures include the live-descriptor aliases and the SIGSEGV on
`2147483647`. A separate probe reads a ready file at descriptors 18, 1032 and
1108. The candidate returns the byte at all three; pristine returns it at 18
and 1032, then fails the read at 1108. Empty `/dev/null` timeouts at 3, 1023,
1024 and 1025 match. `Test/B04read.ztst` passes, including the new regression.

Full upstream validation and the unchanged Oh My Zsh terminal gate are recorded
with the results. This is a correctness fix with no speedup claim. Validation
is Linux x86-64. Installed rc2 remains unchanged.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-read-descriptor.py \
  --shell .work/release-candidate/Src/zsh \
  --output .work/round60/candidate.json --require-pass
```
