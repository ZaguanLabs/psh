#define _XOPEN_SOURCE 700
#include "render.h"
#include "grapheme.h"
#include "md4c.h"
#include "entity.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

/* A document tree decouples CommonMark parsing from width-dependent layout.
 * All state is per invocation. Callbacks copy their borrowed strings. */
enum { BLOCK, SPAN, TEXT };
enum { BOLD=1, ITALIC=2, CODE=4, STRIKE=8, HEADING=16, DIM=32, LINK=64 };
struct node {
    int category, type;
    unsigned value;
    int tight, task, align, autolink, fenced;
    unsigned id;
    char *text, *extra;
    size_t length, extra_length;
    struct node *child, *last, *next, *parent, *allocated_next;
};
struct buffer { char *data; size_t length, capacity; };
struct arena_chunk { struct arena_chunk *next; size_t used, capacity; max_align_t data[]; };
struct arena { struct arena_chunk *head; };
/* The public result remains the first member; callers release it through
 * zmd_document_free. Its strings share a per-result allocation lifetime. */
struct document_storage { struct zmd_document document; struct arena strings; };
struct rendered_span { size_t start, length; unsigned cells, style, decoration; };
struct rendered_line { size_t start, length, first, count; unsigned cells, block, label; };
struct context {
    struct zmd_options options;
    struct node *root, *current, *allocated;
    struct arena tree;
    size_t nodes, copied_bytes;
    unsigned depth;
    const char *error;
    struct buffer output;
    struct zmd_document *document;
    size_t pair_capacity, pair_bytes;
    struct rendered_span *spans;
    struct rendered_line *lines;
    size_t span_count, span_capacity, line_count, line_capacity;
    unsigned block_count, active_block, style, label;
    int line_open, collect, decoration;
};
/* Indices fit in unsigned: every inline buffer is capped at 2,097,152 glyphs. */
struct glyph { char bytes[4]; unsigned char length, style, kind, decoration; unsigned cp, width, end; };
enum { NORMAL, SPACE, BREAK, TAB };
struct glyphs { struct glyph *items; size_t count, capacity; };
struct prefix { char first[1024], rest[1024]; int pending; };
struct row { size_t start, end; unsigned width; };
struct rows { struct row *items; size_t count, capacity; struct row first; };

static int fail(struct context *c, const char *error) {
    if (!c->error) c->error = error;
    return 1;
}
static void arena_free(struct arena *arena) {
    struct arena_chunk *chunk;
    while ((chunk=arena->head)) { arena->head=chunk->next; free(chunk); }
}
static void *arena_alloc(struct context *c, struct arena *arena, size_t size, size_t align) {
    struct arena_chunk *chunk=arena->head;
    size_t offset=chunk ? (chunk->used+align-1)&~(align-1) : 0;
    if (c->error) return NULL;
    if (!chunk || offset>chunk->capacity || size>chunk->capacity-offset) {
        size_t capacity=chunk ? chunk->capacity : 512;
        if (capacity<65536) capacity*=2;
        else capacity=65536;
        if (capacity<size) capacity=size;
        chunk=malloc(sizeof(*chunk)+capacity);
        if (!chunk) { fail(c,"out of memory"); return NULL; }
        chunk->next=arena->head; chunk->capacity=capacity;
        arena->head=chunk; offset=0;
    }
    chunk->used=offset+size;
    return (char *)chunk->data+offset;
}
static int reserve(struct context *c, void **p, size_t *capacity,
                   size_t need, size_t element, size_t limit) {
    size_t next;
    void *result;
    if (c->error) return 1;
    if (need > limit) return fail(c, "document exceeds renderer resource limits");
    if (*capacity >= need) return 0;
    next = *capacity ? *capacity : 64;
    while (next < need) next = next > limit / 2 ? limit : next * 2;
    result = realloc(*p, next * element);
    if (!result) return fail(c, "out of memory");
    *p = result; *capacity = next;
    return 0;
}
static void collect_output(struct context *c, const char *text, size_t length) {
    size_t i=0;
    while (i<length && !c->error) {
        struct rendered_line *line;
        size_t start=i, n;
        if (!c->line_open) {
            if (reserve(c,(void **)&c->lines,&c->line_capacity,c->line_count+1,
                        sizeof(*c->lines),100000)) return;
            line=&c->lines[c->line_count++]; memset(line,0,sizeof(*line));
            line->start=c->output.length+i; line->first=c->span_count;
            line->block=c->active_block; line->label=c->label; c->line_open=1;
        }
        line=&c->lines[c->line_count-1];
        while (i<length && text[i]!='\n') ++i;
        n=i-start;
        if (n) {
            struct rendered_span *span=line->count ? &c->spans[c->span_count-1] : NULL;
            if (!span || span->style!=c->style || span->decoration!=(unsigned)c->decoration) {
                if (reserve(c,(void **)&c->spans,&c->span_capacity,c->span_count+1,
                            sizeof(*c->spans),200000)) return;
                span=&c->spans[c->span_count++]; memset(span,0,sizeof(*span));
                span->start=c->output.length+start; span->style=c->style;
                span->decoration=c->decoration; ++line->count;
            }
            span->length+=n; line->length+=n;
        }
        if (i<length) { c->line_open=0; ++i; }
    }
}
static void output(struct context *c, const char *text, size_t length) {
    if (reserve(c, (void **)&c->output.data, &c->output.capacity,
                c->output.length + length + 1, 1, ZMDOWN_OUTPUT_LIMIT)) return;
    if (c->collect) collect_output(c,text,length);
    if (c->error) return;
    memcpy(c->output.data + c->output.length, text, length);
    c->output.length += length;
    c->output.data[c->output.length] = 0;
}
static void puts_out(struct context *c, const char *s) { output(c, s, strlen(s)); }
static void decoration_out(struct context *c, const char *s) {
    int previous=c->decoration; c->decoration=1;
    puts_out(c,s); c->decoration=previous;
}
static char *copy_text(struct context *c, const char *s, size_t length) {
    char *p;
    if (length + 1 > ZMDOWN_OUTPUT_LIMIT - c->copied_bytes) {
        fail(c,"expanded Markdown exceeds 32 MiB"); return NULL;
    }
    c->copied_bytes += length + 1;
    p = arena_alloc(c,&c->tree,length+1,1);
    if (!p) { fail(c, "out of memory"); return NULL; }
    if (length) memcpy(p, s, length);
    p[length] = 0;
    return p;
}
static struct node *new_node(struct context *c, int category, int type) {
    struct node *n;
    if (++c->nodes > 100000) { fail(c, "too many Markdown nodes"); return NULL; }
    n = arena_alloc(c,&c->tree,sizeof(*n),_Alignof(struct node));
    if (!n) { fail(c, "out of memory"); return NULL; }
    memset(n,0,sizeof(*n));
    n->category = category; n->type = type; n->parent = c->current;
    n->allocated_next = c->allocated; c->allocated = n;
    if (c->current) {
        if (c->current->last) c->current->last->next = n;
        else c->current->child = n;
        c->current->last = n;
    } else c->root = n;
    return n;
}
static int enter_block(MD_BLOCKTYPE type, void *detail, void *userdata) {
    struct context *c = userdata;
    struct node *n;
    if (++c->depth > 128) return fail(c, "Markdown nesting exceeds 128 levels");
    n = new_node(c, BLOCK, type);
    if (!n) return 1;
    n->id=++c->block_count;
    c->current = n;
    switch (type) {
    case MD_BLOCK_H: n->value = ((MD_BLOCK_H_DETAIL *)detail)->level; break;
    case MD_BLOCK_UL: n->tight = ((MD_BLOCK_UL_DETAIL *)detail)->is_tight; break;
    case MD_BLOCK_OL:
        n->tight = ((MD_BLOCK_OL_DETAIL *)detail)->is_tight;
        n->value = ((MD_BLOCK_OL_DETAIL *)detail)->start; break;
    case MD_BLOCK_LI:
        if (((MD_BLOCK_LI_DETAIL *)detail)->is_task)
            n->task = ((MD_BLOCK_LI_DETAIL *)detail)->task_mark == ' ' ? 1 : 2;
        break;
    case MD_BLOCK_CODE: {
        MD_ATTRIBUTE *a = &((MD_BLOCK_CODE_DETAIL *)detail)->lang;
        n->fenced=((MD_BLOCK_CODE_DETAIL *)detail)->fence_char!=0;
        n->extra = copy_text(c, a->text, a->size); n->extra_length = a->size; break;
    }
    case MD_BLOCK_TABLE: n->value = ((MD_BLOCK_TABLE_DETAIL *)detail)->col_count; break;
    case MD_BLOCK_TH: case MD_BLOCK_TD:
        n->align = ((MD_BLOCK_TD_DETAIL *)detail)->align; break;
    default: break;
    }
    return c->error != NULL;
}
static int leave_block(MD_BLOCKTYPE type, void *detail, void *userdata) {
    struct context *c = userdata;
    (void)detail;
    if (!c->current || c->current->category!=BLOCK || c->current->type!=(int)type)
        return fail(c,"unbalanced Markdown parser callbacks");
    c->current = c->current->parent; --c->depth;
    return 0;
}
static int enter_span(MD_SPANTYPE type, void *detail, void *userdata) {
    struct context *c = userdata;
    struct node *n;
    MD_ATTRIBUTE *a = NULL;
    if (++c->depth > 128) return fail(c, "Markdown nesting exceeds 128 levels");
    n = new_node(c, SPAN, type);
    if (!n) return 1;
    c->current = n;
    if (type == MD_SPAN_A) {
        a = &((MD_SPAN_A_DETAIL *)detail)->href;
        n->autolink = ((MD_SPAN_A_DETAIL *)detail)->is_autolink;
    } else if (type == MD_SPAN_IMG) a = &((MD_SPAN_IMG_DETAIL *)detail)->src;
    if (a) { n->extra = copy_text(c, a->text, a->size); n->extra_length = a->size; }
    return c->error != NULL;
}
static int leave_span(MD_SPANTYPE type, void *detail, void *userdata) {
    struct context *c = userdata;
    (void)detail;
    if (!c->current || c->current->category!=SPAN || c->current->type!=(int)type)
        return fail(c,"unbalanced Markdown parser callbacks");
    c->current=c->current->parent; --c->depth;
    return 0;
}
static int text_callback(MD_TEXTTYPE type, const MD_CHAR *text, MD_SIZE size, void *userdata) {
    struct context *c = userdata;
    struct node *n = new_node(c, TEXT, type);
    if (!n) return 1;
    n->text = copy_text(c, text, size); n->length = size;
    return c->error != NULL;
}

