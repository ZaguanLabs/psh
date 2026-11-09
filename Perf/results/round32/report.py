from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round32';read=lambda name:json.loads((l/(name+'.json')).read_text());s='''# Round 32: structural algorithms and unnecessary work

This round identifies and measures deeper algorithmic opportunities. It changes
no production C source or installed binary. The project remains private
`psh 1.0.0-rc0 (zsh 5.9.2)`, with twenty-six accepted optimizations and the
[round-28 daily driver](round28.md).

The strongest customer-facing finding is **scope teardown proportional to the
entire parameter table**. An empty function becomes about 14 times slower with
16,384 unrelated globals. Adding just 512 globals to existing paste kernels
increases coder time by 14.4–17.5% and chat time by 17.7–19.0% in two paired
nine-sample groups. These are measured slowdowns caused by an altered namespace,
not achieved optimization gains or full-application startup measurements.

A second concrete algorithm is **linear integer exponentiation**: the current
implementation multiplies once per exponent step. Safe `1 ** 1048576` cases
cost about 694 microseconds each in warm batches, despite having result one.
Binary exponentiation is a candidate O(log exponent) replacement. No replacement
has been implemented or timed in this round.

## 1. Scope cleanup: the main redesign target

`startparamscope()` increments `locallevel`. On every `endparamscope()`, the
shell decrements that level and calls:

```c
scanhashtable(paramtab, 0, 0, 0, scanendscope, 0);
```

`scanendscope()` tests every visible parameter's level to find bindings that
need restoring or removing. `scanmatchtable()` first walks every bucket, including
empty buckets, and then every node. For S scope exits, H buckets and P visible
parameters, traversal work is O(S * (H + P)). P counts parameter bindings, not
array or associative-array elements. It happens even when a function has no
local bindings. Unsetting globals leaves the enlarged bucket vector in place.

The three scope functions are byte-for-byte identical to their pristine-release
bodies, as is the integer arithmetic operator function. This confirms inherited
logic rather than a new psh regression. The introduction dates of these routines
were not audited against historical upstream Git; copyright headers alone do not
date individual algorithms.

### Controlled scope scaling

The exact installed release runs nine fresh-process samples per case on CPU 13,
C.UTF-8, with 4,000 warm iterations. Case order rotates and reverses between
samples. Fixture construction, warmup, native observation and validation are
outside the timer. Counts include unset table placeholders and exclude hidden
shadow-chain nodes. Dense cases retain the extra globals. Sparse cases create
and delete them before timing. The observer checks actual bucket/visible counts;
outer bindings and absence of leaked locals are checked after each batch.

Microseconds per iteration below include loop/dispatch/body costs. Nested mode
calls two functions per iteration. This is not an isolated timer for the cleanup
routine itself.

| Padding | Occupancy | Entries | Buckets | Loop only | Empty function | One local | Eight locals | Emulate + local | Nested |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
'''
d=read('scope-scaling')['cases']
for padding,occupancy in dict.fromkeys((c['padding'],c['occupancy']) for c in d):
 rows={c['mode']:c for c in d if c['padding']==padding and c['occupancy']==occupancy};t=rows['empty']['table'];assert all(c['table']==t for c in rows.values());s+=f"| {padding:,} | {occupancy} | {t['count']:,} | {t['buckets']:,} | "+' | '.join(f"{rows[mode]['median_us_per_iteration']:.3f}" for mode in ['loop','empty','local1','local8','emulate','nested'])+' |\n'
s+='''
Loop-only controls remain about 0.48 microseconds per iteration. The empty
function grows from 3.849 to 54.448 microseconds. After the 16,384 globals are
deleted, it still takes 8.924 microseconds: the visible count returns to 158,
but buckets remain at 9,664 rather than 151. This exposes a historical-capacity
cost as well as a live-global-count cost. Automatic shrinking could address
part of the sparse case; it would still leave dense scope traversal and its
order/mutation requirements.

A separate pristine DEBUG-build experiment also grows from 3.821 to 16.705
microseconds with 4,096 globals. Its absolute times are not an active/pristine
speed comparison: configurations differ. Both the source identity and this
within-build scaling support the inherited-algorithm finding.

### Existing customer kernels

The wrapper adds globals before sourcing the unchanged customer worker. Its own
small wrapper namespace exists in both controls. Nine alternating samples per
pair, CPU 13 and C.UTF-8; then one complete repeat. Project sources, executable,
worker and resulting editor states are pinned. These are existing offline
input-decoder paste kernels with artificial namespace padding, not full zcoder
or zchat sessions. The padding globals are deliberately absent from the project
result fingerprint and counted separately by the observer.

