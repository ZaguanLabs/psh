# Round 59: validate unlock arithmetic before narrowing

Round 58 protects the exported helper's int domain. Its system-module caller
still narrowed arbitrary arithmetic results before calling it. On this host,
`zsystem flock -u -- 'fd + 4294967296'` can therefore unlock `fd`. Independent
POSIX lock observations confirm this in pristine Zsh 5.9.2 and preceding psh.

The caller now evaluates to mnumber, checks evaluation errors, validates the
original integer or floating value, then converts to int. For floats, the open
interval `(INT_MIN - 1, INT_MAX + 1)` preserves truncation toward zero for every
representable result. Ordered comparisons reject NaN and infinities. Integer
bounds are checked without conversion to floating point. The helper itself,
lock ownership and native ABI are unchanged.

Out-of-range values now return status 1 with a range diagnostic before closing
any descriptor. Existing expression side effects occur once. Arithmetic errors
stop before conversion. Supported fractions and negative values retain their
previous behavior, including `-0.9` truncating to zero and `-2147483648.9`
truncating to INT_MIN. COMPATIBILITY.md records the new rejection and migration.

## Evidence

The extended lock-close oracle keeps two private POSIX record locks and an
unrelated descriptor open. A pipe handshake lets Python independently check
both locks while the shell is alive after the unlock attempt. All acquisitions
use zero timeout and processes have bounded deadlines. Loaded module paths and
hashes are verified. Tests cover two locales, three arithmetic option settings,
and close-on-exec/retained-on-exec locks.

| Build | Cases | Failed expected rejections | Ordinary control differences |
| --- | ---: | ---: | ---: |
| Preceding psh | 396 | 168 | reference |
| Pristine Zsh, alias cases only | 48 | 48 | n/a |
| Candidate release | 396 | 0 | 0 |
| Candidate instrumented system module | 396 | 0 | 0 |

The complete matrix contains 228 previously supported cases and 168 range
rejections. Of the existing cases, the 132 nonnegative-result controls are
compared automatically against the preceding build; 96 negative-result cases
retain the independent expected status, diagnostics category and lock state.
All 48 pristine alias cases close a real lock instead of rejecting the wide
expression. Do not interpret all 168 preceding-build failures as unintended
unlocking: some merely have the wrong diagnostic or acceptance behavior.

The module-only instrumented build enables undefined-behavior and float-cast
checks with recovery disabled. It passes the entire matrix. A further 48 alias
cases run under Memcheck. Four malformed/divide-by-zero expressions have equal
stdout/stderr/status before and after; those exit before the planned EXIT trap,
so that probe does not establish intermediate lock state or trap behavior.

V14 adds a lasting regression for wide, huge, infinite and NaN unlock arguments,
followed by successful fractional unlocking of the original descriptor. Full
upstream validation passes 62 scripts, zero failures and three skips. All 24
unchanged OMZ terminal sessions match; framework sources are unchanged. Results
are retained with the evidence.
This is correctness work with no speedup claim. Validation is Linux x86-64;
other numeric type widths and platforms are not certified. Installed rc2 remains
active; full isolated packaging/native-library checks are required for activation.

## Reproduction

```sh
python3 Perf/check-lock-close.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --wide \
  --output .work/round59/candidate.json
```

Use `--aliases-only` for a bounded reference check of the actual wrong-lock
operation, and add `--memcheck` for the candidate memory check. The wider matrix
should use the round-58 helper fix when testing the preceding caller; pristine
negative table access is a separate known defect. `--native` remains limited to
the helper's int domain. Source identities, build commands, raw results and the
candidate patch are retained under `Perf/results/round59`.
