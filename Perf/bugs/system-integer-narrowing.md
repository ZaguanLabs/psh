# zsh/system narrows integer options before checking their range

Reproduced on Linux x86-64 with the retained pristine Zsh 5.9.2 build,
installed psh rc2, and the preceding round-48 candidate. This is inherited
behavior, not a psh-only incompatibility. Current upstream source inspected
on 2026-11-15 has the same conversion in `getposint()`:
https://raw.githubusercontent.com/zsh-users/zsh/master/Src/Modules/system.c
That is source inspection, not execution of current upstream Git. Whether
this has already been reported has not been established. No report was sent.

## Reproducer

With 32-bit `int` and 64-bit `zlong`:

```sh
printf X | zsh -dfc 'zmodload zsh/system; sysread -i 4294967296 -s 1; rc=$?; print -r -- "$rc:$REPLY"'
```

Actual output: `0:X`. The invalid descriptor aliases descriptor zero and
consumes input. Expected: parameter error (status 1), without consuming input.
The candidate emits `integer expected: 4294967296` and prints `1:`.

`getposint()` converts `zstrtol()`'s `zlong` result to `int` before checking
whether it is negative. On the tested platform values such as 2^32 + fd and
-2^32 + fd become the live descriptor `fd`. Four options can perform I/O
on the wrong descriptor: `sysread -i`, `sysread -o`, `syswrite -o`, and
`sysseek -u`. The same helper lets `sysread -s` silently wrap a buffer size.
The C conversion is implementation-defined when the value is not representable;
the concrete wraparound behavior above is established on the tested host.

## Candidate fix and evidence

Retain the result as `zlong`, check `0 <= ret <= INT_MAX`, then cast to `int`.
Keep the existing parser, warning text, parameter validation order, and return
status. No interface or ABI changes are involved. Correctly rejecting formerly
aliased arguments is an intentional bug correction.

`Perf/check-system-integers.py` uses temporary files, inherited descriptors and
Python inspection of shared file offsets and output bytes. Rejected operations
must also leave result/count variables untouched. All three controls fail 40
of 90 rejection checks; the candidate passes all 90. Another 114 lexical and
boundary controls match exactly across all four builds. The matrix covers C
and C.UTF-8. Huge buffer allocations are deliberately excluded from controls.

The upstream-style regression in `Test/V14system.ztst` covers all five options
with positive and negative aliases, then verifies intact input and output.
Compressed results, executable hashes and loaded module hashes are retained
under `Perf/results/round49/`.

This is a narrow fix for conversion of the parsed value. It does not redesign
`zstrtol()`'s overflow/truncation behavior for arbitrarily large strings, certify
32-bit builds, or fix other conversion sites such as `systell()` and timeout
arguments. Those need independent characterization. The candidate is not
installed or published.
