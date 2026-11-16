# Round 61: validate print -u before narrowing

Round 60 explicitly left the corresponding `print -u` conversion for a separate
change. Its parser cast `zstrtol()`'s `zlong` result to `int` before `dup()`.
On this host, `print -u $((4294967296 + fd))` therefore writes to `fd`. Pristine
Zsh 5.9.2 and the preceding psh build both reproduce the write. Independent
inspection of a private output file confirms the resulting bytes. See
[the finding](bugs/print-descriptor-narrowing.md).

The parser now keeps the `zlong`, rejects values outside `[0, INT_MAX]`, and
only then converts. The diagnostic is `file descriptor out of range`. Rejection
occurs before descriptor duplication or output. Ordinary descriptors, closed
but representable descriptors, lexical diagnostics, coprocess output and the
undocumented `-up` spelling retain their previous behavior. The native ABI is
unchanged.

## Evidence

`Perf/check-print-descriptor.py` inherits a private writable file descriptor
and reads its bytes after each command. The matrix covers C and C.UTF-8, three
wide aliases, five other out-of-range values, a closed `INT_MAX` descriptor and
seven lexical or ordinary controls.

| Build | Cases | Failed expected rejections | Ordinary control differences |
| --- | ---: | ---: | ---: |
| Pristine Zsh | 32 | 16 | reference |
| Preceding psh | 32 | 16 | 0 |
| Candidate release | 32 | 0 | 0 |
| Candidate under Memcheck | 32 | 0 | n/a |

The 16 rejection cases per build comprise eight values in two locales. Not every
reference failure is a wrong-descriptor write: some values instead produce an
incorrect wrapped-descriptor diagnostic. All six alias cases do write the test
sentinel to the real descriptor. The candidate leaves the file empty for every
rejected value. All 16 closed/ordinary controls match the preceding build after
normalizing only the inherited descriptor number.

A separate live coprocess check returns `coprocess-copy` through `print -up`
and `read -p` with equal status, stdout and stderr before and after. The B03
regression rejects a wide alias and a negative descriptor, then successfully
writes `ok` through the real descriptor and preserves the lexical diagnostic.
Full upstream validation passes 62 scripts, zero failures and three skips. All
24 unchanged Oh My Zsh terminal sessions match; framework sources are unchanged.
Results are retained with the evidence. This is correctness work with no speedup
claim. Validation is Linux x86-64; other numeric type widths and platforms are
not certified. Installed rc2 remains unchanged.

An initial full-suite attempt failed only because three expected diagnostic
line numbers in the new test were one greater than the harness line numbering.
That log is retained as `initial-upstream.log.gz`; the corrected assertions
are covered by the subsequent full run.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-print-descriptor.py \
  --shell .work/release-candidate/Src/zsh \
  --reference .work/round61/before.json \
  --output .work/round61/candidate.json --require-pass
python3 Perf/check-print-descriptor.py \
  --shell .work/release-candidate/Src/zsh --memcheck \
  --output .work/round61/memcheck.json --require-pass
```
