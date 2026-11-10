# Round 35: indexed parameter-scope buckets

The twenty-seventh accepted optimization indexes parameter-table buckets that
may contain locals. Two complete installed comparisons give **7.6–8.2% less
time in coder/chat paste**, roughly **4% less in the simulation kernels**, and
**3–6% less in JSON kernels**. URL encoding takes about 0.6–1.0% more time;
that slower control is retained. These are offline project kernels, not full
application startup or a universal shell score.

The private iteration is `1.0.0-rc0-bde30291d0ec`, still Zsh 5.9.2 and rc0.
Its stripped executable is 854,680 bytes, 8 KiB above the preceding 846,488-byte
build. All 1,056 existing ELF export names/types remain, with seven new scope
helpers; four are the supported conditional native SDK API. Public structures
and existing native entry-point signatures are unchanged. There is no intended
Zsh language divergence or script migration.

## Algorithm and conservative boundaries

The [previous investigation](round34.md) saved callbacks but still walked every
bucket and node. This version keeps a private bit per real-parameter-table
bucket. New nodes mark their bucket conservatively; in-place localizations
publish their level and mark atomically through the existing signal queue.
Core growth/resize/deletion invalidates the metadata. A valid bitmap lets scope
exit skip buckets with no potentially local bindings.

The walk retains ascending bucket order, the existing successor protocol and
scan-time resize suppression. It uses the complete original `scanendscope()`
callback, including its live level check. After finishing a bucket, a raw-level
rescan retains its bit if any positive-level parameter remains. That preserves
caller locals, unset placeholders, restored shadows and future-level parameters.
The bitmap is reread after each bucket: a callback can add or promote a binding
in a later bucket without being missed. New heads in a bucket already visited
retain the ordinary scanner's behavior and remain candidates for a later exit.

The index covers the standard real parameter table. Generated providers,
nonstandard hash/comparison/mutation methods, other parameter tables, nested
scans and negative local levels use the original scanner. Uncertain metadata
is rebuilt from live entries or falls back. Allocation failure adds no shell
error; allocation/free bookkeeping preserves errno. The representation and
all generic scan functions are unchanged.

A warm eligible exit costs O(H/W + nodes in candidate buckets), where H is
bucket capacity and W is the bitmap word width. Rebuilds cost O(H + P); initial
construction, rehashing, false-positive bits and parent locals still incur work.
Worst-case walks remain linear. This is an ordered bucket index, not a journal
of locals or a claim of constant-time scope exit.

## Existing native modules remain supported

Arbitrary native code can retain a `Param` pointer and write its level directly.
It cannot safely be assumed to notify a new index. Native initialization and
constructors therefore run behind a conservative barrier. A module which does
not explicitly acknowledge the new protocol leaves that process using legacy
scope scans, even after unloading. Failed native-loading attempts can also
select that conservative fallback. Autoload declarations and already-loaded
module queries do not themselves require a barrier or rebuild.