/* Decode UTF-8 ourselves so invalid input never reaches a terminal verbatim.
 * Cell width follows the process locale's wcwidth, without changing locale. */
static unsigned decode(const unsigned char *s, size_t length, size_t *used) {
    unsigned cp, minimum;
    size_t n, i;
    *used = 1;
    if (s[0] < 0x80) return s[0];
    if (s[0] >= 0xc2 && s[0] <= 0xdf) { n=2; cp=s[0]&31; minimum=0x80; }
    else if (s[0] >= 0xe0 && s[0] <= 0xef) { n=3; cp=s[0]&15; minimum=0x800; }
    else if (s[0] >= 0xf0 && s[0] <= 0xf4) { n=4; cp=s[0]&7; minimum=0x10000; }
    else return 0xfffd;
    if (n > length) return 0xfffd;
    for (i=1; i<n; ++i) {
        if ((s[i]&0xc0) != 0x80) return 0xfffd;
        cp = (cp<<6) | (s[i]&63);
    }
    if (cp < minimum || cp > 0x10ffff || (cp >= 0xd800 && cp <= 0xdfff)) return 0xfffd;
    *used = n;
    return cp;
}
static void push_cp(struct context *c, struct glyphs *v, unsigned cp, unsigned style, int literal) {
    struct glyph g = { .kind=NORMAL };
    if (c->error) return;
    if (cp == '\n') { g.bytes[0]='\n'; g.length=1; g.kind=BREAK; }
    else if (cp == '\t' && literal) { g.bytes[0]='\t'; g.length=1; g.kind=TAB; }
    else if (cp == ' ' || (cp == '\t' && !literal)) {
        if (!literal && v->count && v->items[v->count-1].kind == SPACE) return;
        cp=' '; g.bytes[0]=' '; g.length=1; g.width=1; g.kind=literal ? NORMAL : SPACE;
    } else if (cp < 32 || cp == 127 || (cp >= 0x80 && cp <= 0x9f)) {
        char escaped[16]; size_t i;
        snprintf(escaped, sizeof(escaped), "\\u%04X", cp);
        for (i=0; escaped[i]; ++i) push_cp(c,v,(unsigned char)escaped[i],style,1);
        return;
    } else {
        if (cp < 0x80) { g.bytes[0]=(char)cp; g.length=1; }
        else if (cp < 0x800) {
            g.bytes[0]=(char)(0xc0|(cp>>6)); g.bytes[1]=(char)(0x80|(cp&63)); g.length=2;
        } else if (cp < 0x10000) {
            g.bytes[0]=(char)(0xe0|(cp>>12)); g.bytes[1]=(char)(0x80|((cp>>6)&63));
            g.bytes[2]=(char)(0x80|(cp&63)); g.length=3;
        } else {
            g.bytes[0]=(char)(0xf0|(cp>>18)); g.bytes[1]=(char)(0x80|((cp>>12)&63));
            g.bytes[2]=(char)(0x80|((cp>>6)&63)); g.bytes[3]=(char)(0x80|(cp&63)); g.length=4;
        }
    }
    g.style=(unsigned char)style; g.cp=cp; g.decoration=c->decoration;
    if (reserve(c,(void **)&v->items,&v->capacity,v->count+1,sizeof(g),2u*1024u*1024u)) return;
    v->items[v->count++]=g;
}
static void add_text(struct context *c, struct glyphs *v, const char *s, size_t length,
                     unsigned style, int literal) {
    size_t i=0, used;
    while (i<length && !c->error) {
        unsigned char byte=(unsigned char)s[i];
        if (byte>=32 && byte<127) {
            /* Ordinary text needs neither UTF-8 decoding nor sanitization.
             * Keep capacity and whitespace checks so the glyph limit remains
             * a limit on normalized scalars, not input bytes. */
            do {
                if (byte!=' ' || literal || !v->count || v->items[v->count-1].kind!=SPACE) {
                    if (v->count==v->capacity && reserve(c,(void **)&v->items,&v->capacity,
                            v->count+1,sizeof(*v->items),2u*1024u*1024u)) return;
                    v->items[v->count++]=(struct glyph){.bytes={(char)byte}, .length=1,
                        .style=(unsigned char)style, .kind=byte==' ' && !literal ? SPACE : NORMAL,
                        .decoration=(unsigned char)c->decoration, .cp=byte};
                }
                ++i;
            } while (i<length && (byte=(unsigned char)s[i])>=32 && byte<127);
            continue;
        }
        unsigned cp=decode((const unsigned char *)s+i,length-i,&used);
        push_cp(c,v,cp,style,literal); i+=used;
    }
}
static void add_string(struct context *c, struct glyphs *v, const char *s, unsigned style) {
    add_text(c,v,s,strlen(s),style,0);
}
static int add_entity(struct context *c, struct glyphs *v, const char *s, size_t n, unsigned style) {
    const ENTITY *entity;
    if (n>=4 && s[0]=='&' && s[1]=='#' && s[n-1]==';') {
        unsigned cp=0, base=10; size_t i=2;
        if (s[i]=='x' || s[i]=='X') { base=16; ++i; }
        for (;i<n-1;++i) {
            unsigned digit;
            if (s[i]>='0' && s[i]<='9') digit=(unsigned)(s[i]-'0');
            else if (base==16 && s[i]>='a' && s[i]<='f') digit=(unsigned)(s[i]-'a'+10);
            else if (base==16 && s[i]>='A' && s[i]<='F') digit=(unsigned)(s[i]-'A'+10);
            else return 0;
            if (cp<=0x10ffff) cp=cp*base+digit;
        }
        if (!cp || cp>0x10ffff || (cp>=0xd800 && cp<=0xdfff)) cp=0xfffd;
        push_cp(c,v,cp,style,1); return 1;
    }
    entity=entity_lookup(s,n);
    if (!entity) return 0;
    push_cp(c,v,entity->codepoints[0],style,1);
    if (entity->codepoints[1]) push_cp(c,v,entity->codepoints[1],style,1);
    return 1;
}
static void add_attribute(struct context *c, struct glyphs *v, const char *s, size_t n, unsigned style) {
    size_t i=0, j, used;
    while (i<n && !c->error) {
        if (s[i]!='&') {
            const char *amp=memchr(s+i,'&',n-i);
            j=amp ? (size_t)(amp-s) : n;
            add_text(c,v,s+i,j-i,style,1); i=j;
            continue;
        }
        if (s[i]=='&') {
            for (j=i+1;j<n && j-i<64 && s[j]!=';';++j) {}
            if (j<n && s[j]==';' && add_entity(c,v,s+i,j-i+1,style)) { i=j+1; continue; }
        }
        push_cp(c,v,decode((const unsigned char *)s+i,n-i,&used),style,1); i+=used;
    }
}
static void inline_nodes(struct context *c, struct node *n, struct glyphs *v, unsigned style, int literal) {
    for (;n && !c->error;n=n->next) {
        unsigned next_style=style;
        if (n->category==BLOCK) break;
        if (n->category==TEXT) {
            if (n->type==MD_TEXT_SOFTBR) push_cp(c,v,' ',style,0);
            else if (n->type==MD_TEXT_BR) push_cp(c,v,'\n',style,1);
            else if (n->type==MD_TEXT_NULLCHAR) push_cp(c,v,0xfffd,style,1);
            else if (n->type==MD_TEXT_ENTITY) {
                if (!add_entity(c,v,n->text,n->length,style)) add_text(c,v,n->text,n->length,style,literal);
            } else add_text(c,v,n->text,n->length,style,literal || n->type==MD_TEXT_CODE || n->type==MD_TEXT_HTML);
            continue;
        }
        if (n->category==SPAN) {
            switch (n->type) {
            case MD_SPAN_EM: next_style|=ITALIC; break;
            case MD_SPAN_STRONG: next_style|=BOLD; break;
            case MD_SPAN_CODE: next_style|=CODE; break;
            case MD_SPAN_DEL: next_style|=STRIKE; break;
            case MD_SPAN_A: next_style|=LINK; break;
            case MD_SPAN_IMG: add_string(c,v,"[Image: ",DIM); break;
            default: break;
            }
        }
        inline_nodes(c,n->child,v,next_style,literal);
        if (n->category==SPAN && n->type==MD_SPAN_IMG) add_string(c,v,"]",DIM);
        if (n->category==SPAN && (n->type==MD_SPAN_A || n->type==MD_SPAN_IMG) &&
            n->extra_length && c->options.links && !n->autolink) {
            add_string(c,v," (",DIM);
            add_attribute(c,v,n->extra,n->extra_length,DIM);
            add_string(c,v,")",DIM);
        }
    }
}
static void style_out(struct context *c, unsigned style) {
    char bytes[32]="\033[0"; size_t length=3;
    c->style=style;
    if (!c->options.color) return;
    if (style&BOLD) { memcpy(bytes+length,";1",2); length+=2; }
    if (style&ITALIC) { memcpy(bytes+length,";3",2); length+=2; }
    if (style&DIM) { memcpy(bytes+length,";2",2); length+=2; }
    if (style&STRIKE) { memcpy(bytes+length,";9",2); length+=2; }
    if (style&LINK) { memcpy(bytes+length,";4",2); length+=2; }
    if (style&HEADING) { memcpy(bytes+length,";36",3); length+=3; }
    else if (style&CODE) { memcpy(bytes+length,";33",3); length+=3; }
    bytes[length++]='m'; output(c,bytes,length);
}
static void emit_range(struct context *c, const struct glyphs *v, size_t start, size_t end) {
    char bytes[1024]; size_t length=0;
    unsigned style=0; size_t i;
    int previous=c->decoration;
    for (i=start;i<end && !c->error;++i) {
        const struct glyph *g=&v->items[i];
        if (style!=g->style || c->decoration!=g->decoration || length+g->length>sizeof(bytes)) {
            if (length) output(c,bytes,length);
            length=0;
            if (style!=g->style) { style=g->style; style_out(c,style); }
            c->decoration=g->decoration;
        }
        bytes[length]=g->bytes[0];
        if (g->length>1) memcpy(bytes+length+1,g->bytes+1,g->length-1);
        length+=g->length;
    }
    if (length) output(c,bytes,length);
    if (style) style_out(c,0);
    c->decoration=previous;
}
static void blank(struct context *c) {
    unsigned block=c->active_block; c->active_block=0;
    if (c->output.length && (c->output.length<2 || c->output.data[c->output.length-2]!='\n')) puts_out(c,"\n");
    c->active_block=block;
}
static unsigned prefix_width(struct context *c, const struct prefix *p) {
    size_t a=strlen(p->first), b=strlen(p->rest);
    unsigned width=(unsigned)(a>b?a:b);
    /* Prefixes are generated ASCII. Drop them if they leave no content cell. */
    return width<c->options.width ? width : 0;
}
static void emit_prefix(struct context *c, struct prefix *p) {
    if (prefix_width(c,p)) decoration_out(c,p->pending?p->first:p->rest);
    p->pending=0;
}
static int extend_prefix(struct context *c, struct prefix *p, const char *first, const char *rest) {
    char base[1024]; size_t a=strlen(p->rest), b;
    strcpy(base,p->pending?p->first:p->rest); b=strlen(base);
    if (b+strlen(first)>=sizeof(p->first) || a+strlen(rest)>=sizeof(p->rest))
        return fail(c,"Markdown indentation is too deep");
    strcpy(p->first,base); strcat(p->first,first); strcat(p->rest,rest); p->pending=1;
    return 0;
}
/* Layout assigns each cluster width to its first scalar and advances over
 * the whole cluster at once. Semantic styles remain untouched here. */
