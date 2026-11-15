# Negative lock descriptors read before the descriptor table

Confirmed in the pristine Zsh 5.9.2 release source and the preceding psh core.
The current upstream Git tip has not been checked.

The exported `zcloselockfd(int fd)` helper rejects descriptors greater than
`max_zsh_fd`, then indexes `fdtable[fd]`. It has no lower-bound check. A negative
argument can read outside the descriptor table before returning the expected
ordinary error. This affects both the system-module caller and native callers
of the exported helper.

## Bounded reproducer

```sh
valgrind --quiet --tool=memcheck --error-exitcode=99 --leak-check=no \
  /path/to/pristine/zsh -dfc \
  'zmodload zsh/system; zsystem flock -u -- -1; print -r -- "status=$?"'
```

This uses no lock files. Both tested reference cores print `status=1` with the
usual not-in-use diagnostic, but Memcheck also reports:

```
Invalid read of size 1
  at zcloselockfd (utils.c:2146)
Address ... is 1 bytes before a block of size 64 alloc'd
```

The ordinary error result alone therefore does not establish correctness.
Other negative values can behave differently depending on surrounding memory;
no claim is made that their reference behavior is defined.

## Correction

Reject `fd < 0` alongside the existing upper-bound check, before accessing the
table. This preserves the native signature, error return, errno, and all valid
lock-close behavior. It does not change system-module arithmetic parsing or
fix its separate narrowing of wide numeric values.

[Round 58](../round58.md) retains independent lock/descriptor observations,
direct native-interface checks, memory checks and unchanged OMZ evidence.
No report has been sent by the agent.
