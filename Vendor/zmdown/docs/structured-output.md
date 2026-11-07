# Structured Markdown API — schema 1

```zsh
zmodload zmdown
local -A document
zmdown --spans document --width 60 --text "$markdown" || return

local i j key text
local -i flags cells
for (( i=1; i<=document[line_count]; ++i )); do
  for (( j=1; j<=document[line,$i,span_count]; ++j )); do
    key=line,$i,span,$j
    text=$document[$key,text]
    flags=$document[$key,style]
    cells=$document[$key,cells]
    # Your application can map flags to its own palette and draw "$text".
    print -rn -- "$text"
  done
  print
done
```

Declare the destination with `local -A` or `typeset -A` before calling. The
module replaces its entire value on success. It writes nothing to stdout,
including with `--color always`; all text values are free of ANSI escapes.
`--spans` accepts the same input, width, width-policy, cluster-style, dialect,
and link options as scalar rendering, and excludes `--variable`.

The destination must be a simple name referring to an ordinary writable
association. Missing, scalar, indexed-array, special, tied, readonly, and
formatting-attributed destinations are rejected with status 2. Rendering and
resource failures return 1. Publication validates again with signals queued
and swaps a fully constructed ordinary hash table. Failures preserve the old
association. Values never pass through shell evaluation or caller-provided
parameter callbacks. As with other native Zsh allocations, an unrecoverable
shell allocator failure can terminate the shell; it cannot return a status.

## Feature discovery

```zsh
local features
features=$(zmdown --features 2>/dev/null) || return 1
[[ " $features " == *' spans=1 '* ]] || return 1
```

`--features` prints space-separated tokens, with comma-separated lists where
multiple choices are supported:

```text
spans=1 code-blocks=1 span-roles=1 graphemes=17.0.0 width-policy=unicode-17.0.0-egc-max-wcwidth-emoji2 width-policies=unicode,wcwidth-sum cluster-styles=preserve,first-base soft-breaks=space,newline
```

`width-policy` identifies the unchanged default; `width-policies` and
`cluster-styles` advertise supported option values, not the current selection.
Builds predating these choices omit the new tokens; the earliest builds reject
`--features`. Consumers should check `document[schema]` and the selected policy
metadata too, ignore unknown keys, and require supported choices before
interpreting entries. No JSON decoding or additional module is involved.

`span-roles=1` advertises the additive span `role` field. Older schema 1 builds
omit it. Roles can divide spans that previously shared a style; consumers must
use `span_count` rather than assuming a fixed span count for a particular style.

## Association keys

Indices `N`, `M`, and `B` are decimal integers starting at 1. Associative-array
iteration order has no meaning; use the counts and numbered keys.

| Key | Value |
| --- | --- |
| `schema` | `1` |
| `width` | Requested maximum terminal cells per rendered row |
| `width_policy` | Versioned measurement identifier: `unicode-17.0.0-egc-max-wcwidth-emoji2` or `unicode-17.0.0-egc-wcwidth-sum` |
| `width_policy_name` | Selected option value: `unicode` or `wcwidth-sum` |
| `cluster_styles` | Selected option value: `preserve` or `first-base` |
| `soft_breaks` | Selected soft-break mode: `space` (default) or `newline`; older builds omit this key |
| `line_count` | Number of rendered rows, including blank separator rows |
| `block_count` | Number of parsed blocks, including structural containers |
| `style,NAME` | Bit value for a semantic style, listed below |
| `line,N,text` | Complete plain row, without its terminating newline |
| `line,N,cells` | Row width according to the policy below |
| `line,N,block` | Owning block number, or 0 for a separator |
| `line,N,role` | `content`, `code-label`, or `spacer` |
| `line,N,span_count` | Ordered span count; zero for empty rows |
| `line,N,span,M,text` | Sanitized UTF-8 text in this span |
| `line,N,span,M,style` | Bitwise combination of semantic style flags |
| `line,N,span,M,role` | `content` or `decoration`, independent of style |
| `line,N,span,M,cells` | Cell contribution of this span |
| `block,B,kind` | Block kind, listed below |
| `block,B,parent` | Parent block number; the document root has parent 0 |
| `block,B,level` | Heading level 1–6; present for headings |
| `block,B,fenced` | 1 for fenced code, 0 for indented code; present for code |
| `block,B,language` | Decoded, sanitized fence language, or empty; present for code |
| `block,B,text` | Complete sanitized code content before layout; present for code |

