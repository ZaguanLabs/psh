# Nested associative getters replace the outer expansion's result

Reproduced locally on pristine Zsh 5.9.2 and psh's preceding accepted release
on 2026-11-12. This report concerns those binaries; upstream Git has not been
checked. It has not been sent upstream.

An associative element's native scalar getter can call `gethparam()` for a
different associative parameter. The outer `gethparam()` then returns the
inner parameter's values. No changes to public structures or unsupported
private symbols are required to reproduce this.

## Reproducer

The test module is [hash-reentry-module.c](../hash-reentry-module.c). Build it
against a configured pristine source tree and run it through the accompanying
driver. Substitute the paths to your source/build trees and executable:

```sh
python3 Perf/check-hash-reentry-module.py /path/to/zsh/Src/zsh \
  --headers-build /path/to/zsh-build \
  --headers-source /path/to/zsh-source \
  --memcheck --output /tmp/hash-reentry.json
```

The core reproduction is:

1. Create `outer=(a A b B)` and `inner=(x X y Y)` associative parameters.
2. Give `outer[a]` a scalar GSU whose getter calls `gethparam("inner")`, then
   returns `strgetfn(pm)`. Keep the standard setter and unsetter.
3. Call `gethparam("outer")`.

Expected: two outer values, `A` and `B`, in unspecified hash iteration order.
Observed on both tested hosts: `X` and `Y`.

```text
count=2 calls=1 ok=0
unexpected[0]=X
unexpected[1]=Y
```

The driver exits nonzero on the affected binaries. Memcheck reports no invalid
access for this basic reproducer; the confirmed defect is an incorrect result,
not a demonstrated memory-corruption report. The fixture avoids running its
later pattern cases on a host that fails this first check.

## Cause and candidate fix

`paramvalarr()` and `scanparamvals()` share static `paramvals` and
`numparamvals`. Calling another associative expansion during `getstrvalue()`
overwrites the outer output pointer and count. A nested pattern expansion can
also replace or clear `scanprog`, `scanstr` and `foundparam`.

The candidate saves/restores the output state around each materialization and
the pattern state across each element getter. An internal helper returns the
result count explicitly to `getvaluearr()`: merely restoring the global count
is insufficient because that caller previously used it as a result channel.
The existing `paramvalarr()` signature and native layouts remain unchanged.

The extended fixture checks zero, one, three, 65, 4,096 and 4,097 inner
elements, three nested getter levels, key/value expansions, successful and
empty pattern matches, unset elements, custom scan providers and balanced
signal-queue depth. It compiles against pristine headers and runs under
Memcheck. The fixed output is:

```text
count=2 calls=1 ok=1
pattern-ok=1
matrix-checks=12 ok=1
boundary-checks=2 ok=1
```

This fix does not establish safety for arbitrary table destruction, growth
during getters or nested mutation of the same table. Those are separate
ownership and scanner questions. The separate count-bound performance trial
is not needed to fix the reproduced bug.
