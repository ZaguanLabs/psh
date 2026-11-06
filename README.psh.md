# psh — Performance SHell

Local performance work on the Zsh 5.9.2 release source. **Observable Zsh
behavior is the compatibility contract.** Optimizations must preserve expansion,
quoting, options and emulation, dynamic scope, arithmetic effects, diagnostics,
exit status, traps, and signal handling. Public API/ABI changes require separate
review. Test results are evidence of compatibility, not proof of equivalence.

The local executable is `./psh`. Upstream build targets, `ZSH_VERSION`, module
names (`zsh/*`), startup filenames and version reporting retain their Zsh
identities. The executable's invocation name naturally appears as `psh`.
The original upstream README and licence are retained.

```sh
python3 Perf/build.py
./psh -dfc 'print -r -- "$ZSH_VERSION"'
```

This builds inside `.work/` and publishes `./psh`; it does not install a system
shell. In a clean clone, the build script restores `.work/pristine` from the
`upstream/zsh-5.9.2` tag and checks every source file against the committed
`Perf/upstream-sha256.json` manifest. Existing snapshots are verified against
the same manifest. The baseline is never constructed from the optimized HEAD.
Shallow clones may need `git fetch origin tag upstream/zsh-5.9.2` first.

See [the performance workflow](Perf/README.md),
[the source-review map](Perf/audit.md), and
[the first source/test patch](Perf/0001-short-prefix-array-replacement.patch).
The [second experiment](Perf/round2.md) covers bounded scalar copying;
its [patch](Perf/0002-bounded-scalar-copy.patch) applies after the first.
The [third experiment](Perf/round3.md) accelerates scalar index traversal;
its [patch](Perf/0003-scalar-index-widths.patch) applies after the second.
The [fourth experiment](Perf/round4.md) reuses an array append's known length;
its [patch](Perf/0004-array-append-length.patch) applies after the third.
The [fifth experiment](Perf/round5.md) avoids a full length scan before forward
array pattern searches; its [patch](Perf/0005-forward-array-search.patch) applies
after the fourth.
The [sixth experiment](Perf/round6.md) skips an unnecessary character count for
scalar pattern searches from the beginning; its
[patch](Perf/0006-scalar-search-length.patch) applies after the fifth.
The [seventh experiment](Perf/round7.md) skips Meta-free prefixes while counting
metafied byte spans; its [patch](Perf/0007-metafied-length-prefix.patch) applies
after the sixth.
The [eighth experiment](Perf/round8.md) removes unused backtracking storage for
eligible terminal stars; its [patch](Perf/0008-terminal-star-matching.patch)
applies after the seventh.
The [ninth experiment](Perf/round9.md) skips ASCII runs with bounded word loads
inside eligible terminal stars; its
[patch](Perf/0009-terminal-star-ascii-words.patch) applies after the eighth.

The first change accelerates size-preserving replacements within the first
32 elements of ordinary indexed arrays. It introduces no array-length cache or
storage-format change. Array append scaling remains an open investigation.

The second change copies only the selected scalar bytes after Zsh's existing
index normalization, instead of copying the remaining suffix and truncating it.
Measurements for the second
compare against the preserved first psh executable, not pristine Zsh.

The third change avoids general conversion calls for ASCII and byte-mode
characters while locating scalar indices. The conversion-state and offset rules
remain the same. The third
experiment compares against the preserved second psh executable.

The fourth change removes a redundant length scan within ordinary whole-array
list append. It introduces no persistent cache and leaves special/custom/tied
arrays on the original path. Repeated append remains quadratic. The current
executable includes all nine changes; the fourth experiment compares against
the preserved third executable. Its application controls include small measured
slowdowns as well as the targeted append gains; see the complete report.

The fifth change walks directly to a nonnegative search start, stopping at an
early match or deriving the missing index from the array terminator. Negative
starts, backward searches, scalar and associative searches retain their existing
paths. The fifth experiment compares against the preserved fourth executable.

The sixth change uses the existing nonempty-string check to establish the start
bound for a forward scalar pattern search from the beginning. Other starts and
backward searches retain their full character count. Matching and byte-offset
conversion still perform their existing work. Its measurements compare against
the preserved fifth executable.

The seventh change uses a bounded standard-library search for the first
internal Meta escape, retaining the original escape-pair handling afterward.
It is shared by matching and editor callers. Its measurements compare against
the preserved sixth executable. The existing scalar-search memory issue has a
[ready-to-send upstream report](Perf/bugs/scalar-search-terminator/report.txt)
and [attachment bundle](Perf/bugs/scalar-search-terminator-report.tar.gz).

The eighth change handles a star followed immediately by the matcher's end
marker without a character-boundary buffer. Multibyte traversal preserves its
conversion state; byte mode advances directly to the end. On heap-allocation
builds, unqueued calls retain the original path and its signal boundary.
Measurements compare against the seventh executable and include small measured
slowdowns alongside the targeted gains.

The ninth change skips groups of eight bytes whose high bits are all clear,
using bounded unaligned-safe loads. Non-ASCII bytes retain the existing converter
and its state; embedded NUL remains a byte in bounded matcher input. Platforms
without an exact 64-bit unsigned type and eight-bit bytes use scalar traversal.
Measurements compare against the eighth executable and include unchanged
application controls and a slower short late-match benchmark.