static void cluster_glyphs(struct context *c, struct glyphs *v) {
    struct zmd_grapheme_state state={0};
    size_t start=0, i;
    unsigned width=0; int emoji=0, pictographic=0, variation=0, keycap=0;
    /* ASCII-only buffers have no multi-scalar clusters (CR is sanitized).
     * Fall back for the entire buffer if Unicode could join its neighbours. */
    for (i=0;i<v->count;++i) {
        struct glyph *g=&v->items[i];
        if (g->cp>=0x7f) break;
        g->width=(g->kind==BREAK || g->kind==TAB) ? 0 : 1;
        g->end=(unsigned)i+1;
    }
    if (i==v->count) return;
    for (i=0;i<=v->count;++i) {
        int boundary=i==v->count || zmd_grapheme_break(&state,v->items[i].cp);
        if (boundary && i>start) {
            size_t j;
            if (c->options.width_policy==ZMD_WIDTH_UNICODE &&
                (emoji || (pictographic && variation) || keycap)) width=2;
            for (j=start;j<i;++j) {
                v->items[j].width=0; v->items[j].end=i;
                if (i>start+1 && v->items[j].kind==SPACE) v->items[j].kind=NORMAL;
            }
            v->items[start].width=width;
            start=i; width=0; emoji=pictographic=variation=keycap=0;
        }
        if (i<v->count) {
            struct glyph *g=&v->items[i];
            int w=(g->kind==BREAK || g->kind==TAB) ? 0 : g->cp<0x7f ? 1 : wcwidth((wchar_t)g->cp);
            if (w<0) w=1;
            if (c->options.width_policy==ZMD_WIDTH_WCWIDTH_SUM) width+=(unsigned)w;
            else if ((unsigned)w>width) width=(unsigned)w;
            emoji |= zmd_emoji_presentation(g->cp);
            pictographic |= zmd_extended_pictographic(g->cp);
            variation |= g->cp==0xfe0f;
            keycap |= g->cp==0x20e3 && (v->items[start].cp=='#' ||
                v->items[start].cp=='*' || (v->items[start].cp>='0' && v->items[start].cp<='9'));
        }
    }
}
static void expand_tabs(struct context *c, struct glyphs *v) {
    struct glyphs result={0}; unsigned column=0; size_t i;
    cluster_glyphs(c,v);
    for (i=0;i<v->count && v->items[i].kind!=TAB;++i) {}
    if (i==v->count) return;
    for (i=0;i<v->count && !c->error;++i) {
        struct glyph g=v->items[i];
        if (g.kind==TAB) {
            unsigned n=4-column%4;
            int previous=c->decoration; c->decoration=g.decoration;
            while (n--) { push_cp(c,&result,' ',g.style,1); ++column; }
            c->decoration=previous;
        } else {
            if (reserve(c,(void **)&result.items,&result.capacity,result.count+1,sizeof(g),2u*1024u*1024u)) break;
            result.items[result.count++]=g;
            if (g.kind==BREAK) column=0; else column+=g.width;
        }
    }
    free(v->items); *v=result; cluster_glyphs(c,v);
}
static struct row next_row(struct context *c, const struct glyphs *v, size_t *position,
                            unsigned width, int literal) {
    struct row r={*position,*position,0};
    size_t i=*position, space=(size_t)-1;
    unsigned at_space=0;
    if (!literal) while (i<v->count && v->items[i].kind==SPACE) ++i;
    r.start=i;
    while (i<v->count && v->items[i].kind!=BREAK) {
        unsigned w=v->items[i].width;
        if (r.width+w>width) {
            if (!literal && v->items[i].kind==SPACE) break;
            if (i==r.start) { fail(c,"width is too small for a complete character"); ++i; }
            else if (!literal && space!=(size_t)-1) { i=space; r.width=at_space; }
            break;
        }
        if (!literal && v->items[i].kind==SPACE) { space=i; at_space=r.width; }
        r.width+=w; i=v->items[i].end;
    }
    r.end=i;
    if (!literal) while (r.end>r.start && v->items[r.end-1].kind==SPACE) { --r.end; --r.width; }
    if (i<v->count && v->items[i].kind==BREAK) ++i;
    else if (!literal) while (i<v->count && v->items[i].kind==SPACE) ++i;
    *position=i;
    return r;
}
static void emit_wrapped(struct context *c, struct glyphs *v, struct prefix *p, int literal) {
    size_t position=0;
    unsigned width=c->options.width-prefix_width(c,p);
    expand_tabs(c,v);
    while (position<v->count && !c->error) {
        struct row r=next_row(c,v,&position,width,literal);
        if (c->error) break;
        emit_prefix(c,p); emit_range(c,v,r.start,r.end); puts_out(c,"\n");
    }
}
static void render_children(struct context *, struct node *, struct prefix *, int);
static void render_table(struct context *, struct node *, struct prefix *);
static void render_block(struct context *c, struct node *n, struct prefix *p) {
    struct glyphs text={0};
    unsigned previous=c->active_block; c->active_block=n->id;
    switch (n->type) {
    case MD_BLOCK_DOC: render_children(c,n->child,p,0); break;
    case MD_BLOCK_QUOTE: {
        struct prefix q=*p;
        if (!extend_prefix(c,&q,"> ","> ")) render_children(c,n->child,&q,0);
        p->pending=0; break;
    }
    case MD_BLOCK_UL: case MD_BLOCK_OL: {
        struct node *item; unsigned long number=n->value; int first=1;
        for (item=n->child;item && !c->error;item=item->next) {
            struct prefix q=*p; char marker[48], indent[48];
            if (!first && !n->tight) blank(c);
            if (item->task) snprintf(marker,sizeof(marker),"- [%c] ",item->task==2?'x':' ');
            else if (n->type==MD_BLOCK_OL) snprintf(marker,sizeof(marker),"%lu. ",number++);
            else strcpy(marker,"- ");
            memset(indent,' ',strlen(marker)); indent[strlen(marker)]=0;
            if (extend_prefix(c,&q,marker,indent)) break;
            c->active_block=item->id;
            if (item->child) render_children(c,item->child,&q,n->tight);
            else { emit_prefix(c,&q); puts_out(c,"\n"); }
            p->pending=0; first=0;
        }
        break;
    }
    case MD_BLOCK_H:
        inline_nodes(c,n->child,&text,BOLD|HEADING,0);
        emit_wrapped(c,&text,p,0); break;
    case MD_BLOCK_HR: {
        unsigned width=c->options.width-prefix_width(c,p), i;
        emit_prefix(c,p);
        for (i=0;i<width;++i) decoration_out(c,"-");
        puts_out(c,"\n"); break;
    }
    case MD_BLOCK_CODE: {
        struct prefix q=*p;
        c->label=1; c->decoration=1;
        if (n->extra_length)
            add_attribute(c,&text,n->extra,n->extra_length,DIM);
        else add_string(c,&text,"code",DIM);
        c->decoration=0;
        emit_wrapped(c,&text,&q,0); free(text.items); memset(&text,0,sizeof(text));
        c->label=0;
        if (!extend_prefix(c,&q,"| ","| ")) {
            inline_nodes(c,n->child,&text,CODE,1); emit_wrapped(c,&text,&q,1);
        }
        p->pending=0; break;
    }
    case MD_BLOCK_HTML:
        inline_nodes(c,n->child,&text,DIM,1); emit_wrapped(c,&text,p,1); break;
    case MD_BLOCK_TABLE: render_table(c,n,p); break;
    default:
        inline_nodes(c,n->child,&text,0,0); emit_wrapped(c,&text,p,0); break;
    }
    free(text.items); c->active_block=previous;
}
static void render_children(struct context *c, struct node *n, struct prefix *p, int compact) {
    int first=1;
    while (n && !c->error) {
        if (!first && !compact) blank(c);
        if (n->category==BLOCK) {
            render_block(c,n,p); n=n->next;
        } else {
            /* MD4C omits paragraph callbacks inside tight list items. */
            struct glyphs text={0};
            inline_nodes(c,n,&text,0,0); emit_wrapped(c,&text,p,0); free(text.items);
            do { n=n->next; } while (n && n->category!=BLOCK);
        }
        first=0;
    }
}

