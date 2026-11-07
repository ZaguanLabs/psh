# Mario race reset accumulates track length

Observed while adding the Mario simulation to psh's customer benchmarks on
2026-11-07. Reproduced with the untouched Zsh 5.9.2 release executable and with
psh. This is an application reset issue, independent of the shell optimization.

```zsh
zsh -dfc '
  zmodload zsh/mathfunc
  source /path/to/z3dfx.mario/lib/track.zsh
  source /path/to/z3dfx.mario/lib/engine.zsh
  race-reset
  print -r -- first=$track_length
  race-reset
  print -r -- second=$track_length
'
```

Observed output:

```text
first=448.36574769
second=896.73149539
```

`track-build()` clears its track arrays and initializes `track_s` with zero,
but retains `track_length` before adding every segment's length. `race-reset()`
calls it again. A second reset adds the same circuit length again and produces
a large first interval in `track_s`, affecting subsequent track positioning.
The expected result is the same circuit length and segment positions on every
reset. Resetting `track_length=0` at the start of `track-build()` is the apparent
application fix; it has not been applied to the Mario repository here.

The performance harness restores the original global before each untimed
simulation reset and checks the track and elapsed simulation time. The initial
benchmark samples are retained as `pre-reset-*`; only corrected samples are
used in the round-fourteen table. The pristine-shell reproducer output is
saved in [the evidence](../results/round14/mario-reset-reproducer.log).
