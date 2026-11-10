# Public rc0 benchmark and preparation evidence

These fresh measurements compare the unmodified upstream Zsh 5.9.2 release with
the accepted psh release `1.0.0-rc0-7e8f4c48abf5`. They are end-to-end kernel
comparisons, not sums of improvements from individual development rounds.

- `reference-build.json` and `reference-upstream.log` bind a fresh GCC release
  baseline, `-O2 -g`, explicit `LDFLAGS=-g`, assertions off, dynamic/multibyte/PCRE2,
  private matching modules/functions, and 63 passed upstream scripts with zero
  failures and two skips. `environment.json` records compiler, CPU, OS and kernel.
- `customer-benchmarks.json` / `customer-repeat.json` retain all 13 original
  customer kernels. `library-benchmarks.json` / `library-repeat.json` retain the
  four original library/navigation kernels. Both passes use nine alternating
  samples on CPU 13 in C.UTF-8, with source/binary/worker and matching-state hashes.
  The author project checkouts are separate from this source distribution.
- `bundled-json.json` / `bundled-json-repeat.json` use the included, pinned
  `Vendor/zjson` sources. No separate application checkout is needed for these
  three cases. The earlier mandatory-z3dfx driver is retained as
  `applications-before.py`; the new optional-navigation driver fingerprints itself.
- `timing-commands.json`, `bundled-timing-commands.json`, driver sources and logs
  retain commands and every sample. Own reference builds/tests finished before
  timing; no own profiler ran concurrently. External activity was not continuously
  audited. Warm timings exclude loading/setup/startup. No general shell-speed
  or whole-application-startup guarantee follows from the ratios.
- `preparation.json` verifies all 1,853 production inputs still match the accepted
  installed package and all 1,847 pristine source files match their manifest.
  It also verifies that the historical private rc0 notes were preserved.

To reproduce the bundled JSON workload from the release archive:

```sh
python3 Perf/build.py --profile release
python3 Perf/applications.py .work/release-baseline/Src/zsh ./psh \
  --arrays --zjson Vendor/zjson --output .work/json-benchmarks.json
```

For CPU affinity comparable to the recorded method, add `--cpu N` using an
available CPU on your machine. Leave builds, tests and profilers idle while timing.
The complete original customer benchmark needs its corresponding project sources.

The exact release archive is generated from the subsequent committed release
inputs and validated separately. Its checksum, commit/tree identity and fresh
Git-disabled source-build report accompany the attached archive; they are not
self-referential contents of this benchmark snapshot. The accepted installed
package's [latest validation](../../../Perf/results/round37/README.md) covers
native projects, genuine OMZ sessions and system protection.
