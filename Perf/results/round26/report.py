from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round26'
read=lambda n:json.loads((l/(n+'.json')).read_text())
def key(x):return x.get('case',x.get('operation',x.get('name')))
def paired(a,b):
 assert [key(x) for x in a['cases']]==[key(x) for x in b['cases']]
 return '\n'.join(f'| {key(x)} | {x["median_ms"][0]:.3f} → {x["median_ms"][1]:.3f} | {y["median_ms"][0]:.3f} → {y["median_ms"][1]:.3f} |' for x,y in zip(a['cases'],b['cases']))
def single(d):return '\n'.join(f'| {key(x)} | {x["median_ms"][0]:.3f} → {x["median_ms"][1]:.3f} |' for x in d['cases'])
hardware=[]
for c in read('hardware')['cases']:
 x,y=c['median_scaled_events'];hardware.append(f'| {c["case"]} | {x["cycles"]:,.0f} → {y["cycles"]:,.0f} | {100*(1-y["instructions"]/x["instructions"]):.2f}% |')
profiles=read('endgame-profiles');old=next(x for x in profiles if x['name']=='previous-endgame');new=next(x for x in profiles if x['name']=='resume-endgame');assert old['source_sha256']==new['source_sha256'] and old['output_state_sha256']==new['output_state_sha256']
s='''# Round twenty-six: decimal prefixes without restarting conversion

The twenty-fourth accepted optimization accelerates ordinary positive decimal
conversion in `zstrtol_underscore()`. A complete bounded decimal returns directly;
a continuation seeds the original conversion loop with the validated prefix.
It does not restart that loop from the beginning.

The [incremental patch](0026-decimal-prefix-conversion.patch) applies after
`402746ade22e5a9e8fc80702d4bce53455a62d06`. Version **1.0.0-rc0**, public
interfaces, structures, array ownership and intended language behavior remain
unchanged. The original truncation rules and diagnostic bytes are preserved.

## Profile and invariant

Fresh profiles use the actual installed `1.0.0-rc0-d9a609a3adc3` and the author's
projects. Endgame spends **59,648,781 self instructions**, about **5.2%**, in
integer conversion. Most of the function supports signs, base selection,
underscores and truncation; ordinary short positive decimals need less work.

The new path requires **explicit base 10** and a first byte that the live public
classification table does not consider a leading blank. It reads literal decimal
digits, bounded at **18 on 64-bit-or-wider `zlong`, nine on 32 bits**. Even the
largest prefix fits the signed type, including intermediate arithmetic. The
bound comes from integer capacity, not storage layout or a cache assumption.
A non-decimal continuation returns the value/end pointer directly unless an
underscore is enabled and needs further parsing.

Otherwise a nonempty prefix transfers four values into the original loop:
`calc` is its accumulated value, `inp` is the original input pointer, `s` is the
first unprocessed byte and `neg` is zero. The prefix contains no sign or skipped
leading blank and cannot have truncated. These are exactly the states the
original loop would have reached there. Its digit/underscore processing,
unsigned overflow behavior, signed-range correction and warning emission remain
in place. Keeping `inp` is essential for identical warning digit counts/text.

Signs, whitespace, automatic/other bases and nonnumeric starts keep general
parsing. The raw digit checks retain base-10 semantics even if a native module
changes digit flags; the leading-blank guard retains that public customization.
No syntax/value cache, allocation, wider load, getter omission or signal queue
boundary is added. The caller retains its arithmetic and floating-conversion
behavior. The 32-bit bound is a range argument; a 32-bit build is not newly
certified by this round.

## Rejected restart variants

Both earlier variants remain in the evidence, with their sources and all timing
samples. A fixed nine-digit prototype improves short API calls but slows the
18-digit control about **11.8%** and underscores about **14.5%** in its run.
Its customer timings vary substantially: Endgame is **42.709 → 42.717 ms** in
the first run and **79.048 → 81.722 ms** on repeat; the first array-parser
medians also nearly double relative to later runs. No external cause was
isolated, and these runs are not substituted for the final measurements.

The next prototype uses the word-size bound but still restarts on continuations.
It passes full compatibility/package checks, including 24 OMZ sessions, as an
inactive private package. Nevertheless, the added **19-digit** timing control
reveals a regression: **15.461 → 28.960 ms per million API calls**, about **87%
slower**. Underscores are about **10–14% slower** in its two control runs.
That version is not activated. Resuming from the validated state removes the
repeat scan. All final tables below measure the selected implementation against
its own paired baseline; timings from different variants are not pooled.

## Timing conditions

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0, release assertions disabled,
`-O2 -g`, explicit `LDFLAGS=-g`, multibyte/PCRE enabled. The immutable preceding
source and selected source use the same configuration with private runtimes.
The final measured candidate is `.work/round26/resume/Src/zsh`; its canonical
sources match the selected checkout. Installed and debug builds have their own
paths/configurations and separate verification.

Nine alternating fresh-process samples per binary per run, CPU 2, C.UTF-8.
Own builds, tests and profilers finish before timing. Counter/fixture launchers
compile before their respective timers, between sequential measurement phases.
External activity is not exhaustively audited; the earlier restart trials show
why small timings need caution. Outputs/states match in every final comparison.
Loading, construction and warm-up precede warm application timers; reset costs
retain the existing workload definitions. These are offline kernels, not UI
startup, terminal frame rate, GPU rendering or network measurements.

### Customer kernels

| Kernel | First before → after ms | Repeat before → after ms |
| --- | ---: | ---: |
'''+paired(read('customer-benchmarks'),read('customer-repeat'))+'''

Coder paste takes **1.3% and 1.4% less time**, chat paste **1.7% and 2.6% less**.
Mario takes **1.5% and 1.1% less**; Endgame **0.9% and 0.5% less**. URL encoding
improves about **1.5% and 1.2%**. Small ordinary editor controls remain close:
repeated coder layout is about **0.2% slower**, chat layout about **0.1% slower**.
No aggregate score or universal application speedup is claimed.

### Customer libraries

| Operation | First before → after ms/call | Repeat before → after ms/call |
| --- | ---: | ---: |
'''+paired(read('library-benchmarks'),read('library-repeat'))+'''

Array parsing is **0.2% and 0.6% slower**. Encoding takes about **0.4–0.5% less
time**, validation about **0.9% less** in both runs. Navigation takes about
**1.0% and 2.2% less**. These small library differences are retained alongside
the stronger converter mechanism; no separate cause is assigned to each result.

### Parser/search controls

| Parser operation | Before → after ms/call |
| --- | ---: |
'''+single(read('parser-benchmarks'))+'''

HTML prose conversion is **1.6% slower**; comment conversion about **0.1%
slower**. Repair stays close; cleaning takes about **1.2% less time**. These
controls preserve their algorithms, and their differences are not attributed
individually to the decimal path.

| Search case | Before → after ms/batch |
| --- | ---: |
'''+single(read('search-benchmarks'))+'''

All search samples, including any slower controls, remain available.

### Direct public-API controls

| Input family | Before → after ms per million calls |
| --- | ---: |
'''+single(read('conversion-benchmarks'))+'''

One-digit through 18-digit decimal batches take **14–26% less time** (about
**1.17–1.35x**). The 19-digit continuation takes **14.5% less**, underscores
**5.5% less**, in their selected paired run. Other bases and signs also improve
in this run, but they do not use the decimal fast path and no direct mechanism
is assigned to those gains. These are repeated native API calls with a checked
unsigned digest, including the loop/call cost. Module setup is outside the native
timer; there is no separate native-loop warm-up. They are not whole-shell or
application speedup ratios. Inputs fit this 64-bit host and produce no warnings.

## Instructions and hardware counters

Matched Endgame profiles include preparation and warm-up. Source/final-state
hashes match: **'''+f'{old["instructions"]:,} → {new["instructions"]:,}'+''' instructions**, about
**0.90% fewer**. The original conversion self count is 59,648,781; the selected
count is recorded in the instruction summary and flat reports. Instruction
counts establish reduced work, not elapsed time by themselves.

The Linux launcher counts user-space events from exec through exit, including
inherited tasks and preparation, unlike warm timers. All events are fully
scheduled.

| Kernel | Before → after cycles | Instruction reduction |
| --- | ---: | ---: |
'''+ '\n'.join(hardware)+'''

Cycles fall about **0.4% for coder paste, 1.7% for Endgame, 1.2% for Mario and
0.9% for drawing**. These whole-process scopes differ from warm kernel timers.

## Compatibility and memory checks

<!-- ROUND26_VALIDATION -->

These checks establish focused coverage, not universal equivalence for every
script, native extension, signal schedule or platform. No-multibyte compilation,
32-bit compilation and other operating systems are not newly certified here.
The source-wide audit remains incomplete.

## Installed daily driver

<!-- ROUND26_INSTALLATION -->

[All evidence](results/round26/) retains final samples, slower controls, both
rejected restart trials, setup failures, source/binary hashes and exact commands.
Remaining arithmetic parsing and scope-table scans are separate profiling targets.
'''
(root/'Perf/round26.md').write_text(s)