struct cell { struct glyphs text; struct rows rows; int align; };
static void repeat_out(struct context *c, char byte, unsigned n) {
    char bytes[128]; memset(bytes,byte,sizeof(bytes));
    int previous=c->decoration; c->decoration=1;
    while (n && !c->error) {
        size_t length=n<sizeof(bytes) ? n : sizeof(bytes);
        output(c,bytes,length); n-=(unsigned)length;
    }
    c->decoration=previous;
}
static void spaces(struct context *c, unsigned n) { repeat_out(c,' ',n); }
static void table_border(struct context *c, struct prefix *p, unsigned *widths, unsigned columns) {
    unsigned col;
    emit_prefix(c,p); decoration_out(c,"+");
    for (col=0;col<columns;++col) {
        repeat_out(c,'-',widths[col]+2);
        decoration_out(c,"+");
    }
    puts_out(c,"\n");
}
static void render_table(struct context *c, struct node *n, struct prefix *p) {
    struct node *section, *tr, *td;
    struct cell *cells=NULL;
    unsigned *widths=NULL, *minimum=NULL, columns=n->value, rows=0, r=0, col;
    unsigned budget=c->options.width-prefix_width(c,p), total=0;
    size_t count, i;
    if (!columns || columns>256) { fail(c,"table exceeds 256 columns"); return; }
    for (section=n->child;section;section=section->next)
        for (tr=section->child;tr;tr=tr->next) ++rows;
    count=(size_t)rows*columns;
    if (count>50000) { fail(c,"table exceeds 50000 cells"); return; }
    cells=calloc(count?count:1,sizeof(*cells));
    widths=calloc(columns,sizeof(*widths)); minimum=calloc(columns,sizeof(*minimum));
    if (!cells || !widths || !minimum) { fail(c,"out of memory"); goto done; }
    for (col=0;col<columns;++col) widths[col]=minimum[col]=3;
    for (section=n->child;section;section=section->next) {
        for (tr=section->child;tr;tr=tr->next,++r) {
            for (td=tr->child,col=0;td && col<columns;td=td->next,++col) {
                struct cell *cell=&cells[(size_t)r*columns+col]; unsigned line=0;
                cell->align=td->align;
                inline_nodes(c,td->child,&cell->text,r==0?BOLD:0,0);
                expand_tabs(c,&cell->text);
                for (i=0;i<cell->text.count;++i) {
                    struct glyph *g=&cell->text.items[i];
                    if (g->width>minimum[col]) minimum[col]=g->width;
                    if (g->kind==BREAK) line=0; else line+=g->width;
                    if (line>widths[col]) widths[col]=line;
                }
            }
        }
    }
    total=3*columns+1;
    for (col=0;col<columns;++col) total+=minimum[col];
    if (total>budget) {
        /* When a grid cannot fit, stack cells with their header labels. */
        for (r=1;r<rows && !c->error;++r) {
            if (r>1) blank(c);
            for (col=0;col<columns;++col) {
                struct glyphs line={0};
                struct glyphs *header=&cells[col].text, *body=&cells[(size_t)r*columns+col].text;
                for (i=0;i<header->count;++i) {
                    struct glyph g=header->items[i];
                    if (reserve(c,(void **)&line.items,&line.capacity,line.count+1,sizeof(g),2u*1024u*1024u)) break;
                    line.items[line.count++]=g;
                }
                c->decoration=1; add_string(c,&line,": ",0); c->decoration=0;
                for (i=0;i<body->count;++i) {
                    struct glyph g=body->items[i];
                    if (reserve(c,(void **)&line.items,&line.capacity,line.count+1,sizeof(g),2u*1024u*1024u)) break;
                    line.items[line.count++]=g;
                }
                emit_wrapped(c,&line,p,0); free(line.items);
            }
        }
        if (rows==1) for (col=0;col<columns;++col) emit_wrapped(c,&cells[col].text,p,0);
        goto done;
    }
    total=3*columns+1;
    for (col=0;col<columns;++col) {
        if (widths[col]>budget) widths[col]=budget;
        total+=widths[col];
    }
    if (total>budget) {
        /* Cap the excess above each column's minimum in O(columns*log(width)).
         * The old one-cell-at-a-time loop broke ties left to right; retain
         * that exact allocation for the final partial level. */
        unsigned lo=0, hi=budget, excess=total-budget;
        while (lo<hi) {
            unsigned cap=lo+(hi-lo)/2, removed=0;
            for (col=0;col<columns;++col)
                if (widths[col]-minimum[col]>cap) removed+=widths[col]-minimum[col]-cap;
            if (removed>excess) lo=cap+1; else hi=cap;
        }
        for (col=0;col<columns;++col) if (widths[col]-minimum[col]>lo) {
            total-=widths[col]-minimum[col]-lo;
            widths[col]=minimum[col]+lo;
        }
        for (col=0;col<columns && total>budget;++col)
            if (widths[col]-minimum[col]==lo) { --widths[col]; --total; }
    }
    for (r=0;r<rows && !c->error;++r) for (col=0;col<columns;++col) {
        struct cell *cell=&cells[(size_t)r*columns+col]; size_t position=0;
        while (position<cell->text.count && !c->error) {
            struct row row=next_row(c,&cell->text,&position,widths[col],0);
            if (!cell->rows.count) { cell->rows.first=row; cell->rows.count=1; continue; }
            if (reserve(c,(void **)&cell->rows.items,&cell->rows.capacity,cell->rows.count+1,sizeof(row),100000)) break;
            if (cell->rows.count==1) cell->rows.items[0]=cell->rows.first;
            cell->rows.items[cell->rows.count++]=row;
        }
    }
    table_border(c,p,widths,columns);
    for (r=0;r<rows && !c->error;++r) {
        size_t height=1, y;
        for (col=0;col<columns;++col)
            if (cells[(size_t)r*columns+col].rows.count>height) height=cells[(size_t)r*columns+col].rows.count;
        for (y=0;y<height;++y) {
            emit_prefix(c,p); decoration_out(c,"|");
            for (col=0;col<columns;++col) {
                struct cell *cell=&cells[(size_t)r*columns+col];
                struct row row={0,0,0}; unsigned padding,left=0;
                if (y<cell->rows.count) row=cell->rows.count==1 ? cell->rows.first : cell->rows.items[y];
                padding=widths[col]-row.width;
                if (cell->align==MD_ALIGN_RIGHT) left=padding;
                else if (cell->align==MD_ALIGN_CENTER) left=padding/2;
                spaces(c,1+left); emit_range(c,&cell->text,row.start,row.end);
                spaces(c,1+padding-left); decoration_out(c,"|");
            }
            puts_out(c,"\n");
        }
        if (r==0 || r+1==rows) table_border(c,p,widths,columns);
    }
done:
    if (cells) for (i=0;i<count;++i) { free(cells[i].text.items); free(cells[i].rows.items); }
    free(cells); free(widths); free(minimum);
}

