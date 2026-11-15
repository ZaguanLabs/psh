# zselect can report readiness for an aliased descriptor

Reproduced in the retained pristine Zsh 5.9.2 build, installed psh rc2 and
the preceding research candidate on Linux x86-64 with 32-bit int. The problem
is inherited from the reference source; novelty or current upstream Git status
has not been established. No report has been sent.

Safe reproducer, with ready stdin:

```sh
printf X | zsh -dfc 'zmodload zsh/zselect; reply=(sentinel); zselect -t 0 -r 4294967296; print -r -- "$?:$reply"'
```

The reference reports `0:-r 0`: the oversized number aliases descriptor zero.
The candidate emits a range diagnostic and prints `1:sentinel`. Unlike the
sysread select fallback issue from round 51, zselect already checks FD_SETSIZE;
its mistake is checking after converting zlong to int.

The fix retains the parsed zlong until after range and trailing-input checks.
It then converts to int for FD_SET. The diagnostic uses Zsh's `%z` formatter
to print the parsed value, preserving ordinary in-range diagnostic formatting
while avoiding another narrowing conversion just for the message.

The intentional differences are earlier rejection of oversized descriptors,
full-width numeric diagnostics, untouched readiness results on rejection and
any resulting status-dependent control flow. A range failure still precedes
the trailing-garbage check. All ordinary parser loops, option order, output
selection and timeout logic stay in place. Scripts should supply the real
descriptor and check status before using results. No native ABI change.

The matrix covers default reply, named arrays, associative results and -A
precedence over -a; separate/attached read options, write/exception sets and
mixed descriptor lists; ordinary lexical errors, boundaries and wide values;
and C/C.UTF-8. All children use a zero timeout and a seekable temporary stdin.
Python verifies its offset remains unchanged. Cases compare status, diagnostics
and all output parameters, including preservation of unrelated outputs.

References fail all 240 wide-input checks (72 report success; the remainder
also fail the required full-value range diagnostic and/or error classification).
The candidate passes all 240. All 520 ordinary controls match all references.
The 760-case total is focused coverage, not a universal compatibility metric.

This checks the result produced by zstrtol; it does not redesign arbitrary-
length numeric parsing or certify other architectures. Reports record loaded
module paths/hashes as well as the main executable. See [round 54](../round54.md).
