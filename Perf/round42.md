# Round 42: nested associative getters and the cost of counting

This round finds a wrong-result bug shared with pristine Zsh 5.9.2, fixes it,
and separately tests removing the counting pass from bounded ordinary hash
expansions. The correctness fix does not change native layouts or the existing
`paramvalarr()` interface. No release is published or activated.

The parent is `ed2ef044cc29772c8501040acb02ed3c8df0804d`. Comparisons use the
preceding accepted inactive package `1.0.0-rc1-519928894f02`, SHA-256
`c2dbffe4df42f9adfc77a5946685804ba2c14f4e1cd731ae66a8567c12245421`.
The initial correctness-only package is `1.0.0-rc1-cde7f840ec94`, SHA-256
`db62b371547776e65af4b4b3cb2c340e0fbaaee0fb2c1ec3e08772346c5a45a1`.
The candidates use GCC 15.2 release-profile PGO+LTO builds.
The final, verified correctness-only package is `1.0.0-rc1-6db51a2527d4`,
SHA-256 `d10393954414ba849e7f4759acc0a2e006eb1c9961780d86e3a212d44c2b5102`,
883,312 bytes. Its full test and timing records are distinguished from the
initial signed-count pilot below.

## A concrete native-getter defect

`paramvalarr()` counts hash elements, allocates output slots, then scans again
to fill them. The count and output pointer are static globals. During the fill
scan, `getstrvalue()` can invoke an element's custom native getter. If that
getter expands another hash, it replaces the outer operation's working state.

For `outer=(a A b B)` and `inner=(x X y Y)`, the fixture gives `outer[a]` a
getter that reads `inner` before returning its own ordinary value. Asking for
the outer values returns **X and Y** on both pristine Zsh and the preceding
psh build. The candidate returns **A and B**. The basic reproducer produces
no Memcheck invalid-access diagnostic; this is a demonstrated incorrect result,
not a claim of demonstrated memory corruption.

The fix saves/restores each materialization's count and output pointer, and
saves/restores pattern-search state across each scalar getter. An internal
helper returns the materialized count explicitly to `getvaluearr()` instead
of using the shared count as a second result channel. The old function
signature remains as a wrapper. Getter calls and traversal order are retained.

The [standalone report](bugs/hash-getter-reentry.md) and
[legacy-header native fixture](hash-reentry-module.c) cover the exact before/
after behavior. Later cases exercise zero, one, three, 65, 4,096 and 4,097
inner elements, three nested getter levels, values and key/value pairs,
matching and missing patterns, unset elements, generated scan providers and
balanced signal queues. Arbitrary callback-driven table destruction/growth
and same-table nested mutation remain outside this claim.

## Separate count-bound experiment

Trial `1.0.0-rc1-33125fdb23fe` adds one independent optimization: for tables
with no custom scan provider, an already-held signal queue, and at most 4,096
nodes, use `ht->ct` as an output-capacity upper bound. Unset entries can waste
slots but cannot exceed that bound. Key/value pairs reserve two slots per node.
All larger tables, unqueued callers and custom scan providers retain the count
pass. On this 64-bit host, the upper bound limits additional pointer storage
to 64 KiB per expansion. It is a memory bound, not a cache-line assumption.

The existing fill scan, filters and getters remain. This removes counting
callbacks, not a second invocation of every value getter: the old count pass
does not read values. Native tests explicitly verify that generated providers
still receive both scans and unset elements remain absent.

Callgrind on the actual installed binaries gives an early explanation of the
likely limit. Drawing binning uses 391,607,350 versus 391,607,088 instructions,
essentially unchanged. Real zjson object parsing uses 2,556,310,917 versus
2,555,932,250, a reduction of about 0.015%. The count callback disappears from
the latter profile, but accounts for very little of the complete operation.
Both profiles compare full resulting states after excluding the elapsed line;
their scope includes setup and output, unlike the warm timers.

## Compatibility evidence

Both the initial and final correctness-only installed packages pass the full
packaging verifier. Final-package evidence includes:

- 63 upstream scripts successful, zero failures, two skips.
- All seven core/bundled-project suites, including native zdraw and Markdown.
- 24 genuine interactive Oh My Zsh sessions and 14 native-library observations.
- Installed-component loading/rendering, startup files, module isolation and
  protected stable-Zsh/account-shell snapshots.

Broad comparisons against pristine Zsh cover 5,192 array cases, 281,834 scalar
checks, 362,580 search checks, 63,840 pattern checks, 2,640 substitutions,
512 emulation checks and 195,600 arithmetic checks. Stateful sequences and
legacy native array, scope and floating-state fixtures include Memcheck runs.
The count-bound trial passes the same comparisons, its upstream suite, the
new nested-getter fixture and all 24 OMZ sessions.

The same broad comparisons also run directly between the preceding accepted
psh and the correctness-only candidate. The initial array-native invocation
mistakenly enabled `--raw-contract`, whose baseline assertion specifically
expects pristine Zsh's uncached raw-array result. That assertion correctly
rejects the preceding psh, which already has the documented raw-alias
difference. The failed aggregate and log are retained. The supported native
checks pass when run as a psh-to-psh pair; an additional explicit Memcheck
comparison verifies that both psh versions give the same documented raw-alias
and supported-getter results in C and C.UTF-8. No core behavior was changed
to silence that assertion.

