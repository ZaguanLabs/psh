# Round 41: evaluation work, temporary storage and native boundaries

This round investigates six routes using actual GCC 15.2 PGO+LTO release
packages. It does not change the active rc0, published artifacts or the held
rc1 checkpoint. The parent is `3b0273b808bc48c4df9a2c717503b5417a73a9aa`;
the accepted comparison binary is inactive release `1.0.0-rc1-519928894f02`,
SHA-256 `c2dbffe4df42f9adfc77a5946685804ba2c14f4e1cd731ae66a8567c12245421`.
All six routes are rejected for adoption. The accepted C source is restored
exactly; the optimization count remains 27. No new compatibility departure is
introduced. The final timing matrix is recorded below.

## Profiles and method

Fresh Callgrind profiles use that installed release and unchanged customer
sources. Endgame records 1,068,100,535 instructions: the main mathparse body
has 13.32% self instructions, its cold body 4.63%, op 12.61%, zzlex 10.85%
and itype_end 5.24%. Coder paste records 1,183,726,166 instructions; parameter
substitution, command execution, classification and argument processing remain
important. These are complete profiling processes, including setup and output,
not construction-only timers. State hashes exclude the elapsed-time line.

Customer pilots alternate the accepted and trial executables, nine samples per
case, CPU 13, C.UTF-8. All thirteen existing project kernels retain complete
result-state comparisons and source/binary hashes. Profilers, builds and tests
from this work finish before timing. Separate small Moonlit pilots for the
first two routes compare all rendered output bytes. The existing full Moonlit
profile from round 39 is consulted as additional source evidence, rather than
represented as a new profile of this baseline.

## Scalar finishing and arithmetic storage

The scalar-finishing trial retains the original fetchvalue/getstrvalue calls,
then skips unused modifier handling only for narrowly eligible ordinary scalars.
The checked trial `0cd9f52b549f` includes an explicit non-null value guard.
Coder/chat paste take 0.9%/1.2% less time and the small Moonlit pilot 1.1% less.
These screening differences do not establish a useful customer improvement.

The inline-descriptor arithmetic trial `bf5ee1f7a275` embeds private Value
descriptors in math stack cells. A sixteen-entry initial C stack grows to the
existing hundred-entry limit on the Zsh heap, with recursive save/restoration.
It avoids descriptor allocations but enlarges each hot entry from 32 to 72
bytes on this host. Endgame takes 2.4% more time; the Moonlit pilot is only
0.5% lower. This layout is rejected.

The parallel-buffer trial `e0cb6d877447` keeps the original 32-byte entries and
stores descriptors separately. Growth copies occupied entries and descriptors,
then fixes their private pointers. It retains the original lookup/getter/setter
paths and stack-overflow limit. Endgame takes 5.7% more time, so it is rejected
despite passing boundary and native checks. The additional focused cases cover
depths around sixteen and one hundred, lazy compound lvalues, recursive numeric
strings, callbacks and recovery after overflow. Their exact statuses, output,
diagnostics and restored arithmetic state match both pristine Zsh and the
preceding accepted release, including under Memcheck.

## Reallocation for ordinary scalar appends

Trial `39e3d991802f` replaces allocate/copy/free with realloc for eligible
appends. The original getter and index normalization still run. Eligibility
requires ordinary scalar ownership, a conservative attribute whitelist and an
already-held signal queue. This last condition prevents a pending trap from
observing a stale parameter pointer after realloc moves its allocation.
The normal setter, named-directory update and export handling are retained.
Custom parameters and unqueued native callers use the legacy path.

The large-append control takes 6.3% less time, including the unchanged reset
cost. Actual application medians are much smaller: coder/chat paste about
0.7%/0.4% lower, JSON array encoding 1.2% lower, fetch encoding 2.2% lower;
other controls are flat or slower. This is retained as an experiment, rather
than adopted on the strength of the isolated copy reduction.

## Literal quotes and a confirmed native incompatibility

The first working quote trial `be4ed7db95a9` uses stored wordcode token flags
to recognize short literal quoted arguments, then retains the prefork signal
boundary and quote-removal pass while skipping inactive expansion passes.
Mutable argument copies and original stored wordcode/function text remain.
Coder paste initially takes 3.6% less time.

That version is unsafe. A legacy native module can clear ITOK for Tilde while
an eval body is compiled, then restore it before the command runs. If another
argument contains quote markers, pristine Zsh still performs file expansion
for the whole list. The trial trusts the earlier token flag and skips it:

```zsh
p() { print -rl -- "$@"; }
psh-clear-tilde-token
eval 'psh-restore-tilde-token; p ~ ""'
```

With the fixture HOME, pristine Zsh and the accepted psh print
`/tmp/psh-literal-fixture-home` and an empty line. The trial prints literal
`~` and an empty line. The failed native report is retained. This is a bug
in an unaccepted private trial, not an intentional compatibility difference
or a defect reported against Zsh.

