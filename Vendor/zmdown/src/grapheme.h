#ifndef ZMDOWN_GRAPHEME_H
#define ZMDOWN_GRAPHEME_H
/* Unicode 17 extended grapheme segmentation (UAX #29 revision 47).
 * Initialize to zero. Feed Unicode scalar values, one at a time. */
struct zmd_grapheme_state { unsigned previous, have_previous, regional, indic, emoji; };
int zmd_grapheme_base(unsigned cp);
int zmd_grapheme_break(struct zmd_grapheme_state *state, unsigned cp);
int zmd_emoji_presentation(unsigned cp);
int zmd_extended_pictographic(unsigned cp);
#define ZMDOWN_WIDTH_POLICY "unicode-17.0.0-egc-max-wcwidth-emoji2"
#endif
