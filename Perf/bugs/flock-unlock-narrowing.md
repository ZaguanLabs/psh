# Wide unlock arithmetic can close a different lock descriptor

Confirmed locally in pristine Zsh 5.9.2 and psh before round 59. The upstream Git
tip has not been checked and no report has been sent by the agent.

The flock unlock branch converted mathevali's zlong result to int before calling
zcloselockfd. On the tested Linux x86-64 host, a value such as `fd + 4294967296`
wraps to `fd` and unlocks that actual lock. The existing helper bounds check sees
only the wrapped value. Floating arguments also pass through an unchecked
float-to-zlong conversion before int narrowing.

A bounded reproducer in a fresh shell with a private temporary file:

```zsh
zmodload zsh/system
zsystem flock -t 0 -f fd /path/to/private/temporary/file
zsystem flock -u -- 'fd + 4294967296'
print -r -- "wide:$?"
zsystem flock -u -- fd
print -r -- "actual:$?"
```

The tested reference reports wide:0 then actual:1. The candidate reports wide:1
with a range diagnostic, then actual:0. The maintained Python harness also
checks live lock ownership independently using POSIX record locks.

The correction validates the original mnumber before integer conversion,
preserves fractional truncation and single evaluation, and rejects nonfinite or
out-of-range values before closing anything. See [round 59](../round59.md) for
compatibility, test coverage and limitations.