Concatenating a row's span texts reconstructs `line,N,text` exactly. Appending
one newline to every row reconstructs `--plain` output with the same options.
Empty input has zero rows. Span cell contributions sum to the row cell count.
Generated prefixes, table borders, and padding are included in the spans.
Adjacent text with identical styles and roles is coalesced within each row.
Layout decoration includes code headers, structural prefixes (including code
gutters), thematic rules, table borders, table padding, and stacked-table
separators. Inline code is `content`. Generated inline descriptions, such as
link destinations and image labels, also remain `content`; roles distinguish
layout furniture, not original source bytes.

| Style name | Bit | Meaning |
| --- | --- | --- |
| `strong` | 1 | Strong emphasis; also used for headings and table headers |
| `emphasis` | 2 | Emphasis |
| `code` | 4 | Inline or block code |
| `deletion` | 8 | Strikethrough |
| `heading` | 16 | Heading text |
| `muted` | 32 | Code language labels, raw HTML, generated link destinations/image labels |
| `link` | 64 | Link text |

For example, `***both***` has style 3 and headings have style 17. Use bitwise
checks, such as `(( flags & document[style,strong] ))`, rather than comparing
whole values. Colors remain the application's choice.

Block kinds are `document`, `paragraph`, `heading`, `code`, `html`, `rule`,
`quote`, `unordered-list`, `ordered-list`, `list-item`, `table`, `table-head`,
`table-body`, `table-row`, `table-heading`, and `table-cell`. Tight list text
belongs to its list item because the parser omits a paragraph container.
Table output rows belong to the table, including its stacked narrow layout.
Some container blocks have no directly owned rows. `code-label` rows and
wrapped code rows reference the same code block.

Block numbers identify blocks within a single result. They are not stable
source anchors, source byte offsets, or reusable document handles.

## Code contents

```zsh
local b language code
for (( b=1; b<=document[block_count]; ++b )); do
  [[ $document[block,$b,kind] == code ]] || continue
  language=$document[block,$b,language]
  code=$document[block,$b,text]
  # Feed "$code" to an application highlighter, using "$language" as metadata.
done
```

The text excludes fence delimiters and Markdown container indentation.
MD4C normalizes line endings to LF and may expand leading indentation tabs.
Remaining internal tabs and code whitespace survive in `block,B,text`;
layout separately expands tabs to four-cell stops and wraps the visible rows.
Invalid UTF-8 and terminal controls undergo the same sanitization as visible
text. The result is complete parsed code, not the original source bytes.
Language is the fence's first info-string word, with entities decoded, and is
empty for indented code or an unlabeled fence. It is data, never a command.
Syntax highlighting is outside this module.

Every code block has a muted header: its language when supplied, otherwise
`code`. Body rows have an ASCII `| ` gutter, including blank code lines and
wrapped continuation rows. Indented code uses the same layout; empty fences
still produce a header. For example, an unlabelled block containing `print ok`
renders as:

```text
code
| print ok
```

Header rows retain role `code-label`; body rows retain role `content`. Both
belong to the code block. Header spans and generated prefixes/gutters have
span role `decoration`, while code body spans have role `content` and the
semantic `code` style (subject to the selected cluster-style policy). No
additional color palette or syntax-highlighting dependency is introduced.
Headers wrap to the available width. As with other structural prefixes, the
gutter and container indentation are omitted when they leave no content cell.

Consumers can theme decoration separately using `document[$key,role]` alongside
`document[$key,style]`. To copy or highlight an entire code block, use
`block,B,text`: filtering visible spans removes decoration but still leaves
layout-expanded tabs and wrapped lines, without source-line mapping.
Code metadata excludes the fallback header and all gutters.

## Graphemes and cell measurement

