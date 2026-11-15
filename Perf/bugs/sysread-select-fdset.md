# Timed sysread overflows select's fixed descriptor set

`bin_sysread()`'s select fallback constructs `fd_set fds` on the stack and
passes `infd` to `FD_SET()` without checking `FD_SETSIZE`. `getposint()` accepts
nonnegative descriptors much larger than that set's capacity. On the tested
Linux x86-64 host, descriptor 1024 is already beyond the 0..1023 range.

Reproduced with pristine Zsh 5.9.2 sources and matching baseline headers/shell,
and with the preceding psh candidate. Both private module builds force the
existing select branch by undefining HAVE_POLL after including configuration
headers. They use `-fsanitize=undefined,float-cast-overflow`; the shell itself
is not instrumented. This tests the fallback on Linux, not a native non-poll
operating system. Normal Linux poll builds do not have this FD_SET failure.

With a real readable file inherited as descriptor 1024:

```zsh
zmodload zsh/system
sysread -i 1024 -t 0 -s 1
```

The sanitizer reports an out-of-bounds array index in the FD_SET expansion.
Descriptor 4096 also fails. The same descriptors work without `-t`, and in
the poll build. This is memory-unsafe behavior, not a supported large-FD API
for the select fallback.

## Correction

Before FD_ZERO/FD_SET, reject `infd >= FD_SETSIZE` with status 1 and
`file descriptor out of range for select: N`. This preserves the representable
descriptor range, poll behavior, and untimed reads. No native ABI changes.

The guard intentionally precedes timeout arithmetic. For an unsupported FD,
`-t '(++side, 0)'` leaves `side` unchanged. Ordinary command expansions still
occur before builtin entry. To migrate, use a descriptor below FD_SETSIZE or
a poll-enabled build; removing the timeout is only appropriate if blocking
without a timeout is acceptable to the caller.

## Evidence

`Perf/check-sysread-select-fds.py` creates real descriptors immediately below,
at, and above the boundary. It checks data, offsets, result/count parameters,
timeout-expression side effects and exact diagnostics under C and C.UTF-8.
The host's FD_SETSIZE is verified from the compiler's system headers. No
resource limits are changed, and occupied descriptors are never overwritten.

Pristine and preceding-candidate instrumented select modules fail 8/18 cases.
The corrected instrumented select module passes all 18 with no diagnostics
from the sanitizer. Installed rc2 and the candidate poll build pass all 18.
The broader timeout probe still diagnoses separate conversion overflows;
this patch does not fix or conceal those findings.

Evidence and build commands are retained in `Perf/results/round51/`.
This is an uninstalled research change. No upstream report has been sent,
and whether this was previously reported has not been established.
