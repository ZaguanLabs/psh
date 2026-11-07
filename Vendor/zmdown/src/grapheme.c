#include "grapheme.h"
#include "grapheme_data.h"
static unsigned properties(unsigned cp) {
    if (cp>0x10ffff) return 0;
    return unicode_properties[(unsigned)unicode_pages[cp>>7]*128+(cp&127)];
}
int zmd_emoji_presentation(unsigned cp) { return (int)(properties(cp)>>7); }
int zmd_extended_pictographic(unsigned cp) { return (int)((properties(cp)>>6)&1); }
int zmd_grapheme_base(unsigned cp) {
    unsigned p=properties(cp)&15;
    return p!=G_EXTEND && p!=G_ZWJ && p!=G_SPACINGMARK && p!=G_PREPEND;
}
static int control(unsigned p) { return p==G_CR || p==G_LF || p==G_CONTROL; }
int zmd_grapheme_break(struct zmd_grapheme_state *s, unsigned cp) {
    /* Printable ASCII starts a new cluster except after Prepend (GB9b).
     * Reset every sequence tracker so the following Unicode scalar still
     * takes the complete state machine, including combining marks/keycaps. */
    if (cp>=0x20 && cp<0x7f) {
        int boundary=!s->have_previous || s->previous!=G_PREPEND;
        s->previous=G_OTHER; s->have_previous=1;
        s->regional=s->indic=s->emoji=0;
        return boundary;
    }
    unsigned value=properties(cp), p=value&15, previous=s->previous, ic=(value>>4)&3;
    int ep=(value>>6)&1, boundary=1;
    if (!s->have_previous) boundary=1;
    else if (previous==G_CR && p==G_LF) boundary=0;
    else if (control(previous) || control(p)) boundary=1;
    else if (previous==G_L && (p==G_L || p==G_V || p==G_LV || p==G_LVT)) boundary=0;
    else if ((previous==G_LV || previous==G_V) && (p==G_V || p==G_T)) boundary=0;
    else if ((previous==G_LVT || previous==G_T) && p==G_T) boundary=0;
    else if (p==G_EXTEND || p==G_ZWJ || p==G_SPACINGMARK || previous==G_PREPEND) boundary=0;
    else if (ic==1 && s->indic==2) boundary=0;
    else if (ep && s->emoji==2) boundary=0;
    else if (previous==G_REGIONAL_INDICATOR && p==G_REGIONAL_INDICATOR && s->regional%2) boundary=0;
    if (ic==1) s->indic=1;
    else if (ic==2 && s->indic) s->indic=2;
    else if (ic!=3) s->indic=0;
    if (ep) s->emoji=1;
    else if (p==G_ZWJ && s->emoji==1) s->emoji=2;
    else if (!(p==G_EXTEND && s->emoji==1)) s->emoji=0;
    s->regional=p==G_REGIONAL_INDICATOR ? s->regional+1 : 0;
    s->previous=p; s->have_previous=1;
    return boundary;
}