| Kernel | No padding ms | +512 globals ms | Change | Repeat no padding | Repeat +512 | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
'''
for a,b in zip(read('customer-scaling')['cases'],read('customer-repeat')['cases']):
 x,y=a['median_ms'];u,v=b['median_ms'];assert a['case']==b['case'];s+=f"| {a['case']} | {x:.3f} | {y:.3f} | {(y/x-1)*100:+.1f}% | {u:.3f} | {v:.3f} | {(v/u-1)*100:+.1f}% |\n"
s+='''
The native counts increase exactly 512: coder 192 → 704, chat 188 → 700.
Bucket counts increase from 151 to 604 in both kernels. Padding can affect
allocation/cache layouts and other lookups too, so wall time alone would not
isolate scope teardown.

### Caller attribution

Separate Callgrind runs cover setup, warmup, timed work and final observations.
Their scope differs from the warm timers. Caller edges identify scope-exit scans
separately from option emulation and other generic scans. Application state and
source hashes match within each pair. Duplicate annotated views of the same
edge are deduplicated, rather than double-counted.

| Kernel | Scope exits | Cleanup callbacks, no padding | Cleanup callbacks, +512 | Scope instructions, no padding | Scope instructions, +512 |
| --- | ---: | ---: | ---: | ---: | ---: |
'''
m=read('profile-metrics')
for name in ['coder-paste','chat-paste']:
 a,b=[r for r in m if r['name'].startswith(name)];assert a['scope_exits']==b['scope_exits'];assert b['scope_cleanup_callbacks']-a['scope_cleanup_callbacks']==512*a['scope_exits'];s+=f"| {name} | {a['scope_exits']:,} | {a['scope_cleanup_callbacks']:,} | {b['scope_cleanup_callbacks']:,} | {a['scope_inclusive_instructions']:,} | {b['scope_inclusive_instructions']:,} |\n"
s+='''
Coder performs **10,250,752 extra cleanup callbacks** and chat **20,497,920**,
exactly 512 per scope exit. Scope teardown accounts for 97.8% and 99.2% of the
additional complete-process instructions respectively. That is strong
instruction attribution, not a claim that the same percentages describe wall
time or that all cleanup can be removed. Baseline scope teardown is about
8.9%/10.0% of complete-process instructions; required local restoration remains.

### Replacement design and compatibility work

The intended redesign records localized bindings as they are created or
localized, making cleanup depend on affected bindings. A dirty-bucket index is
one possible way to preserve the current bucket/chain restoration order. A
per-scope name journal is another, with its own allocation and lookup costs.
No data structure is selected or certified yet.

The source review exposes requirements a simple list of `local` declarations
would miss:

- Ordinary localization is split between `createparam()` and `typeset_single()`;
  the parameter can be inserted before its final level is assigned.
- Non-removable specials are localized in place using `pm->old`. Restoring tied
  PATH/path pairs, SECONDS, locale state and export state has real side effects.
- ZLE and completion deliberately create parameters at **locallevel + 1** before
  entering the scope that will own them. See `makezleparams()`, `addcompparams()`
  and `makecompparams()`.
- Modules such as datetime and db_gdbm assign levels directly. `param_private`
  wraps access based on scope. `paramtab` can temporarily designate an associative
  table instead of the global table.
- Unset/redeclare, shadow-chain restoration, rehashing, callbacks that mutate
  tables, native field access and nested scopes invalidate naive pointer journals.
  Observable restoration order must be preserved or explicitly classified.

The first implementation step should centralize localization bookkeeping without
changing behavior, then add an ordered journal with a full-scan fallback when its
completeness cannot be established. Native modules' exposed level writes require
an explicit supported protocol or conservative fallback. Journal maintenance must
not itself scan all globals on each call. Small-local scopes need low allocation
overhead so the common unpadded case benefits too.

Acceptance needs original and padded customer kernels, empty/sparse controls,
ordinary/special/tied/exported locals, SECONDS and locale restoration, private
parameters, native level assignments, callback traces and genuine ZLE/completion/
history/async testing with the unchanged Oh My Zsh setup. This is a core scope
system project, with an identified cost and concrete integration points.

## 2. Integer powers: a smaller algorithm replacement

The integer POWER/POWEREQ branch currently contains:

```c
for (c.u.l = 1; b.u.l--; c.u.l *= a.u.l);
```

