# zsystem flock accepts a NaN retry interval

Confirmed in the local pristine Zsh 5.9.2 release build and the preceding psh
module. This finding has not been checked against the current upstream Git tip.

`bin_zsystem_flock()` multiplies `-i` by one million, rounds with ceil, rejects
values below 1 or above `0.999 * LONG_MAX`, and converts the result to long.
Both rejection comparisons are false for NaN. Its conversion to long has no
defined result. The initial module-only UBSan run reports:

```
system-before.c:676:43: runtime error: -nan is outside the range of representable values of type 'long int'
```

## Minimal bounded reproducer

Create a private, writable temporary file first, then run in a fresh shell:

```zsh
zmodload zsh/system
fd=unchanged
zsystem flock -t 0 -i NaN -f fd /path/to/private/temporary/file
print -r -- "$?:$fd"
```

The zero timeout prevents waiting for another holder. A fresh process releases
its locks on exit. On the tested pristine release build this succeeds and
assigns a descriptor; the candidate returns `1:unchanged` and warns that the
interval is invalid. This reproducer should not use a real application's lock.

## Correction and evidence

Require both ordered range comparisons to succeed before the integer cast:
`value >= 1 && value <= 0.999 * LONG_MAX`. This rejects NaN and preserves the
acceptance range of ordinary numbers, including ceil rounding of tiny positive
intervals. It uses the existing error path and diagnostic. The `-t` parsing
and acquisition/retry loops are unchanged.

`Perf/check-flock-interval.py` performs 276 bounded tests on a private file.
Python independently checks POSIX lock ownership while the shell is paused at
a pipe handshake. The test also checks target descriptors, the destination
variable, expression side effects and exact diagnostics. See [round 57](../round57.md)
for controls and validation. No report has been sent by the agent.