The final unsigned-count package has fresh, clean twelve-group comparison
reports against both pristine Zsh and the preceding accepted psh. Its psh-pair
invocation uses the appropriate baseline mode from the outset. The final
legacy-header nested-getter fixture also passes under Memcheck; both reference
hosts still fail the documented reproduction, as expected.

## Experiment history and isolation

The first fix trial, `cfc6db0ba09b`, restored the shared count without replacing
the caller's result channel. Compiler training rejected it. Intermediate
`8a0b64144972` retained top-level count behavior but still left nested count
consumption uncertain; it is not adopted. The explicit count result in
`cde7f840ec94` replaces both approaches. Final review keeps that count unsigned
until the original conversion to the subscript endpoint: incrementing a signed
endpoint first would introduce signed overflow at `INT_MAX`. Final candidate
`6db51a2527d4` preserves the original unsigned addition. The earlier sources
remain as trial patches; the initial timing pair is not mislabeled as that
final package.

The first full-verifier attempts were rejected because the working tree held
the separate count experiment and an edited compiler-training workload. The
matching fix source was restored, and new JSON-object benchmarks were moved
to a separate worker. Verification then passed without bypassing source
identity checks. The new optional `applications.py --objects` cases use the
unchanged customer zjson library and check every object member and encoded
document outside the timer.

Four changes predated this round: `Packaging/README.md`, `Packaging/build.py`,
`Packaging/check-ohmyzsh.py` and `Perf/ohmyzsh-session.zsh`. They remain untouched
and excluded from this round's commit. Local package provenance includes those
existing build/gate changes; the saved starting diff is local-only.

Elapsed-time comparisons run serially on CPU 13, C.UTF-8, with nine alternating
samples for project kernels, JSON operations and focused expansion cases.
Fresh Moonlit construction uses three alternating pilot samples plus one
excluded warmup per host. Complete results/rendered output must match. Own
builds, tests and profilers, plus an observed separate zdraw build, finish
before timing. The focused controls include ordinary arrays, empty hashes
and 4,097-node fallback tables.

## Timing decision

The count-bound shortcut is **not adopted**. Compared with the initial
correctness-only package, its customer medians range from about 2% less time
for chat paste to small slowdowns in several controls. JSON-object parsing
takes 1.3% more time, encoding 0.5% more, and the fresh Moonlit pilot 1.0% more.
At 4,096 entries, focused pair expansion takes 2.5% less and matching 3.0%
less; the array and 4,097-entry fallback controls are mostly flat. This does
not establish a worthwhile application benefit for the added allocation rule.
The optimization count stays at **27**.

The initial correctness-only package has no broad application regression in
the paired pilot: customer medians range from 0.4% more time to 2.2% less,
JSON-object parsing/encoding take about 1% less, and the three-sample Moonlit
pilot takes 1.1% less. Focused 4,097-entry key/value expansion takes about 2%
more. Small shifts are not evidence that the bug fix itself accelerates these
applications. The complete table, including slower controls, is in
[timings-pilots.md](results/round42/timings-pilots.md). Final-package confirmation
is recorded separately.

The useful adopted change is the correctness fix and its regression coverage.
The new object benchmarks remain available for future investigations. Profiles
show why the removed work is a weak target for these applications; they do not
establish that all performance opportunities are exhausted.

## Final exact-package confirmation

The final unsigned-count package passes both twelve-group differential runs,
all seven package suites, the legacy-header getter fixture under Memcheck, and
`Packaging/verify.py verify`. Matching receipts retain the 24 OMZ sessions,
14 native-library observations, stable-system snapshots and installed-component
checks. Its source inputs still match the build metadata.

After all of that work finished, the final binary was timed directly against
the preceding accepted package. Across thirteen customer kernels, median
changes range from 1.9% less elapsed time to 0.2% more. JSON-object parsing is
essentially flat (+0.02%); object encoding takes 1.4% less. Moonlit's small
three-sample pilot takes 1.7% less, with identical complete rendered output.
At 4,096 entries, focused key/value expansions take about 1.5% more, pairs
0.5% more and pattern matches 1.0% more. These costs and small application
shifts are retained in [timings-final.md](results/round42/timings-final.md),
without representing them as a new optimization gain.

The candidate remains inactive. `/usr/local/psh/current` still selects
`1.0.0-rc0-7e8f4c48abf5`; its executable and the root developer executable
retain their starting hashes. No account-shell, personal startup, stable-Zsh,
release-tag, publication or repository-visibility change was made. The existing
packaging/OMZ edits remain separate and unchanged.

[results/round42](results/round42/) contains final and intermediate build
metadata, all timing samples, failed and successful comparisons, trial patches,
compressed profiles, the fixture's negative/positive evidence, the final
validation receipt, and a SHA-256 manifest. `status.json` identifies the final
package and the protected active release.