The baseline probe uses bases 0, 1 and -1, avoiding signed overflow, with
nonnegative exponents. Nine rotated/reversed fresh-process samples per case,
CPU 13 and C.UTF-8; 50 warm powers per timer. Parsing, lookup and assignment
remain inside the timer. Expected values and state hashes are checked. Setup,
warmup and validation are excluded.

Microseconds per power for base one:

| Exponent | Time |
| ---: | ---: |
'''
for c in read('power-scaling')['cases']:
 if c['base']==1:s+=f"| {c['exponent']:,} | {c['median_us_per_power']:.3f} |\n"
s+='''
Binary exponentiation can consume exponent bits with repeated squaring, replacing
O(e) multiplications with O(log e). Bases 0/1/-1 also admit identity shortcuts.
A future implementation must preserve integer zero-to-zero, negative-exponent
promotion, FORCEFLOAT/libm behavior, overflow conventions and the result type.
It must avoid an unused final square that could overflow even when the requested
result fits. Large-case potential does not imply a benefit in the existing
application kernels, which commonly use small or floating exponents. No optimized
algorithm speedup is reported here.

## 3. Other structural opportunities and existing safeguards

| Area | Current logic | Candidate direction | Main constraint |
| --- | --- | --- | --- |
| Repeated arithmetic | `execarith()` obtains wordcode text and calls `matheval()` each execution | Cache a syntax/execution plan for stable program sites; keep values and variable lookup dynamic | Lazy lvalues, callback-driven state changes, option/locale/classification state, diagnostics and Eprog/.zwc lifetime |
| Option emulation | `installemulation()` traverses the option-name table on each reset | Precomputed masked default vectors or stable dense traversal | Retained special options, aliases, mutable native flags, output aliases and generated scanners |
| Array growth | Append requests exact pointer-vector size through `zrealloc()` | Geometric capacity for eligible interpreter-owned vectors | Native loans, invalidation/cache collisions, memory overhead and custom setters |
| Associative expansion | `paramvalarr()` scans to count, allocates, then scans to fill | Safe count bounds or one-pass materialization for ordinary tables | Generated tables, unset entries, growth during callbacks and bounded memory waste |

Arithmetic compilation has direct customer relevance: the earlier exact-release
[Endgame profile](results/round31/descriptor-pool/endgame-flat.txt) spends about
28.6% of self instructions in `mathparse()` plus
`zzlex()`. That includes validation and stack work; it is not all removable
parsing. A plan must preserve deferred reads such as `i + (i=5)` and parse/error
ordering. Prevalidating the whole expression can move errors ahead of side
effects. Reusing only successful syntax, retaining runtime conversions and
providing guarded legacy fallback are design directions, not an implementation.

Array realloc requests do not by themselves establish quadratic wall time:
allocators can extend blocks in place. Explicit geometric capacity could reduce
allocator calls; it needs measured realloc/move behavior and customer benefit.
The earlier zjson probe was approximately linear and is not contradicted by this
source-level opportunity. The associative counting callback only increments a
counter: two scans do **not** mean two value-getter invocations.

Several useful mechanisms already exist: shell functions execute wordcode,
stable conditional patterns can be cached in `Eprog.pats`, hash tables grow
fourfold, and `zhalloc()` is already an arena allocator. These are not missing
features to implement again. The opportunity is eliminating repeated necessary
work at the right layer, with ownership and invalidation accounted for.

## Evidence and unchanged state

The read-only observer is compiled separately against each host's matching SDK.
Twelve smoke combinations per host pass on pristine and installed psh; both
module load/observe/unload runs pass Memcheck with zero errors, leak checks off.
The three new Zsh workers pass syntax checking. Scaling and project drivers pin
binaries, workers, module bytes and project source hashes and check resulting
state. Own builds/tests/profilers are complete before each timing phase. External
activity is not continuously audited; samples and controls are retained.

The source review covers the named paths, not the complete source tree. The
structural index has partial C support and eight failed files; exact reads and
runtime evidence support the findings. No other-OS or fresh non-multibyte
certification was performed for these research tools.

The [evidence index](results/round32/README.md) retains every sample, command,
caller report, native receipt and compressed raw profile. Production source,
developer/installed executables, package metadata and protected stable-Zsh/startup
entries remain unchanged. The previous round's active package/OMZ certification
is reused for those unchanged artifacts; the interactive gate was not rerun for
this research-only round. The original rc0 tag, private draft and seven assets
are preserved. No binary release or optimization patch is produced.
'''
(root/'Perf/round32.md').write_text(s)
