# CommonMark fixtures

`commonmark-0.31.2.json` is the unmodified example corpus downloaded from
https://spec.commonmark.org/0.31.2/spec.json on 2026-09-11.

The CommonMark specification is copyright John MacFarlane and licensed under
CC-BY-SA 4.0. See `COMMONMARK-LICENSE`, copied from
https://github.com/commonmark/commonmark-spec/blob/0.31.2/LICENSE.

The HTML oracle checks the vendored parser. Rendering the corpus at different
widths and color settings additionally checks UTF-8 validity, terminal-control
handling, and cell-width limits. It does not establish visual fidelity by itself.
