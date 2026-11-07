# zoup

`zoup` removes content that a text browser cannot use and returns simplified
HTML. It is written entirely in Zsh and loads through `autoload`.

The intended pipeline is:

```text
zbrowser requests → zcurl fetches → zoup cleans → zhtml prepares → zdraw draws
```

`zbrowser` is an idea, and `zhtml` is a future integration. This repository
implements the cleaner independently of both. Its output contains HTML, with
no terminal escape sequences, wrapping, screen coordinates, or theme decisions.

Version **0.1.0** is a first, bounded implementation. Verified with Zsh 5.9.2
on Linux. The library invokes no external programs. The optional stdin reader
uses Zsh's standard `zsh/system` module; ordinary scalar input needs no modules.

## Load and use

```zsh
fpath=( /path/to/zoup/functions "${fpath[@]}" )
autoload -Uz zoup

typeset REPLY
zoup clean -- '<p>Hello <img src="photo.jpg" alt="world"></p><script>run()</script>'
print -r -- "$REPLY"
# <p>Hello world</p>
```

Call `zoup clean -- HTML` to replace the caller's `REPLY` scalar. Within a
function, declare `local REPLY`. Input is literal data, including shell-looking
text: it is never evaluated. `--` is required before the single HTML argument.
An empty argument is a valid empty document.

`--stdout` writes the result instead of assigning `REPLY`, without adding a
newline. `--stdin` reads bytes from descriptor 0 until EOF. It buffers the
document before cleaning and blocks while its producer keeps the stream open.
It is intended for files and command-line use, rather than an interactive event
loop. Loading `zsh/system` for this mode persists in the caller's shell.

```zsh
zoup clean --stdin --stdout < page.html > clean.html
# The standalone Zsh launcher selects --stdout automatically:
zsh bin/zoup clean --stdin < page.html > clean.html
```

The library preserves the caller's options, locale, working directory, and
`fpath`. It registers only its namespaced autoloaded functions. It does not
install traps, hooks, an event loop, or terminal input handlers.

## Alongside zcurl

After loading `zcurl` and autoloading `zoup`:

```zsh
typeset -A response
typeset REPLY cleaned_html
if zcurl --result response --compressed -- 'https://example.org/'; then
  if zoup clean -- "$response[body]"; then
    cleaned_html=$REPLY
    # Retain response[effective_url] and response[content_type] with this HTML
    # for the future zhtml consumer.
  fi
fi
```

The application chooses how to handle HTTP status codes, redirects, content
types, and character encoding. `zoup` performs no network requests. Relative
URLs and a document's `<base href>` remain available for downstream resolution.

## Cleaning policy

| Input | Output |
| --- | --- |
| `script`, `style`, `iframe`, `noembed`, `noframes` | Remove element and raw contents. |
| `svg`, `math`, `template` | Remove subtree. Text alternatives inside these subtrees are not extracted yet. |
| `img` | Replace with `alt` text, escaped for HTML. Missing or empty `alt` produces no text. |
| `picture`, `video`, `audio`, `object`, `canvas`, `noscript` | Unwrap and clean child/fallback content. Existing fallback links survive. |
| Comments, declarations, processing instructions | Remove. |
| Stylesheets, inline styles, classes, event handlers, graphical attributes | Remove. No CSS is retained in this version. |
| Semantic elements, `div`, `span` | Keep structure and canonicalize tag names. |
| Links, tables, forms | Keep supported attributes, labels, values, and relationships. |
| Unknown elements | Unwrap and clean children. Their visual or block semantics are unknown. |
| `title`, `textarea` | Preserve text; escape apparent markup inside. |
| Legacy `xmp`, `plaintext` | Convert literal content into an escaped `pre` block. |

