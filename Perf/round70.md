# Round 70: reducing the Clang UTF-8 blocker

Round 69 rejected a Clang-LTO candidate after two zjson malformed-input failures.
This follow-up reduces the measured difference before any performance work.
It changes no interpreter, customer, framework or startup source.

## Reduced failing sequence

For the input bytes `e2 82 A c3 a9`, both healthy GCC and Clang currently
repair the malformed UTF-8 prefix to the Unicode replacement character followed
by `A` and `é`. GCC then parses the resulting JSON string successfully; Clang
reports `invalid_utf8` instead.

The smallest validator and repair calls, when run in isolation, match pristine
Zsh, active rc2, GCC and Clang. Direct checks of the literal
`*[[:INVALID:][:INCOMPLETE:]]*` pattern also match on valid and malformed
controls. The failure therefore depends on the preceding quote/parser sequence,
not just those byte strings.

## Native and locale evidence

`pattern.c` supplies `zmb_ind` through `charref()`/`charrefinc()`, and
`mb_patmatchrange()` reports PP_INVALID/PP_INCOMPLETE only for a conversion error.
This investigation did not identify an uninitialized local. Round 71 subsequently
found that both character-class callers leave the status uninitialized and the
ASCII return in `charref()` does not set it; see [the follow-up](round71.md).

Calling the existing `clear_shiftstate()` diagnostic function between quote and
parse did not change Clang's result. No source-specific compiler or locale bug is
claimed from that outcome alone. The trace shows the same C.UTF-8 locale spelling
and the same expected probe character length on both hosts.

An ordinary Clang package, built without LTO, was also installed inactive and
tested with `--suite zjson --jobs 1`. It still reports two failures out of
14,237 checks under C.UTF-8. Therefore LTO is not required for the failure; the
compiler route remains blocked independently of profiling or performance benefit.

The failed initial feature-enablement probe was a test setup error and is not
presented as evidence. Core dumps and temporary native reproducers remain private;
no user framework or startup files were modified to obtain these results.

## Primary artifacts

_Local retained artifacts under `.work/round70/` include the quote/parse
comparison, validator traces, minimum pattern outcomes, staged quoting checks
and the non-LTO package record._ No elapsed timing or adoption claim accompanies
them. The active psh remains the original inactive-experiment baseline.

## Remaining work

The next step must directly capture `pattern.c`'s conversion outcome and matcher
state for this exact sequence before modifying the interpreter. A customer-side
workaround is not acceptable evidence of compatibility. No native ABI or
performance change is being proposed here.
