# systell converts descriptors before validating their range

This is another site in the integer-conversion family investigated in round
49. It is reproduced in pristine Zsh 5.9.2, psh rc2, and the preceding research
candidate on Linux x86-64. No claim is made about whether it has been reported
previously. No report has been sent.

## Safe reproducer

```zsh
zmodload zsh/system
(
  print -rn ABC > input
  exec 0< input
  sysseek 2
  print -r -- $(( systell(4294967296) ))
)
```

Run this in a temporary directory. The result is `2`: the oversized integer
aliases descriptor zero. The candidate instead reports the existing
`file descriptor out of range` error and aborts the arithmetic expansion.
Negative integer multiples of 2^32 can alias a live descriptor as well.
`systell()` queries position; this reproducer does not modify the file offset.

There is also undefined behavior in the floating branch. Converting values
such as `2147483648.0`, `1e300`, `Inf` or `NaN` to a 32-bit `int` is outside
the defined C conversion range. A private module compiled with
`-fsanitize=undefined,float-cast-overflow` diagnoses it even when the normal
build happens to report the expected error afterward.

## Fix and compatibility

Validate integer arguments against `[0, INT_MAX]` before conversion. For
floating arguments, require `-1 < value < INT_MAX + 1` before truncation.
Ordered comparisons also reject NaN and infinities without casting them.

The lower bound deliberately preserves `systell(-0.9) == systell(0)`.
Likewise, representable positive fractions still truncate toward zero. The
existing diagnostic, arithmetic-error propagation, single evaluation of the
argument, and `-1` result for closed/nonseekable descriptors remain intact.
There is no native ABI change.

The oracle in `Perf/check-systell.py` covers ordinary arithmetic,
`FORCE_FLOAT`, `C_PRECEDENCES`, C and C.UTF-8 locales, two seekable descriptors,
a pipe, a closed descriptor, and expression side effects. All three normal
references fail 16 of 84 rejection cases. The candidate passes all 84, and
134 compatibility controls match all references exactly. The instrumented
preceding module has 60 diagnosed conversion errors plus the 16 integer
aliasing failures; the instrumented candidate passes all 218 cases.

Instrumented coverage applies to `system.c`, not the entire shell. Loaded
module paths and hashes are checked and recorded. The initial instrumented
attempt lacked the module's error-name table and fell back to the reference
module; that attempt is retained but excluded from sanitizer evidence. The
harness now restricts the module search path for instrumented runs and rejects
unexpected provenance.

Full validation and remaining timeout-conversion findings are in
[round 50](../round50.md). This is an uninstalled research candidate.