static const char *block_kind(int type) {
    switch (type) {
    case MD_BLOCK_DOC: return "document";
    case MD_BLOCK_QUOTE: return "quote";
    case MD_BLOCK_UL: return "unordered-list";
    case MD_BLOCK_OL: return "ordered-list";
    case MD_BLOCK_LI: return "list-item";
    case MD_BLOCK_HR: return "rule";
    case MD_BLOCK_H: return "heading";
    case MD_BLOCK_CODE: return "code";
    case MD_BLOCK_HTML: return "html";
    case MD_BLOCK_P: return "paragraph";
    case MD_BLOCK_TABLE: return "table";
    case MD_BLOCK_THEAD: return "table-head";
    case MD_BLOCK_TBODY: return "table-body";
    case MD_BLOCK_TR: return "table-row";
    case MD_BLOCK_TH: return "table-heading";
    case MD_BLOCK_TD: return "table-cell";
    default: return "unknown";
    }
}
static void pair_key(struct context *c, const char *value, size_t length, const char *key, int n) {
    char *k, *v;
    struct document_storage *storage=(struct document_storage *)c->document;
    if (c->error) return;
    if (n<0 || n>=128) { fail(c,"structured key exceeds limit"); return; }
    if (length+(size_t)n+2>ZMDOWN_OUTPUT_LIMIT-c->pair_bytes) {
        fail(c,"structured output exceeds 32 MiB"); return;
    }
    if (reserve(c,(void **)&c->document->pairs,&c->pair_capacity,
                (c->document->count+1)*2+1,sizeof(char *),ZMDOWN_PAIR_LIMIT*2+1)) return;
    k=arena_alloc(c,&storage->strings,(size_t)n+length+2,1);
    if (!k) return;
    v=k+(size_t)n+1;
    memcpy(k,key,(size_t)n+1); if (length) memcpy(v,value,length); v[length]=0;
    c->document->pairs[c->document->count*2]=k;
    c->document->pairs[c->document->count*2+1]=v;
    ++c->document->count; c->document->pairs[c->document->count*2]=NULL;
    c->pair_bytes+=length+(size_t)n+2;
}
static void pair(struct context *c, const char *value, size_t length, const char *key) {
    pair_key(c,value,length,key,(int)strlen(key));
}
static char *decimal(char *end, size_t value) {
    do { *--end=(char)('0'+value%10); value/=10; } while (value);
    return end;
}
/* Internal prefixes fit in 64 bytes: two labels and bounded row/span indices.
 * Build the row portion once and append each span index in place. */