The checked replacement `5a66afc94be0` inspects every argument's actual bytes,
accepting only ASCII and inert quote markers, with a sixty-four-byte bound
per word before fallback. It passes the native reproducer under Memcheck,
736 literal-argument cases, 2,640 substitution cases and 512 emulation cases.
The additional validation removes most of the initial gain: coder paste is
0.8% lower, chat paste 0.4% higher, and other results are mixed. Neither quote
trial is adopted. Native table mutation is not silently declared unsupported.

## Complete integer-counter evaluation

Trial `72c68479281a` specializes a complete one-letter postfix expression such
as `i++`. It requires the real ordinary parameter table, original hash/compare
and lookup callbacks, the standard integer GSU, a conservative flag whitelist,
no environment aliases/export, normal execution, no FORCEFLOAT and no overflow.
Live character classifications are checked. No parameter binding or value is
cached. The lookup and update occur inside the parser's existing signal queue;
all ineligible cases retain the evaluator.

The existing arithmetic differential suite passes 195,600 cases. A new matrix
evaluates 3,240 complete expressions directly, preserving the exact entry path;
wrapping an expression inside `answer=...` would miss this specialization.
The legacy native fixture compares returned type/value, custom recursive
getters/setters, native hash/compare callbacks, classification edits, overflow,
queue restoration and a real queued USR1 trap under Memcheck.

The isolated exact `i++` loop takes 34.1% less time. Its trailing-space and
`i+=1` controls take 5.0% and 7.2% more, respectively. Endgame takes 1.8% more;
its matching-output instruction profile increases from 1,068,100,535 to
1,071,205,722, or 0.29%. The specialization is useful locally, but its placement
adds eligibility work to recursive parser calls. It is not adopted.

The outer-entry variant `65c3b3ab6eb4` moves eligibility to mathevall, leaving
recursive entries without the new check. Its queued parser body is byte-identical
to the accepted body after moving the original error guard and queue increment
to a small inline entry wrapper. Fallback enters with exactly the original
queue depth; it does not unqueue and restart parsing. This variant is assessed
separately in the final matrix.

## Final installed-release timings and decision

Percent change in elapsed time against the accepted release within each pair;
negative means less time. These are nine-sample pilots with matching state,
not individually established statistically significant improvements.

| Trial | Coder paste | Chat paste | Endgame | Mario | Fetch encoding |
| --- | ---: | ---: | ---: | ---: | ---: |
| Scalar finish | -0.89% | -1.16% | -0.41% | -3.12% | +0.04% |
| Inline descriptors | -0.49% | -0.30% | +2.40% | -2.01% | -0.63% |
| Parallel descriptors | -0.23% | -0.64% | +5.70% | +0.01% | -0.39% |
| Scalar realloc | -0.65% | -0.43% | +0.41% | -0.68% | -2.22% |
| Quote metadata (unsafe) | -3.60% | -1.45% | -0.30% | -1.35% | -1.15% |
| Quote bytes checked | -0.76% | +0.43% | -0.58% | -1.08% | +0.08% |
| Counter in parser | -0.58% | +0.03% | +1.84% | -0.21% | -0.87% |
| Counter outer entry | -0.90% | -0.86% | +0.17% | -2.10% | -1.30% |

The complete thirteen-case matrix and every raw sample remain in
[timings-all.md](results/round41/timings-all.md) and the linked JSON reports.
The outer-counter placement avoids the first variant's Endgame regression,
but Endgame is essentially flat and editor medians are only about 1% lower.
Other controls remain mixed. This does not justify accepting a second parser
entry path. Its arithmetic matrix, native Memcheck test and core package suite
pass, but it is rejected for customer performance. Both counter patches remain
unapplied.

The useful architectural lesson is specific: eliminating work inside one
operation can lose overall when eligibility checks, stack footprint or code
placement affect every evaluation. The unsafe quote trial also shows that a
syntax token cache cannot blindly trust classification decisions made earlier.
A larger arithmetic execution-plan experiment remains a possible next route,
but needs characterization of parse/error ordering, lazy reads, native callback
state, options and trap boundaries before implementation. This round does not
claim to have implemented that cache or exhausted all possible optimizations.

## Evidence and limits

Patches, reports, raw timing samples, build metadata and compressed profiles are
retained under [results/round41](results/round41/). Trial build directories,
installed inactive executables and compiled native fixtures remain in `.work`
and the isolated release prefixes. The initial scalar variant and quote build
with a missing generated forward declaration are retained as preliminary
controls; neither is a release candidate.

Focused/native tests and the core package suite are screening evidence, not a
claim that every trial passed the complete package or OMZ gate. No rejected
trial receives activation evidence. Public module layouts and existing exports,
stable Zsh, startup files, account shell and active psh remain protected.
