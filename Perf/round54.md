# Round 54: zselect descriptor validation before narrowing

The system-module audit continues into zsh/zselect. Its handle_digits helper
checked FD_SETSIZE only after narrowing to int. Large values could alias a
valid descriptor and report readiness for it. A small change validates the
full parsed zlong, then converts it only when representable. The range warning
now prints that full value with the existing Zsh diagnostic formatter.
See [the finding and reproducer](bugs/zselect-descriptor-narrowing.md).

## Compatibility and evidence

The new oracle runs 760 cases under C and C.UTF-8. It inspects all result
parameters, exit status, stderr and the independently held input file position.
It uses zero-timeout select on temporary seekable input, so malformed cases
cannot hang waiting for readiness. Default/named/associative outputs, -A over
-a precedence, separate and attached flags, read/write/exception sets, mixed
lists, lexical errors, range boundaries and oversized numbers are covered.

| Build | Wide-input failures / 240 | Ordinary control differences / 520 |
| --- | --- | --- |
| Pristine Zsh 5.9.2 | 240 | 0 |
| Installed rc2 | 240 | 0 |
| Round-53 candidate | 240 | 0 |
| Round-54 candidate | 0 | 0 |

The 240 checks include diagnostic correctness: do not interpret this as 240
successful wrong-descriptor operations. Each reference returns success for
72 of the wide-input cases. The candidate rejects every tested wide value
before the select call and leaves readiness parameters intact.

The existing order is preserved: require an initial digit, parse decimal,
check range, then check trailing garbage. Existing option-loop behavior is
covered by differential controls, not rewritten. Earlier rejection can stop
later option processing and alter conditionals/traps; COMPATIBILITY.md records
the change and migration. The native module ABI and timeout logic are intact.

The reference executable and loaded module hashes are recorded before rebuild;
the preceding module is retained privately. This fixes int narrowing of the
parsed value, not zstrtol truncation of arbitrary-size input. Testing is on
Linux x86-64 with 32-bit int; other architectures have not been certified.

The upstream-style regression in V14 checks default and associative result
preservation for rejected wide descriptors, followed by ordinary readiness.
The full upstream suite passes 62 scripts with zero failures and three skips
(privileged/optional-module coverage). All 24 unchanged OMZ terminal sessions
pass. Evidence is retained under Perf/results/round54.
No performance gain is claimed. Installed rc2 remains active; complete isolated
packaging/native validation is required before activation.

## Reproduction

```sh
python3 Perf/check-zselect-descriptors.py --shell /path/to/reference --output reference.json
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-zselect-descriptors.py --shell .work/release-candidate/Src/zsh --output candidate.json --reference reference.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output ohmyzsh.json
```