Audited core modules and the three bundled native modules opt in explicitly.
The [SDK contract](../COMPATIBILITY.md#parameter-scope-index-and-native-opt-in)
requires standard core ownership of real-table operations and notification of
live level promotions. `psh_scope_setlevel()` is atomic; raw edits followed by
`psh_scope_mark()` require the caller's signal queue. Merely rebuilding against
a new header does not opt in. Previously built compatible modules require no
scope-related edits and are tested loading into the new core.

Awareness is a private registry keyed to the actual Module and loaded handle,
not an otherwise unused public flag bit. Reloading forgets the old identity;
freeing a Module removes registry entries and pending frame references. The
actual module is captured inside the original loader, avoiding a second lookup
through possibly changed aliases or a freed name. All bookkeeping finishes
under the loader's **original** queue, before its original unqueue can deliver
traps. Every original loader return path and outer signal boundary is retained.

The imported zdraw/zcurl/zmdown revisions and original source hashes remain in
`Vendor/sources.json`; three recorded local patches add conditional setup
acknowledgment. Ordinary Zsh-header builds skip these calls. The package verifier
still enforces every pinned file hash. Newly built psh-aware modules use the
matching psh SDK and isolated release paths; no stable Zsh module is overwritten.

## Exact installed measurements

Parent `1.0.0-rc0-56f97a85e8cb` versus new `1.0.0-rc0-bde30291d0ec`, nine
alternating samples per case, CPU 13, C.UTF-8. Result states and project/worker/
binary hashes match. Own core/module builds, tests and profiles finish before
timing; observer modules are prebuilt. The hardware launcher compiles before
its own counter measurements. A brief CPU/sibling observation is recorded;
external activity is not continuously audited. Negative time change is faster.
Customer units are milliseconds per batch; library units are per call.

| Kernel | First parent → new (ms) | Time change | Repeat parent → new | Time change |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 123.081 → 113.651 | -7.66% | 122.755 → 113.155 | -7.82% |
| zcoder.zsh/coder-layout | 5.759 → 5.707 | -0.90% | 5.775 → 5.742 | -0.57% |
| zcoder.zsh/coder-wide-layout | 66.032 → 65.229 | -1.22% | 66.229 → 65.617 | -0.92% |
| zchat.zsh/chat-paste | 217.106 → 200.650 | -7.58% | 220.615 → 202.634 | -8.15% |
| zchat.zsh/chat-layout | 5.770 → 5.747 | -0.40% | 5.788 → 5.758 | -0.52% |
| zchat.zsh/chat-wide-layout | 66.231 → 64.944 | -1.94% | 66.096 → 65.077 | -1.54% |
| endgame/endgame-world | 44.619 → 44.197 | -0.95% | 44.601 → 44.236 | -0.82% |
| z3dfx.mario/mario-race | 20.966 → 20.160 | -3.84% | 21.033 → 20.186 | -4.03% |
| z3dfx/shooter-step | 12.211 → 11.707 | -4.13% | 12.288 → 11.774 | -4.18% |
| z3dfx.agy/shooter-step | 12.305 → 11.735 | -4.63% | 12.243 → 11.783 | -3.76% |
| z3dfx.grok/shooter-step | 12.197 → 11.755 | -3.62% | 12.292 → 11.805 | -3.96% |
| zfetch/fetch-encode | 13.712 → 13.792 | +0.58% | 13.747 → 13.881 | +0.97% |
| z3dfx.drawing/drawing-binning | 13.019 → 13.015 | -0.03% | 13.086 → 13.134 | +0.37% |

| Kernel | First parent → new (ms) | Time change | Repeat parent → new | Time change |
| --- | ---: | ---: | ---: | ---: |
| JSON array | 95.701 → 91.582 | -4.30% | 96.617 → 91.798 | -4.99% |
| JSON array encoding | 212.735 → 201.046 | -5.49% | 211.923 → 204.365 | -3.57% |
| JSON validation | 92.271 → 89.395 | -3.12% | 95.176 → 89.473 | -5.99% |
| navigation | 1.952 → 1.888 | -3.28% | 2.036 → 1.920 | -5.70% |

The URL-encoding slowdown and mixed drawing control are not omitted. Parser,
search and array families also retain every slower sample. No aggregate score,
terminal painting gain, network speedup or application-startup result is claimed.

Matched final private-release profiles retain eight raw Callgrind runs, flat
views, inclusive callers and state/source fingerprints:

| Kernel | Parent instructions | New instructions | Reduction | Parent → new cleanup callbacks |
| --- | ---: | ---: | ---: | ---: |
| coder | 1,387,191,748 | 1,298,890,604 | 6.365% | 3,864,022 → 220,158 |
| chat | 2,363,622,108 | 2,193,418,996 | 7.201% | 7,606,608 → 560,391 |
| endgame | 1,144,450,047 | 1,144,584,321 | -0.012% | 6,642 → 150 |
| json-encode | 2,653,577,770 | 2,549,157,250 | 3.935% | 6,224,907 → 936,018 |

These counts cover the whole process, unlike warm batch timers. Reductions in
cleanup callbacks reflect skipped no-op global visits, not omitted restoration
callbacks. Inclusive edge extraction deduplicates repeated annotation views.
The earlier private pilot is archived separately: its gains and baseline medians
are not substituted into the installed comparison. Whole-process hardware
counters for four installed cases are fully scheduled and remain in the evidence.

## Namespace and retained-capacity controls

The matching-SDK observer is read-only and explicitly aware, so loading it does
not accidentally select the legacy path. Nine paired samples per case, rotated
and reversed case order, 4,000 warm iterations. Table counts, outer bindings and
absence of leaked locals are checked outside the timer. Cells are parent → new
**microseconds per iteration**, including dispatch and body work:

| Padding | Occupancy | Loop | Empty | One local | Eight locals | Emulate + local | Nested |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | dense | 0.482 → 0.470 | 3.839 → 3.393 | 4.307 → 3.798 | 6.445 → 5.984 | 5.639 → 4.966 | 8.848 → 7.751 |
| 512 | dense | 0.477 → 0.467 | 5.141 → 3.352 | 5.583 → 3.784 | 8.094 → 6.044 | 7.053 → 5.020 | 12.155 → 7.783 |
| 512 | sparse | 0.476 → 0.470 | 4.072 → 3.361 | 4.526 → 3.770 | 6.604 → 5.953 | 5.958 → 4.998 | 9.192 → 7.783 |
| 4,096 | dense | 0.479 → 0.470 | 15.440 → 3.389 | 16.707 → 3.820 | 18.774 → 5.996 | 18.005 → 4.992 | 37.112 → 7.803 |
| 4,096 | sparse | 0.488 → 0.474 | 5.082 → 3.417 | 5.534 → 3.831 | 7.494 → 5.860 | 6.968 → 5.016 | 11.144 → 7.845 |
| 16,384 | dense | 0.480 → 0.472 | 55.089 → 3.631 | 56.416 → 4.066 | 58.250 → 6.218 | 49.044 → 5.267 | 112.321 → 8.326 |
| 16,384 | sparse | 0.475 → 0.465 | 8.928 → 3.557 | 9.398 → 4.003 | 11.325 → 6.024 | 10.821 → 5.246 | 19.127 → 8.149 |

With 16,384 live globals, the empty-function control falls from about 55.1 to
3.63 microseconds. With those globals deleted but capacity retained, it falls
from 8.93 to 3.56. Both improve, unlike the previous scanner-only trial. This
controlled namespace result is not a fifteenfold speedup for the applications.
The H/W term and candidate-bucket collisions remain visible in the algorithm.

## Verification and retained unsuccessful work

- The final GCC candidate passes 63 upstream scripts, zero failures, two skips.
  The unchanged GCC parent has the same result. Clang parent/candidate pass
  63/0/2, and the DEBUG development build passes 62/0/3.
- The main native matrix has **28,392 scenario observations in 26 zero-error
  Memcheck processes**, leak checking disabled. Each host/locale runs 1,092
  cases: seven table sizes, three levels, ordinary/generated providers, both
  queued contexts and thirteen mutation/restoration modes. Independent expected
  callback sequences cover promotion into a later previously unmarked bucket,
  successor replacement/deletion, current/future additions, suppressed growth,
  in-place special restoration, live levels, nested read-only scans and errno.
- Tracked, unacknowledged and opaque-constructor modes pass. GCC and pristine
  comparisons cover C and C.UTF-8; Clang, DEBUG and exact installed checks extend
  the matrix. These are repeated observations, not 28,392 unique scenarios.
- Additional lifecycle tests pass under Memcheck: unloading the just-loaded
  module from a signal trap, ordinary reloads and replacing aware code with
  opaque code at the same name/path. An unrelated flag bit cannot opt a module
  in. Constructor writes are protected before setup. Four growth/shrink workers
  keep parent locals alive through actual rehashes, removal and name reuse;
  they pass on parent, candidate, pristine and DEBUG builds. Earlier installed
  native modules also load and force legacy behavior correctly.
- Broad comparisons pass: 192,360 arithmetic, 704,585 scalar, 5,192 array,
  193,236 search, 159,600 pattern, 2,640 substitution and 200,832 native floating
  API observations; 481,248 generic hash scenarios under four Memcheck processes;
  20 accessor, 36 completion PTY and 512 emulation cases. Customer correctness
  includes 24 project/locale kernels and five original project suites.
- All seven installed-package suites pass, including 190 zdraw tests. Exact
  tested native objects are staged before verification. The mandatory normal-user
  package gate passes with **24 actual OMZ sessions** using the unchanged
  re5et/git/highlighter stack, completion/history/prompt/async/Ctrl-C checks,
  installed components, startup identities, invocation modes and split symbols.

The initial bootstrap omitted acknowledgment of `zsh/main`; a tracking-state
assertion caught the resulting permanent fallback. Its passing legacy tests are
not presented as indexed certification. An early integer reentrancy counter was
optimized away by GCC; its source and disassembly are retained. The final level
setter uses Zsh's signal queue. Early module-flag registration and post-loader
bookkeeping were replaced by the private registry and original-queue finalization
before adoption. The archived early pilot is distinct from the final source.

Packaging first rejected stale vendor pins, then caught a malformed preprocessor
line in zmdown's compact setup function. Corrected source/pins and a fresh build
were used; failed work directories, logs and source remain. No verifier is
weakened, and no unsuccessful source variant or slower control is discarded.

The [41-file incremental patch](0035-indexed-parameter-scopes.patch) and source
checks replay the complete change against parent
`dcc2ed1e3023feb583303032c127624bcecb83f9`. Removing the recorded metadata hooks,
SDK acknowledgment and level-update transformations reconstructs **every changed
core file exactly**, including the original loader logic/queue boundaries,
generic scanners and cleanup body. All 1,847 pristine release files are verified,
all 1,853 canonical package inputs match, and vendor pins retain their original
revision provenance. Passing coverage is not proof of universal compatibility;
no fresh 32-bit, other-OS, non-multibyte build or allocation-failure injection is
certified.

The package activates through the isolated installer after these checks. The
preceding release's 1,603-entry manifest, 11,828 protected stable-Zsh/startup
entries, `/etc/shells`, account login shell and personal configuration remain
unchanged. Existing processes retain their prior release paths. The project
stays private rc0; the original tag, draft and seven assets are preserved.
The [evidence index](results/round35/README.md) binds validation, timing and
installation to the exact source and executable.
