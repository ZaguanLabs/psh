# Existing scalar-search terminator read

Round six's expanded Memcheck coverage found an out-of-bounds read in both
**untouched Zsh 5.9.2** and the psh candidate. This is separate from the scalar
character-count optimization. It has not been patched or reported upstream
as part of this local work.

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

Both print `2`. Memcheck reports one invalid read of size one and exits with
status 97 on each. The accessed address is immediately after the two-byte
allocation containing `a` and its terminating NUL. The diagnostic points to
`mb_metacharlenconv()` called from `getarg()`'s forward first-subscript path.

The pattern's second match occurs at the string terminator. That path advances
by `MB_METACHARLEN()` before calculating the next character's width. The width
of NUL is one in the existing converter, so this subsequent conversion reads
past the allocation. The pristine and candidate function stacks agree; source
line numbers differ because of the preceding psh changes.

An initial Memcheck run stopped at the first failing matrix. A second harness
continued after every child status to complete all 84 scalar search/range
matrices. Pristine and candidate produce identical output bytes, matching
function stacks and per-matrix error counts: **520 invalid reads across 36
matrices**, with no additional reported error context in the candidate.
The parent process itself reports zero errors; that does not make the child
matrices clean. The comparison explicitly includes their reports.

The harness, both complete Memcheck logs, minimal-reproducer logs and comparison
metadata are retained under [`results/round6/`](results/round6/), particularly
[`memcheck-comparison.json`](results/round6/memcheck-comparison.json). Leak
checking was disabled. These results do not establish the absence of other
memory errors or undefined behavior.

A correction needs a separate review of end-of-string widths and subscript
results, including scalar assignments and range boundaries. The performance
patch preserves the existing matcher and offset calculations; the ordinary
193,236-search differential matrix also matches pristine behavior.