All output modes wrap at Unicode 17 extended grapheme boundaries, using
[UAX #29 revision 47](https://www.unicode.org/reports/tr29/tr29-47.html).
Combining sequences, skin-tone modifiers, regional-indicator flags, ZWJ emoji,
and Indic conjuncts remain together. A cluster that cannot fit causes the
whole render to fail before assignment or stdout output. Structural prefixes
are omitted when they would consume the entire width, as in scalar rendering.

The default `--width-policy unicode` (`unicode-17.0.0-egc-max-wcwidth-emoji2`)
assigns a cluster the maximum of its scalars' locale-dependent `wcwidth` values
(negative values become 1).
Clusters containing an Emoji_Presentation scalar, an extended pictograph with
VS16, or a keycap sequence use two cells. Standalone combining clusters can
have zero cells. This deterministic policy is not a promise about every
terminal: ambiguous characters follow the current locale, VS15 does not undo
a default emoji's two-cell width, and shaping/fonts can differ. Use a UTF-8
locale; the core does not change the process locale.

### Compatibility width policy

`--width-policy wcwidth-sum` sums the locale-dependent `wcwidth` of every
constituent scalar in each extended grapheme. Each negative result contributes
**one cell**; zero-width scalars contribute zero. Emoji get no special width
override. The versioned identifier is `unicode-17.0.0-egc-wcwidth-sum`.

The entire cluster remains indivisible. In a UTF-8 locale where woman and
laptop each have width 2 and ZWJ has width 0, `👩‍💻` needs four cells:

```zsh
local -A document
zmdown --spans document --width 78 \
  --width-policy wcwidth-sum --cluster-styles first-base \
  --text "$markdown" || return
[[ $document[width_policy_name] == wcwidth-sum &&
   $document[width_policy] == unicode-17.0.0-egc-wcwidth-sum &&
   $document[cluster_styles] == first-base ]] || return 1
```

At width two, that cluster causes atomic failure under `wcwidth-sum`; it fits
intact under the default policy. A keycap sequence can instead be narrower
under `wcwidth-sum`, because it has no forced two-cell emoji presentation.
This is a compatibility policy for drawing backends that sum scalar widths,
including some curses application paths, not a guarantee about every curses
implementation, locale, or terminal. No backend library is linked or probed.

The selected policy applies to plain/ANSI layout, structured output, table
column sizing and wrapping, tab expansion, and all reported cell counts.
Generated ASCII indentation and borders contribute one cell per character in
both policies. Tabs expand to four-cell stops relative to the unwrapped
content line (excluding generated indentation); tab stops therefore use the
selected policy's content width. Code metadata keeps its pre-layout text.
Unsupported policy/mode values return status 2 before input is read or a
destination is changed.

### Styles inside a grapheme

The independent `--cluster-styles preserve` default retains each scalar's
semantic style flags, even when a Markdown style boundary falls inside a
grapheme. Under `unicode`, the first scalar's span receives the whole cluster's
width and continuation spans contribute zero. Under `wcwidth-sum`, each span
receives its own scalars' contributions, using the same negative-width rule.
In either policy, the span counts sum to the row's count. Such spans must be
drawn together without introducing a wrap inside their shared grapheme.

Opt into `--cluster-styles first-base` for a backend needing one style per
cluster. Every scalar in the grapheme receives the semantic flags of its first
base character. Here, a base is the first scalar whose Unicode
Grapheme_Cluster_Break property is **not** Extend, ZWJ, SpacingMark, or Prepend.
This skips combining marks, variation selectors, skin-tone modifiers, joiners,
and prepend characters. If there is no base, including a combining-only
cluster, the first scalar's style is used. Flags are selected as a complete
bitmask, so strong-plus-emphasis combinations survive.

For example, `**e**` followed by a combining acute accent becomes one strong
`é` grapheme. Conversely, an unstyled `e` followed by a strong combining accent
becomes entirely unstyled. Only styles are normalized: text, grapheme
boundaries, layout, and code metadata remain unchanged. The decision is made
on the full rendered row, including generated indentation and table padding.
Both ANSI and structured output honor the mode; ANSI emits no style change
inside a normalized grapheme. Adjacent graphemes with the same style may share
a span when their roles also match. Roles survive normalization independently;
a grapheme spanning a decoration/content boundary can still occupy multiple
spans with the same style. UTF-8 scalar bytes are never split across spans.

The drawing backend remains responsible for respecting whole-grapheme
boundaries during its own clipping. These options do not provide or configure
a backend clipping operation.

## Bounds and C API

In addition to the renderer's shared limits, structured output permits at
most 100,000 rows, 200,000 spans, 500,000 key/value pairs, and 32 MiB of combined
key/value strings including terminators. Counts include generated metadata.
A smaller input can exceed these limits when laid out at a very narrow width.
`first-base` also uses the 100,000-row and 200,000-span limits for its temporary
row records, including in scalar output. Records before and after normalization
must fit these bounds. There is no truncation or partial result.
Zsh's parameter representation adds
allocation overhead beyond the bounded C strings and record arrays.

The independently testable C interface is `zmd_render_document()` in
`src/render.h`. It returns an owned `struct zmd_document` containing alternating
UTF-8 key/value strings and a count of pairs; release it using
`zmd_document_free()`. On failure the result pointer is NULL. No Zsh or terminal
library is needed by the C core.

Initialize `struct zmd_options` to zero before setting its fields. Select
`ZMD_WIDTH_UNICODE` (0) or `ZMD_WIDTH_WCWIDTH_SUM` (1) in `width_policy`, and
`ZMD_STYLES_PRESERVE` (0) or `ZMD_STYLES_FIRST_BASE` (1) in `cluster_styles`.
Invalid enum values fail without returning a result. These fields extend the
development C options struct; C/FFI consumers must rebuild/update their struct
layout against the current header. The Zsh command defaults and schema 1's
existing default fields remain compatible; policy metadata is additive.