static size_t index_prefix(char *key, const char *label, size_t index) {
    char number[3*sizeof(size_t)+1], *end=number+sizeof(number), *p=decimal(end,index);
    size_t a=strlen(label), b=(size_t)(end-p);
    memcpy(key,label,a); memcpy(key+a,p,b);
    key[a+b]=','; key[a+b+1]=0;
    return a+b+1;
}
static void number_pair(struct context *c, size_t value, const char *key) {
    char number[3*sizeof(size_t)+1], *end=number+sizeof(number), *p=decimal(end,value);
    pair(c,p,(size_t)(end-p),key);
}
static void field_pair(struct context *c, const char *value, size_t length,
                        const char *prefix, const char *field) {
    char key[128]; size_t a=strlen(prefix), b=strlen(field);
    if (a+b>=sizeof(key)) { fail(c,"structured key exceeds limit"); return; }
    memcpy(key,prefix,a); memcpy(key+a,field,b+1);
    pair_key(c,value,length,key,(int)(a+b));
}
static void number_field(struct context *c, size_t value, const char *prefix, const char *field) {
    char number[3*sizeof(size_t)+1], *end=number+sizeof(number), *p=end;
    p=decimal(end,value);
    field_pair(c,p,(size_t)(end-p),prefix,field);
}
static void glyph_pair(struct context *c, struct glyphs *v, const char *prefix, const char *field) {
    size_t i, length=0; char *text;
    for (i=0;i<v->count;++i) length+=v->items[i].length;
    text=malloc(length+1);
    if (!text) { fail(c,"out of memory"); return; }
    length=0;
    for (i=0;i<v->count;++i) {
        memcpy(text+length,v->items[i].bytes,v->items[i].length); length+=v->items[i].length;
    }
    field_pair(c,text,length,prefix,field); free(text);
}
/* Normalize styles only after layout: generated indentation and table padding
 * may share a grapheme with a leading combining mark or trailing prepend. */
