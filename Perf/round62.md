# Round 62: validate zle -F before narrowing

The descriptor audit reaches the watcher API used by asynchronous interactive
plugins. `bin_zle_fd()` cast `zstrtol()`'s `zlong` result to `int` before
validation. On this host, `4294967296 + fd` therefore addresses descriptor
`fd`. Pristine Zsh 5.9.2 and the independently rebuilt round-61 candidate both
replace or remove that descriptor's handler through the wide alias. See
[the finding](bugs/zle-fd-narrowing.md).

The parser now checks the original value before converting. Values outside
`[0, INT_MAX]` return status 1 with the existing `Bad file descriptor number
for -F` diagnostic. Rejected operations leave watcher state unchanged. Ordinary
descriptors, `-w` replacement, listing, callback dispatch and removal are
unchanged. No native structure or callback interface is modified.

## Evidence

`Perf/check-zle-fd.py` inspects watcher state after each operation. The matrix
covers wide addition, `-w` replacement, listing and removal in C and C.UTF-8,
plus valid `3`, `+3` and `003`, zero, lexical errors, negative values and
`INT_MAX` controls. Expected states include the remaining original handler and
its successful cleanup through the real descriptor.

| Build | Cases | Failures against intended state | Control differences |
| --- | ---: | ---: | ---: |
| Pristine Zsh | 14 | 8 | reference |
| Preceding psh, rebuilt from round 61 | 14 | 8 | 0 |
| Candidate release and module | 14 | 0 | 0 |
| Candidate under Memcheck | 14 | 0 | n/a |

The probe was corrected before the final matrix: `-w` now precedes its
descriptor, and an empty global handler listing returns status 0, matching the
actual API. Both reference runs and candidate comparisons use that same probe.
The preceding build is a private, isolated reconstruction of commit `c1177c9`;
the candidate was never used as its own before-control.

`Test/X03zlebindkey.ztst` rejects wide replace, list and remove operations,
then observes the original handler and removes it through descriptor 11. The
unchanged Oh My Zsh terminal gate exercises its real asynchronous ZLE callback,
completion, history, prompt, syntax highlighting and interrupt behavior. Full
upstream validation passes 62 scripts, zero failures and three skips; all 24
unchanged OMZ sessions match. Results are retained with the evidence. This is
correctness work with no speedup claim.

The isolated `TESTNUM=X03` check passes before the final full run. The retained
`initial-upstream.log.gz` failure is a test-fixture issue: stderr expectations
need exact `(eval)` diagnostics rather than the stdout wildcard spelling.
`x03.log.gz` records the corrected isolated test.

Validation is Linux x86-64 with the release `poll` backend. The separately
identified select-only capacity issue is not addressed or certified here.
Other numeric type widths and platforms are not certified. Installed rc2 remains
unchanged.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-zle-fd.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --reference .work/round62/before.json \
  --output .work/round62/candidate.json --require-pass
python3 Perf/check-zle-fd.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --memcheck \
  --output .work/round62/memcheck.json --require-pass
```
