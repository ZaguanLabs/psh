# Unicode 17.0.0 data

Pinned Unicode 17.0.0 property data and extended grapheme tests, downloaded
2026-09-11. Files are unmodified, with SHA-256 hashes in `SHA256SUMS`.

- `GraphemeBreakProperty.txt` and `GraphemeBreakTest.txt`:
  https://www.unicode.org/Public/17.0.0/ucd/auxiliary/
- `DerivedCoreProperties.txt` (Indic_Conjunct_Break):
  https://www.unicode.org/Public/17.0.0/ucd/DerivedCoreProperties.txt
- `emoji-data.txt` (Extended_Pictographic and Emoji_Presentation):
  https://www.unicode.org/Public/17.0.0/ucd/emoji/emoji-data.txt
- `LICENSE.txt`: https://www.unicode.org/license.txt

Unicode License V3 is retained alongside the data. The generated
`src/grapheme_data.h` retains attribution and is reproduced by
`python3 scripts/unicode-tables.py`. `--check` verifies reproducibility without
writing. The module compiles these tables directly; no Unicode library is
needed at runtime. The implementation follows UAX #29 revision 47:
https://www.unicode.org/reports/tr29/tr29-47.html
