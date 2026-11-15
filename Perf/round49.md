# Round 49: validate system-module integers before narrowing

Round 48's descriptor investigation is now a narrowly scoped correctness fix.
`getposint()` retains the parsed `zlong` until it has checked both bounds of
the nonnegative `int` range. Previously an oversized or sufficiently negative
number could become a valid file descriptor and perform real I/O. The five
affected options and safe reproducer are in [the finding](bugs/system-integer-narrowing.md).

## Results

| Build | Rejection failures / 90 | Compatibility controls / 114 |
| --- | --- | --- |
| Pristine Zsh 5.9.2 | 40 | Exact match |
| Installed rc2 | 40 | Exact match |
| Round-48 candidate | 40 | Exact match |
| Round-49 candidate | 0 | Exact match |

The independent oracle checks command status, diagnostics, result/count
variables, file contents and input/output offsets. Each case gets fresh file
contents and reset offsets, with a child timeout. The 114 controls include
valid numbers, signs, leading spaces/zeros, empty values, trailing junk,
underscores, zero-size reads and INT_MAX descriptors. Their complete observed
states match the references, including existing unusual parsing behavior.
Cases run in C and C.UTF-8 on Linux x86-64; this is not cross-platform coverage.
No performance improvement is claimed.

The previous candidate's shared module is retained privately before rebuilding,
and all three controls were run before replacing it. Reports record the loaded
module hash as well as the executable hash: only `zsh/system` changes, so the
main executable hash alone cannot identify this candidate.

## Validation and scope

The focused V14 module suite passes, and the preceding sysopen oracle still
passes all 1,038 cases. The full upstream suite passes 62 scripts, with zero
failures and three skips (privileged/optional-module coverage). The unchanged
OMZ terminal gate passes all 24 sessions. Results are retained alongside the
matrices under `Perf/results/round49/`.

The patch preserves parser grammar and existing diagnostics. It checks the
parsed number, not arbitrary-length decimal input independently of `zstrtol()`.
Do not treat this as a complete checked-integer audit. Separate leads include
the arithmetic `systell()` conversion and sysread timeout conversion, which
need different treatment for floating values, errors and side effects.

Installed rc2 remains active. This research candidate has not undergone the
complete isolated packaging/native validation required before activation and
is neither a new release nor an installed update.

## Reproduction

```sh
python3 Perf/check-system-integers.py --shell /path/to/reference --output reference.json
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-system-integers.py --shell .work/release-candidate/Src/zsh --output candidate.json --reference reference.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output ohmyzsh.json
```

For a new standalone build, first stage its autoload functions with
`make -C .work/release-candidate install.fns`. This writes only to the private
runtime configured by the builder; existing functions were already staged here.
