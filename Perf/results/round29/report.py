from pathlib import Path
import json
root=Path.cwd();l=root/'.work/logs/round29';read=lambda n:json.loads((l/(n+'.json')).read_text());r=read('restoration');assert r['passed'] and r['no_activation_performed'];trial=read('inactive-build')
s='''# Round 29: grouped string hashing, not adopted

**Neither prototype is adopted.** The installed daily driver remains
`1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted optimizations. Production
source is restored to parent `605e124852ff4a8ed61a01ab0b7bba7b77440176`;
the developer executable is byte-for-byte identical to its preceding accepted
build. No activation or new compatibility difference is introduced.

The selected prototype reduces total JSON-encoding instructions by 1.03% and
chat-paste instructions by 0.95%. Native hashing of long keys takes up to about
42% less time in the final length controls. Actual installed-build application
results are less compelling: chat paste takes 1.1–1.5% less time, coder paste
is essentially flat, and JSON encoding takes 0.6–0.9% more time. These mixed
customer results do not justify replacing the accepted implementation.

## Profiles and implementation

Fresh profiles of the actual accepted release cover Endgame, chat paste, JSON
array encoding and JSON validation. Generic `hasher()` accounts for about
3.2–3.5% of instructions in the chat/JSON profiles. Endgame remains dominated
by arithmetic parsing/evaluation, which is a separate research lead.

The original hash starts at zero and applies `h = 33*h + byte` using unsigned
arithmetic. Four steps can be combined as:

```text
h_next = 1185921*h + 35937*a + 1089*b + 33*c + d
```

The coefficients are 33^4, 33^3, 33^2 and 33. Unsigned wraparound preserves the
original result; hash values, collision buckets and table traversal order are
intended to remain identical. Both prototypes still load individual unsigned
characters and check NUL before reading the next one. There are no word-width
memory loads, strlen prepass, alignment requirement, new allocations, cache,
locale dependency, public declaration or signal-boundary change.

The first prototype groups all blocks. Its native length controls show a
16.8% slower two-byte key and smaller one/three/four-byte regressions. Its two
private-build customer groups do show promising coder-paste gains of 4.2–4.9%,
with mixed controls. Those measurements remain in
[grouped-initial](results/round29/grouped-initial/); this variant was not packaged
for a direct installed-binary performance comparison. Its initial application
gains are not proof of an installed-release benefit.

The second prototype peels the first four-byte block, allowing short keys to
return without arithmetic involving an initial zero accumulator. This largely
removes the two-to-four-byte native regression; one-byte hashing remains 8.7%
slower in the final installed comparison. Its source remains reviewable as an
[unapplied experimental patch](results/round29/peeled-source.patch).

Matched private-build instruction profiles have identical project source and
resulting-state fingerprints:

| Kernel | Parent instructions | Peeled instructions | Reduction |
| --- | ---: | ---: | ---: |
| JSON array encoding | 2,653,578,305 | 2,626,359,221 | 1.03% |
| Chat paste | 2,363,622,174 | 2,341,198,461 | 0.95% |

Hash-function self instructions fall from 88,521,563 to 61,303,090 for JSON
encoding and 74,999,240 to 52,575,433 for chat. Instrumented instructions are
not wall time. [Receipts](results/round29/matched-profiles.json), complete flat
reports and compressed raw profiles retain the commands and fingerprints.

## Final installed-release measurements

The decisive comparison uses the exact installed old release and inactive trial
`1.0.0-rc0-e1f66a23cf65`, both release-profile builds with DEBUG off, dynamic
modules, multibyte/PCRE support, `-O2 -g`, explicit `LDFLAGS=-g`, and split symbols.
The machine-code bytes of each measured hash function match its corresponding
private build used for profiling. This check binds the leaf routine, not every
address or byte of the two differently configured executables.

Nine alternating fresh-process samples per pair run on CPU 13. Customer,
library, parser, search, hardware and hash-length groups use C.UTF-8; the array
control driver uses C. Own builds, tests and profilers have completed before
timing. One pre-run observation found CPU 13 idle and its sibling at 1% busy;
that is not a continuous audit or a claim that unrelated work was absent.
Warm timers exclude startup, loading and fixture construction. Output/state
fingerprints match. Positive percentages below mean more time; small or mixed
differences do not establish a useful general benefit.

'''
for base,rep,title in [('customer-benchmarks','customer-repeat','Customer kernels'),('library-benchmarks','library-repeat','Library operations')]:
 s+='### '+title+'\n\n| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n'
 a=read(base)['cases'];b=read(rep)['cases'];assert len(a)==len(b)
 for x,y in zip(a,b):
  name=x.get('case',x.get('operation'));assert name==y.get('case',y.get('operation'));o,n=x['median_ms'];u,v=y['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% | {u:.3f} | {v:.3f} | {(v/u-1)*100:+.1f}% |\n'
 s+='\n'
for key,title in [('parser-benchmarks','Parser controls'),('search-benchmarks','Search controls'),('array-benchmarks','Array controls'),('hash-benchmarks','Native key-length controls')]:
 s+='### '+title+'\n\n| Case | Parent ms | Trial ms | Change |\n| --- | ---: | ---: | ---: |\n'
 for c in read(key)['cases']:
  name=c.get('case',c.get('name',c.get('operation',c.get('length'))))
  if key=='array-benchmarks':name+=f" / size {c['size']} / iterations {c['iterations']}"
  if key=='hash-benchmarks':name=f"{c['length']} bytes / {c['iterations']} calls"
  o,n=c['median_ms'];s+=f'| {name} | {o:.3f} | {n:.3f} | {(n/o-1)*100:+.1f}% |\n'
 s+='\n'
s+='''The native table times repeated hot external calls with checked unsigned
checksums; allocation, module loading and interpreter dispatch are outside its
timers. The fixture is prepared before the first timed call, with no concurrent
build. It is an isolated length control, not a shell or application speed score.

### Hardware controls

These user-space counters cover exec through exit, setup and inherited tasks,
which differs from warm timers. All events were fully scheduled.

| Case | Parent cycles | Trial cycles | Parent instructions | Trial instructions |
| --- | ---: | ---: | ---: | ---: |
'''
for c in read('hardware')['cases']:
 a,b=c['median_scaled_events'];s+=f"| {c['case']} | {a['cycles']:,.0f} | {b['cycles']:,.0f} | {a['instructions']:,.0f} | {b['instructions']:,.0f} |\n"
s+='''
### Earlier noisy pass

An earlier CPU-2 pass of the peeled private build has large swings in unchanged
parent controls: coder paste is 130.226 ms, chat paste 240.930 ms and agy shooter
23.956 ms. Some pairwise changes range from 31.5% less time to 20.2% more time.
The parent ELF, worker and customer source fingerprints match the first pass.
One later aggregate observation records 18% activity on CPU 2's sibling; it
does not establish the cause of the earlier variations.

All nine groups and samples remain under
[peeled-noisy](results/round29/peeled-noisy/). They are not used to adopt a change.
The final pass changes both CPU and executable scope to actual installed builds;
its medians are not substituted into the earlier groups. The data do not isolate
whether code layout, configuration paths, host activity or other factors explain
the differences between private and installed measurements. In particular, the
installed peeled result does not directly measure the first grouped prototype.

## New native coverage and validation

The committed [native fixture](hash-module.c) compares the public hash function
with the exact original release recurrence, checking unchanged errno. Per
host/locale it runs 538,428 counted inputs:

- 522,248 empty and exhaustive nonzero one/two-byte inputs at eight offsets;
- 2,744 selected triples at eight offsets;
- 8,256 exact-sized allocation cases, lengths 0–257 with four content patterns;
- 1,084 protected/read-only mapping cases, including lengths through 65,535;
- 4,096 deterministic buffers with possible embedded NULs and varying offsets.

The page-boundary strings end immediately before an inaccessible page; read-only
mapping checks also reject writes to those inputs. Heap cases under Memcheck
exercise the terminator at the allocation boundary. Long cases exercise unsigned
wraparound. These are focused raw-byte checks, not a proof of all shell behavior.

**5,384,280 checks across ten Memcheck processes pass** for the peeled prototype:
pristine/GCC in C and UTF-8, Clang old/new in UTF-8, pristine/DEBUG in UTF-8,
and exact old/new installed releases in UTF-8. Leak checks are disabled; there
are zero memory errors. This repeats the matrix across hosts/locales, rather
than representing five million distinct strings. A further 1,076,856 Memcheck
checks pass for pristine and the restored accepted developer binary in UTF-8.
Initial smoke receipts remain separate from these final receipts.

The peeled candidate also passes:

- GCC release: 63 upstream scripts, zero failures, two skips. Clang parent and
  candidate each pass 63/0/2. The DEBUG developer build passes 62/0/3; its
  default configuration lacks PCRE. The restored DEBUG build passes 62/0/3 again.
- Eleven broad groups: arrays 5,192; search 193,236; patterns 159,600; scalars
  704,585 across five encodings; substitution 2,640; arithmetic syntax 110,100;
  native floating-point 200,832 scenarios under Memcheck; accessor 20; PTY
  completion 36; emulation frontend 512; and customer correctness, including
  24 kernel/locale pairs plus five original project suites.
- Seven newly built inactive-package suites, including all 190 zdraw tests,
  rebuilt native modules, login/startup/component checks and 24 genuine
  interactive Oh My Zsh sessions with re5et, git and syntax highlighting.
- Exact source/oracle comparison, public declaration/header and dynamic-export
  comparisons. Only the experimental hash function changes in the candidate
  production source. The scanner and array implementation remain unchanged.

Those passes establish correctness evidence for the exercised cases. They do
not override mixed customer performance or make the prototype an accepted
optimization. Other operating systems and a fresh non-multibyte build were not
certified here. The structural index reported partial coverage; exact source
reads and comparisons support the focused source claims.

## Restored state

'''
s+=f"Active prefix: `{r['active_prefix']}`.\n\nActive ELF SHA-256: `{r['active_sha256']}`.\n\nAll {r['active_source_inputs_match']:,} current packaged inputs match that accepted release;\nproduction source matches the parent byte-for-byte. The developer ELF is also\nbyte-for-byte restored, SHA-256 `{r['development_sha256']}`.\n\n"
s+='''The normal-user verifier passes again on the unchanged active release,
including a fresh 24-session OMZ gate. Its historical seven-suite receipts are
reused because the exact accepted executable and payload are unchanged; these
are not presented as seven newly rerun suites on the restored release.

The first restored-package verification attempt correctly rejected local Vendor
build outputs left from the inactive trial. The exact previously tested active
module bytes were copied back into those transient build paths, with the trial
bytes preserved in its inactive prefix. No verification check was weakened and
neither installed release was modified. The failed log, hashes and successful
rerun remain in the evidence. A source-only helper also initially required a
not-yet-produced final hardware receipt; that dependency was moved to full
closeout, with no production change.

'''
s+=f"All {r['active_release_entries_unchanged']:,} active-release entries and {r['protected_stable_entries_unchanged']:,} protected stable-Zsh/startup\nentries remain unchanged. `/etc/shells`, the account login shell, personal startup\nfiles and framework sources are untouched. Package `latest.json` points back to\nthe active accepted build. No activation was performed. The inactive trial\n`{Path(r['inactive_trial_prefix']).name}` is retained for research, with ELF SHA-256\n`{r['inactive_trial_sha256']}`. Both stripped executables are 846,488 bytes and retain\nthe same 1,056 dynamic exported names/types.\n\n"
s+='''The project stays `1.0.0-rc0`; the original rc0 tag, draft and seven historical
assets remain unchanged and the repository stays private. There is no new
accepted source patch or release archive from this round. The current accepted
optimization report remains [round 28](round28.md).

[The evidence index](results/round29/README.md) distinguishes proposed/inactive
receipts from restoration proof. It retains every slower control, prototype
and timing pass, with compressed raw profiles. Local-only protected-file and
previous-release snapshots are excluded. The source audit remains incomplete;
arithmetic parsing/evaluation is still a substantial future target in Endgame.
'''
(root/'Perf/round29.md').write_text(s)
