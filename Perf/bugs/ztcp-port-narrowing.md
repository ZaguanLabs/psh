# ztcp truncates numeric ports before endpoint I/O

Confirmed locally in pristine Zsh 5.9.2 and psh round 65 on Linux x86-64.
Current upstream Git has not been checked and no report has been sent.

Numeric listener and outbound ports went through `htons(atoi(argument))`.
Consequently `65536 + port` selected the existing `port` on this host. Larger
wraparounds and negative values could also produce a different valid port.
These values describe the wrong endpoint, rather than an invalid unused port.

## Reproducer

```sh
python3 Perf/check-ztcp-ports.py \
  --shell .work/round66/previous-build/Src/zsh \
  --modules .work/round66/previous-runtime/lib/zsh/5.9.2 \
  --output before.json
```

The listener case asks for an alias of a private kernel-selected loopback port,
then Python independently connects to the actual port. The outbound case
reverses this: Python owns the listener and observes whether Zsh connects to it.
Before correction, those independent connections succeed through wide aliases
in both directions and both tested locales.

## Correction

Parse numeric ports as `zlong`, rejecting negative values and values above 65535
before `htons()` or socket creation. Service names still take their existing
system-database path. Valid numeric prefixes are retained deliberately. Zero
was already rejected for listeners; outbound zero and nonnumeric cases retain
their existing connection-failure behavior.

This does not change default-port selection or descriptor validation. Evidence
uses private IPv4 loopback only, not external hosts or IPv6. See
[round 66](../round66.md) for compatibility and validation details.