static void normalize_cluster_styles(struct glyphs *v) {
    size_t start=0;
    while (start<v->count) {
        size_t end=v->items[start].end, base=start, j;
        for (j=start;j<end;++j) if (zmd_grapheme_base(v->items[j].cp)) { base=j; break; }
        for (j=start;j<end;++j) v->items[j].style=v->items[base].style;
        start=end;
    }
}
static void normalized_output(struct context *c, int color) {
    struct context result={0}; size_t i;
    result.options=c->options; result.options.color=color;
    result.collect=c->document!=NULL;
    for (i=0;i<c->line_count && !c->error && !result.error;++i) {
        struct rendered_line *line=&c->lines[i]; struct glyphs text={0}; size_t j;
        for (j=0;j<line->length;++j) if ((unsigned char)c->output.data[line->start+j]>=0x7f) break;
        if (j==line->length) {
            unsigned style=0;
            result.active_block=line->block; result.label=line->label;
            for (j=0;j<line->count;++j) {
                struct rendered_span *span=&c->spans[line->first+j];
                result.decoration=span->decoration;
                if (style!=span->style) { style=span->style; style_out(&result,style); }
                output(&result,c->output.data+span->start,span->length);
            }
            if (style) style_out(&result,0);
            puts_out(&result,"\n");
            continue;
        }
        for (j=0;j<line->count && !c->error;++j) {
            struct rendered_span *span=&c->spans[line->first+j];
            c->decoration=span->decoration;
            add_text(c,&text,c->output.data+span->start,span->length,span->style,1);
        }
        c->decoration=0;
        cluster_glyphs(c,&text); normalize_cluster_styles(&text);
        result.active_block=line->block; result.label=line->label;
        emit_range(&result,&text,0,text.count); puts_out(&result,"\n");
        free(text.items);
    }
    if (!result.error) output(&result,"",0);
    free(c->output.data); free(c->spans); free(c->lines);
    c->output=result.output; c->spans=result.spans; c->lines=result.lines;
    c->span_count=result.span_count; c->span_capacity=result.span_capacity;
    c->line_count=result.line_count; c->line_capacity=result.line_capacity;
    c->line_open=result.line_open;
    if (result.error) fail(c,result.error);
}
/* Measure the final row, including clusters touching generated padding.
 * Sum mode reports scalar contributions per span; the default assigns a
 * whole cluster's width to the span containing its first scalar. */
