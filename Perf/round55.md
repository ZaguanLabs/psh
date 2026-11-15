# Round 55: linear associative readiness construction

`zselect -A` searched its entire accumulated key/value list for every ready
file descriptor. This made result construction quadratic in the number of
ready descriptors, even for a read-only set with no duplicate keys.

The returned three descriptor sets already encode the complete answer. Emit
each key at its first occurrence in the existing read/write/exception traversal,
and collect its flags directly from those sets. This preserves key insertion
order, ascending descriptor order within each set, and `rwe` flag order. It
also avoids allocating a replacement value when another flag is encountered.
The descriptor traversal remains bounded by the largest selected descriptor;
there is no new descriptor table, cache, ownership rule or native ABI change.

Parameter assignment still happens after constructing the complete list.
Parsing, select/retry behavior, ordinary-array construction and error paths
are unchanged. No intentional compatibility difference is introduced.

## Release profiling and timing

Callgrind on the actual release core and old/new release modules, with 100
calls selecting 256 read/write-ready descriptors, reports 318,334,593 versus
108,069,771 whole-process instructions. Before the change, strcmp accounts for
137,923,873 instructions (43.33%) and bin_zselect itself for 69,423,968 (21.81%).
The latter falls to 3,915,252 instructions. These instruction counts are profile
evidence, not elapsed-time measurements.

Separate timings use nine alternating before/after samples pinned to one CPU,
without concurrent builds, tests or profiling. Both variants use the same
release executable and different, explicitly verified zselect modules. Each
sample is a fresh process, including startup and final result serialization:
10,000 repeated selections for 1/8 descriptors, 1,000 for 64/256/512. Every
descriptor is ready for both reading and writing. Complete final output hashes
match for every timed sample. Medians follow; negative savings mean slower.

| Ready descriptors | Associative before → after | Time saved | Ordinary-array time saved |
| --- | --- | --- | --- |
| 1 | 0.01983 → 0.01938 s | 2.26% | 3.08% |
| 8 | 0.03914 → 0.03574 s | 8.68% | -1.29% |
| 64 | 0.05143 → 0.02088 s | 59.40% | 1.08% |
| 256 | 0.33742 → 0.08456 s | 74.94% | 1.17% |
| 512 | 1.55011 → 0.17752 s | 88.55% | -0.13% |

Small changes in the ordinary-array controls are retained, including slower
results. No ordinary-array improvement is claimed. These are repeated-zselect
workloads, not end-to-end application speedups.

The user's zcoder remote-server polling function uses `zselect -A` over its
reader list (`lib/remote_server.zsh`, `_remote_server_io_poll`); zdraw's streams
example uses it for terminal/worker input. This makes the path relevant to the
user's applications, but no full application performance gain is established
here. The two-descriptor streams case should not be expected to show the large
batch gains. Application-level profiling remains a separate follow-up.

## Compatibility and memory evidence

- 105 readiness/output cases match the preceding module and pristine Zsh,
  including full pristine-interpreter comparison. Independent Python select
  results check each associative readiness value. Cases cover zero to 512
  descriptors, shuffled input, overlapping sets, mixed sets, actual TCP urgent
  data (`rwe`), readonly parameters, ordinary arrays and timeout preservation.
  Raw parameter serialization also compares observable hash iteration order.
- The existing 760-case descriptor matrix passes: 240 required rejections
  and 520 unchanged controls.
- Memcheck reports zero errors for both modules over 100 calls with 256
  overlapping descriptors and equal final output. Leak checking was disabled;
  this is not a leak-freedom claim.
- The full upstream suite passes 62 scripts, zero failures, three skips.
  V14 includes a lasting regression for combined flags and timeout preservation.
- All 24 unchanged Oh My Zsh terminal sessions match, including the configured
  plugin/theme stack. This is terminal behavior testing, not startup alone.

Evidence, raw timing samples, hashes and the candidate patch are retained under
`Perf/results/round55`. Tests were run on Linux x86-64; other platforms have
not been certified. Installed rc2 remains active. Complete isolated packaging
and native-loader verification remain mandatory before activation.

## Reproduction

Retain the preceding `zsh/zselect.so` under a private module root before building.
Then run the check, profile and benchmark modes separately (no overlapping work
while timing):

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/zselect-readiness.py --shell .work/release-candidate/Src/zsh \
  --before .work/round55/before --after .work/release-runtime/lib/zsh/5.9.2 \
  --mode check --output .work/round55/check.json
```

Use `--mode profile`, `--mode memcheck` or `--mode bench --samples 9`, each
with a distinct output file. The harness requires Linux `/proc`, Python select,
at least 520 available descriptors, and local TCP urgent-data support.