Useful global attributes include `id`, `title`, `lang`, `dir`, `role`, `hidden`,
`aria-label`, `aria-labelledby`, and `aria-describedby`. Element-specific
attributes include link destinations, list numbering, table spans and header
relationships, and basic form submission/control data. All surviving attributes
are lowercase, double-quoted, and escaped; the first duplicate wins. Boolean
attributes use an empty value. The exact allowlist lives in
[the filter](functions/_zoup_clean).

URL-bearing attributes accept relative references and explicit `http`, `https`,
`mailto`, or `tel` schemes. Unsupported schemes, literal whitespace/backslashes,
and ambiguous entity-encoded prefixes are removed. Query-string character
references are preserved. The browser must still interpret each URL according
to its action: for example, a form submission needs an HTTP(S) destination.

Content order, whitespace, and existing character references are preserved.
CRLF and CR become LF. Keeping block elements avoids joining adjacent paragraphs
into one word. Entity decoding, prose whitespace collapsing, tab expansion,
visibility interpretation, and terminal layout belong to `zhtml`.

The filter does not infer an article, remove navigation, or hide content based
on classes and styles. The HTML `hidden` attribute and hidden form controls stay
in the output for the consumer to interpret.

## Bounds and failures

- At most 1,048,576 input bytes, including when reading stdin.
- At most 32,768 bytes per tag and 128 attributes per tag.
- At most 32,768 literal `<` boundaries, checked after splitting input once.
- At most 32,768 scanner iterations; text runs, tags, comments, and raw-text
  closing-tag candidates count toward this limit.
- NUL, ESC, DEL, and C0 controls other than tab, LF, CR, and form feed are rejected.

Return status is `0` for success, `1` for input, parsing, limit, or I/O failure,
and `2` for incorrect usage or an unsuitable `REPLY` parameter. `REPLY` must be
unset or an ordinary writable scalar, not an array, readonly, exported, or
special parameter. Diagnostics go to stderr. Cleaning failures leave `REPLY`
unchanged and write no HTML to stdout. A downstream write failure can still
occur after stdout output begins.

An unterminated tag or quoted attribute is an error. An unterminated comment
or removed raw/subtree element consumes the remaining input. General missing
end tags and invalid nesting are left for the downstream parser.

Script removal tracks HTML's ordinary, escaped, and double-escaped script data.
For example, the inner `</script>` in `<!--<script>…</script>` does not end the
outer script, so its remaining JavaScript is also discarded. JavaScript string
quoting does not override HTML end tags. Comments accept both `-->` and the
malformed `--!>` ending, preserving content after the first ending.

## Scope

This is a tokenizer and allowlist filter, not a complete HTML5 tree builder.
It does not implement full browser error recovery, foreign-content integration
rules, CSS parsing, JavaScript execution, character
encoding conversion, or a DOM API. The tokenizer follows the basic distinctions
between tags, quoted attributes, raw text, and escapable raw text described in
the [HTML parsing standard](https://html.spec.whatwg.org/multipage/parsing.html).

Output is intended for a non-scripting text browser. It is not a security
sanitizer for insertion into a graphical browser. Character references remain
encoded; a consumer must validate decoded text before terminal rendering.

The scanner splits input once at `<` boundaries and reassembles segments when
attributes or other states require it. This avoids copying the entire remaining
document for every tag. Input, segments, and output still coexist in memory;
the input byte limit is not a process-memory limit. These bounds do not promise
interactive latency. Incremental processing and richer media alternatives are
future work to guide with measurements.

## Development

Implementation, launcher, tests, and benchmarks are Zsh source. Run:

```zsh
zsh -df scripts/test.zsh
zsh -df scripts/benchmark.zsh
```

Tests cover content preservation, removal, malformed input, shell-looking data,
Unicode, repeated cleanup, limits, caller state, and stdin/stdout behavior.
Benchmarks use synthetic repeated sections and report wall-clock time for the
installed shell; they are not claims about real-world page performance.
The [initial measurements](docs/performance.md) record the scanner optimization.

Licensed under the [Apache License 2.0](LICENSE).