static void measure_line(struct context *c, struct rendered_line *line) {
    struct glyphs glyphs={0}; size_t i, offset=line->start, span=line->first;
    for (i=0;i<line->length;++i) if ((unsigned char)c->output.data[offset+i]>=0x7f) break;
    if (i==line->length) {
        for (i=0;i<line->count;++i) c->spans[span+i].cells=(unsigned)c->spans[span+i].length;
        line->cells=(unsigned)line->length;
        if (line->cells>c->options.width) fail(c,"structured row exceeds requested width");
        return;
    }
    add_text(c,&glyphs,c->output.data+line->start,line->length,0,1);
    cluster_glyphs(c,&glyphs);
    for (i=0;i<glyphs.count && !c->error;++i) {
        while (span<line->first+line->count &&
               offset>=c->spans[span].start+c->spans[span].length) ++span;
        if (span==line->first+line->count) { fail(c,"invalid structured span boundary"); break; }
        if (c->options.width_policy==ZMD_WIDTH_WCWIDTH_SUM) {
            int width=wcwidth((wchar_t)glyphs.items[i].cp);
            c->spans[span].cells+=width<0 ? 1u : (unsigned)width;
        } else c->spans[span].cells+=glyphs.items[i].width;
        line->cells+=glyphs.items[i].width; offset+=glyphs.items[i].length;
    }
    free(glyphs.items);
    if (line->cells>c->options.width) fail(c,"structured row exceeds requested width");
}
static void collect_document(struct context *c) {
    size_t i,j; struct node *n;
    pair(c,ZMDOWN_SCHEMA_VERSION,strlen(ZMDOWN_SCHEMA_VERSION),"schema");
    const char *policy=c->options.width_policy==ZMD_WIDTH_WCWIDTH_SUM ? ZMDOWN_SUM_WIDTH_POLICY : ZMDOWN_WIDTH_POLICY;
    const char *policy_name=c->options.width_policy==ZMD_WIDTH_WCWIDTH_SUM ? "wcwidth-sum" : "unicode";
    const char *styles=c->options.cluster_styles==ZMD_STYLES_FIRST_BASE ? "first-base" : "preserve";
    pair(c,policy,strlen(policy),"width_policy");
    pair(c,policy_name,strlen(policy_name),"width_policy_name");
    pair(c,styles,strlen(styles),"cluster_styles");
    const char *breaks=c->options.hard_soft_breaks ? "newline" : "space";
    pair(c,breaks,strlen(breaks),"soft_breaks");
    number_pair(c,c->options.width,"width");
    number_pair(c,c->line_count,"line_count");
    number_pair(c,c->block_count,"block_count");
    number_pair(c,BOLD,"style,strong"); number_pair(c,ITALIC,"style,emphasis");
    number_pair(c,CODE,"style,code"); number_pair(c,STRIKE,"style,deletion");
    number_pair(c,HEADING,"style,heading"); number_pair(c,DIM,"style,muted");
    number_pair(c,LINK,"style,link");
    for (i=0;i<c->line_count && !c->error;++i) {
        struct rendered_line *line=&c->lines[i];
        char key[64];
        const char *role=line->label ? "code-label" : line->block ? "content" : "spacer";
        size_t prefix_length=index_prefix(key,"line,",i+1);
        measure_line(c,line);
        field_pair(c,c->output.data+line->start,line->length,key,"text");
        number_field(c,line->cells,key,"cells");
        number_field(c,line->block,key,"block");
        field_pair(c,role,strlen(role),key,"role");
        number_field(c,line->count,key,"span_count");
        for (j=0;j<line->count && !c->error;++j) {
            struct rendered_span *span=&c->spans[line->first+j];
            index_prefix(key+prefix_length,"span,",j+1);
            field_pair(c,c->output.data+span->start,span->length,key,"text");
            number_field(c,span->cells,key,"cells");
            number_field(c,span->style,key,"style");
            const char *span_role=span->decoration ? "decoration" : "content";
            field_pair(c,span_role,strlen(span_role),key,"role");
        }
    }
    for (n=c->allocated;n && !c->error;n=n->allocated_next) if (n->category==BLOCK) {
        const char *kind=block_kind(n->type);
        char key[64]; index_prefix(key,"block,",n->id);
        field_pair(c,kind,strlen(kind),key,"kind");
        number_field(c,n->parent?n->parent->id:0,key,"parent");
        if (n->type==MD_BLOCK_H) number_field(c,n->value,key,"level");
        if (n->type==MD_BLOCK_CODE) {
            struct glyphs code={0}, language={0};
            number_field(c,(size_t)n->fenced,key,"fenced");
            inline_nodes(c,n->child,&code,CODE,1);
            add_attribute(c,&language,n->extra,n->extra_length,0);
            glyph_pair(c,&code,key,"text"); glyph_pair(c,&language,key,"language");
            free(code.items); free(language.items);
        }
    }
}
void zmd_document_free(struct zmd_document *document) {
    if (!document) return;
    arena_free(&((struct document_storage *)document)->strings);
    free(document->pairs); free(document);
}
static int render(const char *input, size_t length, const struct zmd_options *options,
                  char **result, size_t *result_length, struct zmd_document *document,
                  const char **error) {
    struct context c={0}; struct prefix prefix={{0},{0},1};
    MD_PARSER parser={0}; int status;
    *result=NULL; *result_length=0; *error=NULL;
    if (length>ZMDOWN_INPUT_LIMIT) { *error="input exceeds 4 MiB"; return 1; }
    if (!options || !options->width || options->width>4096) { *error="width must be between 1 and 4096"; return 1; }
    if (options->width_policy!=ZMD_WIDTH_UNICODE && options->width_policy!=ZMD_WIDTH_WCWIDTH_SUM) {
        *error="unsupported width policy"; return 1;
    }
    if (options->cluster_styles!=ZMD_STYLES_PRESERVE && options->cluster_styles!=ZMD_STYLES_FIRST_BASE) {
        *error="unsupported cluster styles"; return 1;
    }
    if (options->hard_soft_breaks!=0 && options->hard_soft_breaks!=1) {
        *error="unsupported soft break mode"; return 1;
    }
    c.options=*options; c.document=document;
    c.collect=document || options->cluster_styles==ZMD_STYLES_FIRST_BASE;
    if (c.collect) c.options.color=0;
    parser.flags=options->gfm ? MD_DIALECT_GITHUB : MD_DIALECT_COMMONMARK;
    if (options->hard_soft_breaks) parser.flags|=MD_FLAG_HARD_SOFT_BREAKS;
    parser.enter_block=enter_block; parser.leave_block=leave_block;
    parser.enter_span=enter_span; parser.leave_span=leave_span; parser.text=text_callback;
    status=md_parse(input,(MD_SIZE)length,&parser,&c);
    if (status && !c.error) fail(&c,"Markdown parser failed");
    if (!c.error && c.root) render_block(&c,c.root,&prefix);
    /* Ensure even an empty successful result is an owned, terminated string. */
    if (!c.error) output(&c,"",0);
    if (!c.error && options->cluster_styles==ZMD_STYLES_FIRST_BASE)
        normalized_output(&c,document ? 0 : options->color);
    if (!c.error && document) collect_document(&c);
    free(c.spans); free(c.lines);
    arena_free(&c.tree);
    if (c.error) { free(c.output.data); *error=c.error; return 1; }
    *result=c.output.data; *result_length=c.output.length;
    return 0;
}

int zmd_render(const char *input, size_t length, const struct zmd_options *options,
               char **result, size_t *result_length, const char **error) {
    return render(input,length,options,result,result_length,NULL,error);
}
int zmd_render_document(const char *input, size_t length, const struct zmd_options *options,
                        struct zmd_document **result, const char **error) {
    struct zmd_document *document=calloc(1,sizeof(struct document_storage));
    char *text=NULL; size_t text_length=0; int status;
    *result=NULL; *error=NULL;
    if (!document) { *error="out of memory"; return 1; }
    status=render(input,length,options,&text,&text_length,document,error); free(text);
    if (status) { zmd_document_free(document); return status; }
    *result=document; return 0;
}
