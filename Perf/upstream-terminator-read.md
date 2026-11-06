# Existing scalar-search terminator read

Round six's expanded Memcheck coverage found an out-of-bounds read in both
**untouched Zsh 5.9.2** and the psh candidate. This is separate from the scalar
character-count optimization. The user submitted the report upstream;
Mikael Magnusson supplied a fix.
The two search-loop bounds guards are now backported separately from the
performance changes. The original release baseline remains untouched.

A standalone, ready-to-send [bug report](bugs/scalar-search-terminator/report.txt)
and reproducer/full pristine Memcheck log are now available. The verified
reporting address is `zsh-workers@zsh.org`, as listed in the
[official mailing-list documentation](https://zsh.sourceforge.io/Doc/Release/Introduction.html#Mailing-Lists).

From the project root, the minimal reproducer is:

```sh
LC_ALL=C.UTF-8 valgrind --error-exitcode=97 --leak-check=no \
  .work/baseline/Src/zsh -dfc 's=a; print -r -- "${s[(in:2:)*]}"'
LC_ALL=C.UTF-8 valgrind --error-exitcode=97 --leak-check=no \
  .work/candidate/Src/zsh -dfc 's=a; print -r -- "${s[(in:2:)*]}"'
```

Historically both printed `2` and Memcheck exited with status 97. With the
backport, the candidate still prints `2` and exits with status 0 under Memcheck;
the release baseline retains its original diagnostic. The accessed address is
immediately after the two-byte
allocation containing `a` and its terminating NUL. The diagnostic points to
`mb_metacharlenconv()` called from `getarg()`'s forward first-subscript path.

The pattern's second match occurs at the string terminator. That path advances
by `MB_METACHARLEN()` before calculating the next character's width. The width
of NUL is one in the existing converter, so this subsequent conversion reads
past the allocation. At discovery the pristine and candidate function stacks agreed; source
line numbers differ because of the preceding psh changes.

An initial Memcheck run stopped at the first failing matrix. A second harness
continued after every child status to complete all 84 scalar search/range
matrices. At discovery pristine and candidate produced identical output bytes, matching
function stacks and per-matrix error counts: **520 invalid reads across 36
matrices**, with no additional reported error context in the candidate.
The parent process itself reports zero errors; that does not make the child
matrices clean. The comparison explicitly includes their reports.

The harness, both complete Memcheck logs, minimal-reproducer logs and comparison
metadata are retained under [`results/round6/`](results/round6/), particularly
[`memcheck-comparison.json`](results/round6/memcheck-comparison.json). Leak
checking was disabled. These results do not establish the absence of other
memory errors or undefined behavior.

## Maintainer fix backported on 2026-11-06

Mikael's patch, supplied in the conversation with subject “PATCH: check we
didn't advance past the end of string in getarg's search loops”, guards the
`prevcharlen` and `nextcharlen` updates with `lastpos <= de` and `t <= de`
after advancing over the matched character. Returned offsets are unchanged.
The [backport patch](upstream-terminator-fix.patch) credits its author. An
upstream commit ID was not supplied; the patch text is the provenance used
here. No development-HEAD rebase is involved.

The minimal reproducer retains output `2` with zero Memcheck errors. All 84
saved matrices now report zero errors, including child processes; the previous
520 reads are gone. Output bytes match the archived run after replacing its
36 Valgrind-induced failure statuses with success statuses. The 193,236 search
and 28,394 scalar read/write comparisons still match the release baseline.
Full upstream tests and no-multibyte substitution checks pass. Scope is the
saved corpus, not a claim that every shell workload is Memcheck-clean.

Evidence and hashes: [results/upstream-terminator-fix/](results/upstream-terminator-fix/).
Historical round-six through round-nine error logs are retained unchanged.
