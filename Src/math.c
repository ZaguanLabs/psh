/*
 * math.c - mathematical expression evaluation
 *
 * This file is part of zsh, the Z shell.
 *
 * Copyright (c) 1992-1997 Paul Falstad
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and to distribute modified versions of this software for any
 * purpose, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 *
 * In no event shall Paul Falstad or the Zsh Development Group be liable
 * to any party for direct, indirect, special, incidental, or consequential
 * damages arising out of the use of this software and its documentation,
 * even if Paul Falstad and the Zsh Development Group have been advised of
 * the possibility of such damage.
 *
 * Paul Falstad and the Zsh Development Group specifically disclaim any
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose.  The software
 * provided hereunder is on an "as is" basis, and Paul Falstad and the
 * Zsh Development Group have no obligation to provide maintenance,
 * support, updates, enhancements, or modifications.
 *
 */

struct mathvalue;

#include "zsh.mdh"
#include "math.pro"

#include <math.h>

/* nonzero means we are not evaluating, just parsing */
 
/**/
int noeval;
 
/* integer zero */

/**/
mod_export mnumber zero_mnumber;

/*
 * The last value we computed:  note this isn't cleared
 * until the next computation, unlike yyval.
 * Everything else is saved and returned to allow recursive calls.
 */
/**/
mnumber lastmathval;

/* last input base we used */

/**/
int lastbase;
 
static char *ptr;

static mnumber yyval;
static char *yylval;
static int yylval_len;

#define MAX_MLEVEL 256

static int mlevel = 0;

/* Retain an immutable conversion locale for the life of the process. */
#if defined(USE_LOCALE) && defined(HAVE_MATH_STRTOD_L)
#define PSH_MATH_LOCALE_OBJECT 1
static locale_t math_c_locale;
#endif

/* != 0 means recognize unary plus, minus, etc. */

static int unary = 1;

/* LR = left-to-right associativity *
 * RL = right-to-left associativity *
 * BOOL = short-circuiting boolean   */

#define LR   0x0000
#define RL   0x0001
#define BOOL 0x0002

#define MTYPE(x)  ((x) & 3)

/*
 * OP_A2    2 arguments
 * OP_A2IR  2 arguments, return integer
 * OP_A2IO  2 arguments, must be integer, return integer
 * OP_E2    2 arguments with assignment
 * OP_E2IO  2 arguments with assignment, must be integer, return integer
 * OP_OP    None of the above, but occurs where we are expecting an operator
 *          rather than an operand.
 * OP_OPF   Followed by an operator, not an operand.
 *
 * OP_A2*, OP_E2*, OP_OP*:
 *   Occur when we need an operator; the next object must be an operand,
 *   unless OP_OPF is also supplied.
 *
 * Others:
 *   Occur when we need an operand; the next object must also be an operand,
 *   unless OP_OPF is also supplied.
 */
#define OP_A2   0x0004
#define OP_A2IR 0x0008
#define OP_A2IO 0x0010
#define OP_E2   0x0020
#define OP_E2IO 0x0040
#define OP_OP   0x0080
#define OP_OPF  0x0100

#define M_INPAR 0
#define M_OUTPAR 1
#define NOT 2
#define COMP 3
#define POSTPLUS 4
#define POSTMINUS 5
#define UPLUS 6
#define UMINUS 7
#define AND 8
#define XOR 9
#define OR 10
#define MUL 11
#define DIV 12
#define MOD 13
#define PLUS 14
#define MINUS 15
#define SHLEFT 16
#define SHRIGHT 17
#define LES 18
#define LEQ 19
#define GRE 20
#define GEQ 21
#define DEQ 22
#define NEQ 23
#define DAND 24
#define DOR 25
#define DXOR 26
#define QUEST 27
#define COLON 28
#define EQ 29
#define PLUSEQ 30
#define MINUSEQ 31
#define MULEQ 32
#define DIVEQ 33
#define MODEQ 34
#define ANDEQ 35
#define XOREQ 36
#define OREQ 37
#define SHLEFTEQ 38
#define SHRIGHTEQ 39
#define DANDEQ 40
#define DOREQ 41
#define DXOREQ 42
#define COMMA 43
#define EOI 44
#define PREPLUS 45
#define PREMINUS 46
#define NUM 47
#define ID 48
#define POWER 49
#define CID 50
#define POWEREQ 51
#define FUNC 52
#define TOKCOUNT 53

/*
 * Operator precedences: in reverse order, i.e. lower number, high precedence.
 * These are the C precedences.
 *
 * 0   Non-operators: NUM (numeric constant), ID (identifier),
 *                    CID (identifier with '#'), FUNC (math function)
 * 1   Opening parenthesis: M_INPAR '('  (for convenience, not an operator)
 * 2   Unary operators: PREPLUS/POSTPLUS '++', PREMINUS/POSTMINUS '--',
 *                      NOT '!', COMP '~', UPLUS '+', UMINUS '-'
 * 3   POWER '**' (not in C but at high precedence in Perl)
 * 4   MUL '*', DIV '/', MOD '%'
 * 5   PLUS '+', MINUS '-'
 * 6   SHLEFT '<<', SHRIGHT '>>'
 * 7   GRE '>', 'GEQ' '>=', LES '<', LEQ '<='
 * 8   DEQ '==', NEQ '!='
 * 9   AND '&'
 * 10  XOR '^'
 * 11  OR  '|'
 * 12  DAND '&&'
 * 13  DXOR '^^' (not in C)
 * 14  DOR '||'
 * 15  QUEST '?'
 * 16  COLON ':'
 * 17  EQ '=', PLUSEQ '+=', MINUSEQ '-=', MULEQ '*=', DIVEQ '/=',
 *     MODEQ '%=', ANDEQ '&=', XOREQ '^=', OREQ '|=',
 *     SHFLEFTEQ '<<=', SHRIGHTEQ '>>=', DANDEQ '&&=', DOREQ '||=',
 *     DXOREQ '^^='
 * 18 COMMA ','
 * 137 M_OUTPAR ')' (for convenience, not an operator)
 * 200 EOI (end of input:  for convenience, not an operator)
 */
static int c_prec[TOKCOUNT] =
{
/*        M_INPAR   M_OUTPAR     NOT       COMP     POSTPLUS */
/*  0 */     1,       137,        2,        2,         2,
/*        POSTMINUS   UPLUS     UMINUS     AND        XOR    */
/*  5 */     2,         2,        2,        9,        10,
/*          OR         MUL       DIV       MOD       PLUS    */
/* 10 */    11,         4,        4,        4,         5,
/*         MINUS      SHLEFT   SHRIGHT     LES        LEQ    */
/* 15 */     5,         6,        6,        7,         7,
/*          GRE        GEQ       DEQ       NEQ       DAND    */
/* 20 */     7,         7,        8,        8,        12,
/*          DOR        DXOR     QUEST     COLON       EQ     */
/* 25 */    14,        13,       15,       16,        17,
/*         PLUSEQ    MINUSEQ    MULEQ     DIVEQ      MODEQ   */
/* 30 */    17,        17,       17,       17,        17,
/*         ANDEQ      XOREQ     OREQ    SHLEFTEQ   SHRIGHTEQ */
/* 35 */    17,        17,       17,       17,        17,
/*        DANDEQ      DOREQ    DXOREQ    COMMA       EOI     */
/* 40 */    17,        17,       17,       18,       200,
/*       PREPLUS    PREMINUS     NUM        ID       POWER   */
/* 45 */     2,         2,        0,        0,         3,
/*          CID      POWEREQ     FUNC  */
/* 50 */     0,        17,        0
};

/*
 * Operator precedences: in reverse order, i.e. lower number, high precedence.
 * These are the default zsh precedences.
 *
 * 0   Non-operators: NUM (numeric constant), ID (identifier),
 *                    CID (identifier with '#'), FUNC (math function)
 * 1   Opening parenthesis: M_INPAR '('  (for convenience, not an operator)
 * 2   Unary operators: PREPLUS/POSTPLUS '++', PREMINUS/POSTMINUS '--',
 *                      NOT '!', COMP '~', UPLUS '+', UMINUS '-' 
 * 3   SHLEFT '<<', SHRIGHT '>>'
 * 4   AND '&'
 * 5   XOR '^'
 * 6   OR  '|'
 * 7   POWER '**' (not in C but at high precedence in Perl)
 * 8   MUL '*', DIV '/', MOD '%'
 * 9   PLUS '+', MINUS '-'
 * 10  GRE '>', 'GEQ' '>=', LES '<', LEQ '<='
 * 11  DEQ '==', NEQ '!='
 * 12  DAND '&&'
 * 13  DOR '||', DXOR '^^' (not in C)
 * 14  QUEST '?'
 * 15  COLON ':'
 * 16  EQ '=', PLUSEQ '+=', MINUSEQ '-=', MULEQ '*=', DIVEQ '/=',
 *     MODEQ '%=', ANDEQ '&=', XOREQ '^=', OREQ '|=',
 *     SHFLEFTEQ '<<=', SHRIGHTEQ '>>=', DANDEQ '&&=', DOREQ '||=',
 *     DXOREQ '^^='
 * 17 COMMA ','
 * 137 M_OUTPAR ')' (for convenience, not an operator)
 * 200 EOI (end of input:  for convenience, not an operator)
 */
static int z_prec[TOKCOUNT] =
{
/*        M_INPAR   M_OUTPAR     NOT       COMP     POSTPLUS */
/*  0 */     1,       137,        2,        2,         2,
/*        POSTMINUS   UPLUS     UMINUS     AND        XOR    */
/*  5 */     2,         2,        2,        4,         5,
/*          OR         MUL       DIV       MOD       PLUS    */
/* 10 */     6,         8,        8,        8,         9,
/*         MINUS      SHLEFT   SHRIGHT     LES        LEQ    */
/* 15 */     9,         3,        3,       10,        10,
/*          GRE        GEQ       DEQ       NEQ       DAND    */
/* 20 */    10,        10,       11,       11,        12,
/*          DOR        DXOR     QUEST     COLON       EQ     */
/* 25 */    13,        13,       14,       15,        16,
/*         PLUSEQ    MINUSEQ    MULEQ     DIVEQ      MODEQ   */
/* 30 */    16,        16,       16,       16,        16,
/*         ANDEQ      XOREQ     OREQ    SHLEFTEQ   SHRIGHTEQ */
/* 35 */    16,        16,       16,       16,        16,
/*        DANDEQ      DOREQ    DXOREQ    COMMA       EOI     */
/* 40 */    16,        16,       16,       17,       200,
/*       PREPLUS    PREMINUS     NUM        ID       POWER   */
/* 45 */     2,         2,        0,        0,         7,
/*          CID      POWEREQ     FUNC  */
/* 50 */     0,        16,        0
};

/* Option-selectable preference table */
static int *prec;

/*
 * Precedences for top and argument evaluation.  Careful:
 * prec needs to be set before we use these.
 */
#define TOPPREC (prec[COMMA]+1)
#define ARGPREC (prec[COMMA]-1)

static int type[TOKCOUNT] =
{
/*  0 */  LR, LR|OP_OP|OP_OPF, RL, RL, RL|OP_OP|OP_OPF,
/*  5 */  RL|OP_OP|OP_OPF, RL, RL, LR|OP_A2IO, LR|OP_A2IO,
/* 10 */  LR|OP_A2IO, LR|OP_A2, LR|OP_A2, LR|OP_A2, LR|OP_A2,
/* 15 */  LR|OP_A2, LR|OP_A2IO, LR|OP_A2IO, LR|OP_A2IR, LR|OP_A2IR,
/* 20 */  LR|OP_A2IR, LR|OP_A2IR, LR|OP_A2IR, LR|OP_A2IR, BOOL|OP_A2IO,
/* 25 */  BOOL|OP_A2IO, LR|OP_A2IO, RL|OP_OP, RL|OP_OP, RL|OP_E2,
/* 30 */  RL|OP_E2, RL|OP_E2, RL|OP_E2, RL|OP_E2, RL|OP_E2,
/* 35 */  RL|OP_E2IO, RL|OP_E2IO, RL|OP_E2IO, RL|OP_E2IO, RL|OP_E2IO,
/* 40 */  BOOL|OP_E2IO, BOOL|OP_E2IO, RL|OP_A2IO, RL|OP_A2, RL|OP_OP,
/* 45 */  RL, RL, LR|OP_OPF, LR|OP_OPF, RL|OP_A2,
/* 50 */  LR|OP_OPF, RL|OP_E2, LR|OP_OPF
};

/* the value stack */

#define STACKSZ 100
static int mtok;			/* last token */
static int sp = -1;			/* stack pointer */

struct mathvalue {
    /*
     * If we need to get a variable, this is the string to be passed
     * to the parameter code.  It may include a subscript.
     * When lval_len > 0, lval borrows a plain ASCII identifier slice
     * of length lval_len directly from the math expression buffer.
     */
    char *lval;
    /*
     * If this is not zero, we've retrieved a variable and this
     * stores a reference to it.
     */
    Value pval;
    Param cached_pm;
    mnumber val;
    int lval_len;
};

static struct mathvalue *stack;

/* The same field list drives recursive saves and restores. Keep the flat
 * locals below: grouping them into a C object can enlarge each recursive
 * frame. mtok belongs to the entry-point wrappers; lastmathval and output
 * radix/underscore settings deliberately remain result channels. */
#define MATH_EVAL_SAVE_FIELDS(APPLY) \
    APPLY(lastbase, xlastbase) \
    APPLY(noeval, xnoeval) \
    APPLY(unary, xunary) \
    APPLY(ptr, xptr) \
    APPLY(yyval, xyyval) \
    APPLY(yylval, xyylval) \
    APPLY(yylval_len, xyylval_len) \
    APPLY(sp, xsp) \
    APPLY(stack, xstack) \
    APPLY(prec, xprec)
#define SAVE_MATH_FIELD(active, saved) saved = active;
#define RESTORE_MATH_FIELD(active, saved) active = saved;

enum prec_type {
    /* Evaluating a top-level expression */
    MPREC_TOP,
    /* Evaluating a function argument */
    MPREC_ARG
};

/* Parse a plain decimal integer string (optional '-' + 1..18 digits, no
 * leading zero under OCTALZEROES, no spaces/radix/float chars) without
 * invoking recursive matheval(). Returns 1 on match, 0 to fall back. */
static inline int
math_parse_plain_decimal(const char *sv, zlong *out)
{
    int neg = 0;
    unsigned char c;
    zulong acc;
    int digits;

    if (*sv == '-') {
	neg = 1;
	sv++;
    }
    c = (unsigned char)*sv;
    if ((unsigned char)(c - '0') > 9U)
	return 0;
    if (c == '0') {
	if (neg || sv[1] != '\0')
	    return 0;
	*out = 0;
	return 1;
    }
    acc = (zulong)(c - '0');
    digits = 1;
    sv++;
    while ((unsigned char)(*sv - '0') <= 9U && digits < 18) {
	acc = acc * 10 + (zulong)(*sv - '0');
	sv++;
	digits++;
    }
    if (*sv != '\0')
	return 0;
    *out = neg ? -(zlong)acc : (zlong)acc;
    return 1;
}

/*
 * Bounded static-BSS bytecode cache for repeated pure-integer arithmetic
 * expressions with plain ASCII identifiers.  Any float, subscript, function,
 * radix, option edge case, unset/readonly/non-integer write, or division by
 * zero falls back cleanly to mathevall() without side effects.
 */
#define MBC_SMALL_CACHE_SIZE  128
#define MBC_SMALL_SRC         80
#define MBC_SMALL_VARS        12
#define MBC_SMALL_VARBUF      96
#define MBC_SMALL_CONSTS      12
#define MBC_SMALL_OPS         48

#define MBC_LARGE_CACHE_SIZE  8
#define MBC_LARGE_SRC         384
#define MBC_LARGE_VARS        16
#define MBC_LARGE_VARBUF      128
#define MBC_LARGE_CONSTS      32
#define MBC_LARGE_OPS         192

#define MBC_MAX_VARS          MBC_LARGE_VARS
#define MBC_STACK_SZ          32

static unsigned char mbc_bad_char[256];
static int mbc_table_ready;

static void
mbc_init_table(void)
{
    int i;
    static const char allowed[] =
	"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
	" \t\n\"+-*/%&|^~!<>=?:,()";
    memset(mbc_bad_char, 1, sizeof(mbc_bad_char));
    mbc_bad_char[0] = 0;
    for (i = 0; allowed[i]; i++)
	mbc_bad_char[(unsigned char)allowed[i]] = 0;
    mbc_bad_char[(unsigned char)Dash] = 0;
    mbc_bad_char[(unsigned char)Dnull] = 0;
    mbc_table_ready = 1;
}

#define MBC_F_HAS_WRITE       (1U << 0)
#define MBC_F_SAFE_SINGLE_END (1U << 1)
#define MBC_F_HAS_DIV         (1U << 2)
#define MBC_F_HAS_BRANCH      (1U << 3)
#define MBC_F_HAS_COMMA       (1U << 4)

#define MBC_TOK_BAD (-1)
#define MBC_OP(op, arg) ((unsigned short)(((unsigned)(op) << 8) | ((unsigned)(arg) & 0xffU)))

enum {
    MBC_PUSH_CONST = 1,
    MBC_LOAD_VAR,
    MBC_STORE_VAR,
    MBC_PREINC,
    MBC_PREDEC,
    MBC_POSTINC,
    MBC_POSTDEC,
    MBC_C_ADD,
    MBC_C_SUB,
    MBC_C_MUL,
    MBC_C_DIV,
    MBC_C_MOD,
    MBC_C_AND,
    MBC_C_XOR,
    MBC_C_OR,
    MBC_C_SHL,
    MBC_C_SHR,
    MBC_NEG,
    MBC_NOT,
    MBC_COMP,
    MBC_TOBOOL,
    MBC_POP,
    MBC_ADD,
    MBC_SUB,
    MBC_MUL,
    MBC_DIV,
    MBC_MOD,
    MBC_AND,
    MBC_XOR,
    MBC_OR,
    MBC_SHL,
    MBC_SHR,
    MBC_LES,
    MBC_LEQ,
    MBC_GRE,
    MBC_GEQ,
    MBC_DEQ,
    MBC_NEQ,
    MBC_DXOR,
    MBC_POWER,
    MBC_JZ_KEEP,
    MBC_JNZ_ONE,
    MBC_JZ_POP,
    MBC_JMP
};

struct mbc_hdr {
    unsigned hash;
    unsigned short src_len;
    unsigned short write_mask;
    unsigned char cprec;
    unsigned char valid;	/* 0=empty, 1=compiled, 2=non-compilable */
    unsigned char nvars;
    unsigned char nconsts;
    unsigned char nops;
    unsigned char flags;
};

struct math_bc_small {
    struct mbc_hdr h;
    char src[MBC_SMALL_SRC];
    char var_buf[MBC_SMALL_VARBUF];
    unsigned char var_off[MBC_SMALL_VARS];
    unsigned var_hash[MBC_SMALL_VARS];
    zlong consts[MBC_SMALL_CONSTS];
    unsigned short ops[MBC_SMALL_OPS];
};

struct math_bc_large {
    struct mbc_hdr h;
    char src[MBC_LARGE_SRC];
    char var_buf[MBC_LARGE_VARBUF];
    unsigned char var_off[MBC_LARGE_VARS];
    unsigned var_hash[MBC_LARGE_VARS];
    zlong consts[MBC_LARGE_CONSTS];
    unsigned short ops[MBC_LARGE_OPS];
};

struct mbc_view {
    struct mbc_hdr *h;
    char *src;
    char *var_buf;
    unsigned char *var_off;
    unsigned *var_hash;
    zlong *consts;
    unsigned short *ops;
    unsigned short max_vars;
    unsigned short max_varbuf;
    unsigned short max_consts;
    unsigned short max_ops;
};

static struct math_bc_small mbc_small[MBC_SMALL_CACHE_SIZE];
static struct math_bc_large mbc_large[MBC_LARGE_CACHE_SIZE];

struct mbc_compile_ctx {
    struct mbc_view *vw;
    const int *ptab;
    const char *p;
    int tok;
    int unary;
    int tok_var;
    zlong tok_val;
    unsigned char var_used;
    unsigned char write_count;
    short last_write_op;
    int failed;
};

static int
mbc_emit(struct mbc_compile_ctx *ctx, unsigned op_code, unsigned arg)
{
    struct mbc_view *vw = ctx->vw;
    struct mbc_hdr *h = vw->h;
    if (h->nops >= vw->max_ops) {
	ctx->failed = 1;
	return -1;
    }
    vw->ops[h->nops] = MBC_OP(op_code, arg);
    return (int)(h->nops++);
}

static int
mbc_add_const(struct mbc_compile_ctx *ctx, zlong val)
{
    struct mbc_view *vw = ctx->vw;
    struct mbc_hdr *h = vw->h;
    int i;
    for (i = 0; i < (int)h->nconsts; i++)
	if (vw->consts[i] == val)
	    return i;
    if (h->nconsts >= vw->max_consts) {
	ctx->failed = 1;
	return -1;
    }
    vw->consts[h->nconsts] = val;
    return (int)(h->nconsts++);
}

static int
mbc_add_var(struct mbc_compile_ctx *ctx, const char *start, size_t len)
{
    struct mbc_view *vw = ctx->vw;
    struct mbc_hdr *h = vw->h;
    int i;
    unsigned hv = 0;
    size_t k;

    if (len == 0 || len >= 32) {
	ctx->failed = 1;
	return -1;
    }
    for (k = 0; k < len; k++)
	hv += (hv << 5) + (unsigned char)start[k];
    for (i = 0; i < (int)h->nvars; i++) {
	if (vw->var_hash[i] == hv) {
	    const char *existing = vw->var_buf + vw->var_off[i];
	    if (memcmp(existing, start, len) == 0 && existing[len] == '\0')
		return i;
	}
    }
    if (h->nvars >= vw->max_vars ||
	(size_t)ctx->var_used + len + 1 > vw->max_varbuf) {
	ctx->failed = 1;
	return -1;
    }
    i = (int)(h->nvars++);
    vw->var_off[i] = ctx->var_used;
    vw->var_hash[i] = hv;
    memcpy(vw->var_buf + ctx->var_used, start, len);
    vw->var_buf[ctx->var_used + len] = '\0';
    ctx->var_used = (unsigned char)(ctx->var_used + len + 1);
    return i;
}

static int
mbc_lex_decimal(const char **pp, zlong *out)
{
    const char *p = *pp;
    unsigned char c = (unsigned char)*p;
    if ((unsigned char)(c - '0') > 9U)
	return 0;
    if (c == '0') {
	unsigned char c1 = (unsigned char)p[1];
	if (c1 == 'x' || c1 == 'X' || c1 == 'b' || c1 == 'B' ||
	    c1 == '.' || c1 == 'e' || c1 == 'E' || c1 == '#' ||
	    c1 == '_' || (unsigned char)(c1 - '0') <= 9U)
	    return 0;
	*pp = p + 1;
	*out = 0;
	return 1;
    } else {
	zulong acc = (zulong)(c - '0');
	int digits = 1;
	p++;
	while ((unsigned char)(*p - '0') <= 9U && digits < 18) {
	    acc = acc * 10 + (zulong)(*p - '0');
	    p++;
	    digits++;
	}
	if (*p == '.' || *p == 'e' || *p == 'E' || *p == '#' ||
	    *p == '_' || (unsigned char)(*p - '0') <= 9U)
	    return 0;
	*pp = p;
	*out = (zlong)acc;
	return 1;
    }
}

static void
mbc_next(struct mbc_compile_ctx *ctx)
{
    const char *p = ctx->p;
    int tok = MBC_TOK_BAD;

    if (ctx->failed) {
	ctx->tok = MBC_TOK_BAD;
	return;
    }
    for (;;) {
	char ch = *p++;
	switch (ch) {
	case ' ':
	case '\t':
	case '\n':
	case '"':
	case Dnull:
	    continue;
	case '+':
	    if (*p == '+') {
		p++;
		tok = ctx->unary ? PREPLUS : POSTPLUS;
	    } else if (*p == '=') {
		p++;
		tok = PLUSEQ;
	    } else {
		tok = ctx->unary ? UPLUS : PLUS;
	    }
	    break;
	case '-':
	case Dash:
	    if (IS_DASH(*p)) {
		p++;
		tok = ctx->unary ? PREMINUS : POSTMINUS;
	    } else if (*p == '=') {
		p++;
		tok = MINUSEQ;
	    } else if (ctx->unary) {
		if ((unsigned char)(*p - '0') <= 9U) {
		    zlong v;
		    if (!mbc_lex_decimal(&p, &v)) {
			ctx->failed = 1;
			ctx->tok = MBC_TOK_BAD;
			return;
		    }
		    ctx->tok_val = -v;
		    tok = NUM;
		} else if (*p == '.') {
		    ctx->failed = 1;
		    ctx->tok = MBC_TOK_BAD;
		    return;
		} else {
		    tok = UMINUS;
		}
	    } else {
		tok = MINUS;
	    }
	    break;
	case '(':
	    tok = M_INPAR;
	    break;
	case ')':
	    tok = M_OUTPAR;
	    break;
	case '!':
	    if (*p == '=') { p++; tok = NEQ; }
	    else tok = NOT;
	    break;
	case '~':
	    tok = COMP;
	    break;
	case '&':
	    if (*p == '&') {
		if (*++p == '=') { tok = MBC_TOK_BAD; break; }
		tok = DAND;
	    } else if (*p == '=') {
		p++;
		tok = ANDEQ;
	    } else {
		tok = AND;
	    }
	    break;
	case '|':
	    if (*p == '|') {
		if (*++p == '=') { tok = MBC_TOK_BAD; break; }
		tok = DOR;
	    } else if (*p == '=') {
		p++;
		tok = OREQ;
	    } else {
		tok = OR;
	    }
	    break;
	case '^':
	    if (*p == '^') {
		if (*++p == '=') { tok = MBC_TOK_BAD; break; }
		tok = DXOR;
	    } else if (*p == '=') {
		p++;
		tok = XOREQ;
	    } else {
		tok = XOR;
	    }
	    break;
	case '*':
	    if (*p == '*') {
		if (*++p == '=') { tok = MBC_TOK_BAD; break; }
		tok = POWER;
	    } else if (*p == '=') {
		p++;
		tok = MULEQ;
	    } else {
		tok = MUL;
	    }
	    break;
	case '/':
	    if (*p == '=') { p++; tok = DIVEQ; }
	    else tok = DIV;
	    break;
	case '%':
	    if (*p == '=') { p++; tok = MODEQ; }
	    else tok = MOD;
	    break;
	case '<':
	    if (*p == '<') {
		if (*++p == '=') { p++; tok = SHLEFTEQ; }
		else tok = SHLEFT;
	    } else if (*p == '=') {
		p++;
		tok = LEQ;
	    } else {
		tok = LES;
	    }
	    break;
	case '>':
	    if (*p == '>') {
		if (*++p == '=') { p++; tok = SHRIGHTEQ; }
		else tok = SHRIGHT;
	    } else if (*p == '=') {
		p++;
		tok = GEQ;
	    } else {
		tok = GRE;
	    }
	    break;
	case '=':
	    if (*p == '=') { p++; tok = DEQ; }
	    else tok = EQ;
	    break;
	case '?':
	    tok = ctx->unary ? MBC_TOK_BAD : QUEST;
	    break;
	case ':':
	    tok = COLON;
	    break;
	case ',':
	    tok = COMMA;
	    break;
	case '\0':
	    p--;
	    tok = EOI;
	    break;
	default:
	    p--;
	    if ((unsigned char)(*p - '0') <= 9U) {
		zlong v;
		if (!mbc_lex_decimal(&p, &v)) {
		    ctx->failed = 1;
		    ctx->tok = MBC_TOK_BAD;
		    return;
		}
		ctx->tok_val = v;
		tok = NUM;
	    } else if ((unsigned char)*p <= 0x7f &&
		       (typtab[(unsigned char)*p] & IIDENT)) {
		const char *start = p;
		size_t len;
		while ((unsigned char)*p <= 0x7f &&
		       (typtab[(unsigned char)*p] & IIDENT))
		    p++;
		if ((unsigned char)*p > 0x7f || *p == '[' || *p == '(') {
		    ctx->failed = 1;
		    ctx->tok = MBC_TOK_BAD;
		    return;
		}
		len = (size_t)(p - start);
		if (len == 3 &&
		    ((((start[0] | 32) == 'n') && ((start[1] | 32) == 'a') &&
		      ((start[2] | 32) == 'n')) ||
		     (((start[0] | 32) == 'i') && ((start[1] | 32) == 'n') &&
		      ((start[2] | 32) == 'f')))) {
		    ctx->failed = 1;
		    ctx->tok = MBC_TOK_BAD;
		    return;
		}
		ctx->tok_var = mbc_add_var(ctx, start, len);
		if (ctx->tok_var < 0) {
		    ctx->tok = MBC_TOK_BAD;
		    return;
		}
		tok = ID;
	    } else {
		tok = MBC_TOK_BAD;
	    }
	    break;
	}
	break;
    }
    ctx->p = p;
    if (tok == MBC_TOK_BAD) {
	ctx->failed = 1;
	ctx->tok = MBC_TOK_BAD;
	return;
    }
    {
	int tp = type[tok];
	if (tp & (OP_A2|OP_A2IR|OP_A2IO|OP_E2|OP_E2IO|OP_OP)) {
	    if (ctx->unary) {
		ctx->failed = 1;
		ctx->tok = MBC_TOK_BAD;
		return;
	    }
	} else {
	    if (!ctx->unary) {
		ctx->failed = 1;
		ctx->tok = MBC_TOK_BAD;
		return;
	    }
	}
	ctx->unary = !(tp & OP_OPF);
    }
    ctx->tok = tok;
}

static void
mbc_record_write(struct mbc_compile_ctx *ctx, int vid, int op_pos)
{
    ctx->write_count++;
    ctx->last_write_op = (short)op_pos;
    ctx->vw->h->write_mask |= (unsigned short)(1U << vid);
}

static int
mbc_parse_expr(struct mbc_compile_ctx *ctx, int pc, int depth)
{
    const int *ptab = ctx->ptab;
    struct mbc_view *vw = ctx->vw;
    struct mbc_hdr *bc = vw->h;

    if (ctx->failed || depth > 24) {
	ctx->failed = 1;
	return 0;
    }

    switch (ctx->tok) {
    case NUM: {
	int ci = mbc_add_const(ctx, ctx->tok_val);
	if (ci < 0 || mbc_emit(ctx, MBC_PUSH_CONST, (unsigned)ci) < 0)
	    return 0;
	mbc_next(ctx);
	break;
    }
    case ID: {
	int vid = ctx->tok_var;
	mbc_next(ctx);
	if (ctx->failed)
	    return 0;
	if ((ctx->tok == POSTPLUS || ctx->tok == POSTMINUS) &&
	    ptab[ctx->tok] <= pc) {
	    int pos = mbc_emit(ctx, ctx->tok == POSTPLUS ? MBC_POSTINC : MBC_POSTDEC,
			       (unsigned)vid);
	    if (pos < 0)
		return 0;
	    mbc_record_write(ctx, vid, pos);
	    mbc_next(ctx);
	} else if (ctx->tok >= EQ && ctx->tok <= SHRIGHTEQ &&
		   ptab[ctx->tok] <= pc) {
	    int atop = ctx->tok;
	    unsigned op_code;
	    int pos;
	    mbc_next(ctx);
	    if (!mbc_parse_expr(ctx, ptab[atop], depth + 1))
		return 0;
	    switch (atop) {
	    case EQ:        op_code = MBC_STORE_VAR; break;
	    case PLUSEQ:    op_code = MBC_C_ADD; break;
	    case MINUSEQ:   op_code = MBC_C_SUB; break;
	    case MULEQ:     op_code = MBC_C_MUL; break;
	    case DIVEQ:     op_code = MBC_C_DIV; bc->flags |= MBC_F_HAS_DIV; break;
	    case MODEQ:     op_code = MBC_C_MOD; bc->flags |= MBC_F_HAS_DIV; break;
	    case ANDEQ:     op_code = MBC_C_AND; break;
	    case XOREQ:     op_code = MBC_C_XOR; break;
	    case OREQ:      op_code = MBC_C_OR; break;
	    case SHLEFTEQ:  op_code = MBC_C_SHL; break;
	    case SHRIGHTEQ: op_code = MBC_C_SHR; break;
	    default:        ctx->failed = 1; return 0;
	    }
	    pos = mbc_emit(ctx, op_code, (unsigned)vid);
	    if (pos < 0)
		return 0;
	    mbc_record_write(ctx, vid, pos);
	} else {
	    if (mbc_emit(ctx, MBC_LOAD_VAR, (unsigned)vid) < 0)
		return 0;
	}
	break;
    }
    case M_INPAR:
	mbc_next(ctx);
	if (!mbc_parse_expr(ctx, ptab[COMMA] + 1, depth + 1))
	    return 0;
	if (ctx->tok != M_OUTPAR) {
	    ctx->failed = 1;
	    return 0;
	}
	mbc_next(ctx);
	break;
    case UPLUS:
	mbc_next(ctx);
	if (!mbc_parse_expr(ctx, ptab[UPLUS], depth + 1))
	    return 0;
	break;
    case UMINUS:
	mbc_next(ctx);
	if (!mbc_parse_expr(ctx, ptab[UMINUS], depth + 1))
	    return 0;
	if (mbc_emit(ctx, MBC_NEG, 0) < 0)
	    return 0;
	break;
    case NOT:
	mbc_next(ctx);
	if (!mbc_parse_expr(ctx, ptab[NOT], depth + 1))
	    return 0;
	if (mbc_emit(ctx, MBC_NOT, 0) < 0)
	    return 0;
	break;
    case COMP:
	mbc_next(ctx);
	if (!mbc_parse_expr(ctx, ptab[COMP], depth + 1))
	    return 0;
	if (mbc_emit(ctx, MBC_COMP, 0) < 0)
	    return 0;
	break;
    case PREPLUS:
    case PREMINUS: {
	int is_inc = (ctx->tok == PREPLUS);
	int vid, pos;
	mbc_next(ctx);
	if (ctx->failed || ctx->tok != ID) {
	    ctx->failed = 1;
	    return 0;
	}
	vid = ctx->tok_var;
	mbc_next(ctx);
	if (ctx->failed || ctx->tok == POSTPLUS || ctx->tok == POSTMINUS) {
	    ctx->failed = 1;
	    return 0;
	}
	pos = mbc_emit(ctx, is_inc ? MBC_PREINC : MBC_PREDEC, (unsigned)vid);
	if (pos < 0)
	    return 0;
	mbc_record_write(ctx, vid, pos);
	break;
    }
    default:
	ctx->failed = 1;
	return 0;
    }

    while (!ctx->failed && ctx->tok != MBC_TOK_BAD && ptab[ctx->tok] <= pc) {
	int otok = ctx->tok;
	switch (otok) {
	case QUEST: {
	    int j_else, j_end;
	    mbc_next(ctx);
	    bc->flags |= MBC_F_HAS_BRANCH;
	    j_else = mbc_emit(ctx, MBC_JZ_POP, 0);
	    if (j_else < 0)
		return 0;
	    if (!mbc_parse_expr(ctx, ptab[COLON] - 1, depth + 1))
		return 0;
	    if (ctx->tok != COLON) {
		ctx->failed = 1;
		return 0;
	    }
	    mbc_next(ctx);
	    j_end = mbc_emit(ctx, MBC_JMP, 0);
	    if (j_end < 0)
		return 0;
	    vw->ops[j_else] = MBC_OP(MBC_JZ_POP, bc->nops);
	    if (!mbc_parse_expr(ctx, ptab[QUEST], depth + 1))
		return 0;
	    vw->ops[j_end] = MBC_OP(MBC_JMP, bc->nops);
	    break;
	}
	case DAND: {
	    int j_done;
	    mbc_next(ctx);
	    bc->flags |= MBC_F_HAS_BRANCH;
	    j_done = mbc_emit(ctx, MBC_JZ_KEEP, 0);
	    if (j_done < 0)
		return 0;
	    if (!mbc_parse_expr(ctx, ptab[DAND] - 1, depth + 1))
		return 0;
	    if (mbc_emit(ctx, MBC_TOBOOL, 0) < 0)
		return 0;
	    vw->ops[j_done] = MBC_OP(MBC_JZ_KEEP, bc->nops);
	    break;
	}
	case DOR: {
	    int j_done;
	    mbc_next(ctx);
	    bc->flags |= MBC_F_HAS_BRANCH;
	    j_done = mbc_emit(ctx, MBC_JNZ_ONE, 0);
	    if (j_done < 0)
		return 0;
	    if (!mbc_parse_expr(ctx, ptab[DOR] - 1, depth + 1))
		return 0;
	    if (mbc_emit(ctx, MBC_TOBOOL, 0) < 0)
		return 0;
	    vw->ops[j_done] = MBC_OP(MBC_JNZ_ONE, bc->nops);
	    break;
	}
	case COMMA:
	    mbc_next(ctx);
	    bc->flags |= MBC_F_HAS_COMMA;
	    if (mbc_emit(ctx, MBC_POP, 0) < 0)
		return 0;
	    if (!mbc_parse_expr(ctx, ptab[COMMA], depth + 1))
		return 0;
	    break;
	case MUL:
	case DIV:
	case MOD:
	case PLUS:
	case MINUS:
	case SHLEFT:
	case SHRIGHT:
	case LES:
	case LEQ:
	case GRE:
	case GEQ:
	case DEQ:
	case NEQ:
	case AND:
	case XOR:
	case OR:
	case DXOR:
	case POWER: {
	    unsigned op_code;
	    int rhs_pc = ptab[otok] - (MTYPE(type[otok]) != RL);
	    mbc_next(ctx);
	    if (!mbc_parse_expr(ctx, rhs_pc, depth + 1))
		return 0;
	    switch (otok) {
	    case MUL:     op_code = MBC_MUL; break;
	    case DIV:     op_code = MBC_DIV; bc->flags |= MBC_F_HAS_DIV; break;
	    case MOD:     op_code = MBC_MOD; bc->flags |= MBC_F_HAS_DIV; break;
	    case PLUS:    op_code = MBC_ADD; break;
	    case MINUS:   op_code = MBC_SUB; break;
	    case SHLEFT:  op_code = MBC_SHL; break;
	    case SHRIGHT: op_code = MBC_SHR; break;
	    case LES:     op_code = MBC_LES; break;
	    case LEQ:     op_code = MBC_LEQ; break;
	    case GRE:     op_code = MBC_GRE; break;
	    case GEQ:     op_code = MBC_GEQ; break;
	    case DEQ:     op_code = MBC_DEQ; break;
	    case NEQ:     op_code = MBC_NEQ; break;
	    case AND:     op_code = MBC_AND; break;
	    case XOR:     op_code = MBC_XOR; break;
	    case OR:      op_code = MBC_OR; break;
	    case DXOR:    op_code = MBC_DXOR; break;
	    case POWER:   op_code = MBC_POWER; bc->flags |= MBC_F_HAS_DIV; break;
	    default:      ctx->failed = 1; return 0;
	    }
	    if (mbc_emit(ctx, op_code, 0) < 0)
		return 0;
	    break;
	}
	default:
	    ctx->failed = 1;
	    return 0;
	}
    }
    return !ctx->failed;
}

static int
mbc_compile(struct mbc_view *vw, const char *s, unsigned len,
	    unsigned hash, int cprec)
{
    struct mbc_compile_ctx ctx;
    struct mbc_hdr *bc = vw->h;

    bc->hash = hash;
    bc->src_len = (unsigned short)len;
    bc->write_mask = 0;
    bc->cprec = (unsigned char)cprec;
    bc->valid = 2;
    bc->nvars = 0;
    bc->nconsts = 0;
    bc->nops = 0;
    bc->flags = 0;
    memcpy(vw->src, s, len);

    ctx.vw = vw;
    ctx.ptab = cprec ? c_prec : z_prec;
    ctx.p = s;
    ctx.tok = MBC_TOK_BAD;
    ctx.unary = 1;
    ctx.tok_var = -1;
    ctx.tok_val = 0;
    ctx.var_used = 0;
    ctx.write_count = 0;
    ctx.last_write_op = -1;
    ctx.failed = 0;

    mbc_next(&ctx);
    if (ctx.failed || ctx.tok == EOI)
	return 0;
    if (!mbc_parse_expr(&ctx, ctx.ptab[COMMA] + 1, 0) ||
	ctx.failed || ctx.tok != EOI || bc->nops == 0)
	return 0;

    if (ctx.write_count > 0) {
	bc->flags |= MBC_F_HAS_WRITE;
	if (ctx.write_count == 1 && ctx.last_write_op == (short)(bc->nops - 1))
	    bc->flags |= MBC_F_SAFE_SINGLE_END;
	else if (bc->flags & (MBC_F_HAS_DIV | MBC_F_HAS_BRANCH))
	    return 0;
    }

    bc->valid = 1;
    return 1;
}

static inline Param
mbc_lookup_param(const char *name, unsigned hashval)
{
    unsigned hsize = (unsigned)paramtab->hsize;
    unsigned bucket = ((hsize & (hsize - 1)) == 0) ? (hashval & (hsize - 1))
						   : (hashval % hsize);
    unsigned char c0 = (unsigned char)name[0];
    HashNode hp;

    for (hp = paramtab->nodes[bucket]; hp; hp = hp->next) {
	if ((unsigned char)hp->nam[0] == c0 &&
	    strcmp(hp->nam + 1, name + 1) == 0)
	    return (Param)hp;
    }
    return NULL;
}

static inline int
mbc_is_writable_int(Param pm)
{
    return pm != NULL && !pm->env &&
	!(pm->node.flags & (PM_UNSET|PM_AUTOLOAD|PM_READONLY|
			    PM_RESTRICTED|PM_EXPORTED|PM_DEFAULTED)) &&
	PM_TYPE(pm->node.flags) == PM_INTEGER &&
	pm->gsu.i == &stdinteger_gsu &&
	(!isset(WARNNESTEDVAR) || pm->level >= locallevel);
}

static inline int
mbc_read_var(const struct mbc_view *vw, Param *pms, unsigned vi, zlong *out)
{
    Param pm = pms[vi];
    if (pm) {
	*out = pm->u.val;
	return 1;
    }
    pm = mbc_lookup_param(vw->var_buf + vw->var_off[vi], vw->var_hash[vi]);
    if (!pm) {
	if (isset(UNSET)) {
	    *out = 0;
	    return 1;
	}
	return 0;
    }
    if (pm->node.flags & PM_AUTOLOAD)
	return 0;
    if (pm->node.flags & PM_UNSET) {
	if (isset(UNSET)) {
	    *out = 0;
	    return 1;
	}
	return 0;
    }
    {
	int pmt = PM_TYPE(pm->node.flags);
	if (pmt == PM_INTEGER && pm->gsu.i == &stdinteger_gsu) {
	    pms[vi] = pm;
	    *out = pm->u.val;
	    return 1;
	}
	if (pmt == PM_SCALAR && pm->gsu.s == &stdscalar_gsu) {
	    const char *sv = pm->u.str;
	    if (!sv || !*sv) {
		*out = 0;
		return 1;
	    }
	    return math_parse_plain_decimal(sv, out);
	}
    }
    return 0;
}

static inline Param
mbc_get_writable_int(const struct mbc_view *vw, Param *pms, unsigned vi)
{
    Param pm = pms[vi];
    if (!pm)
	pm = mbc_lookup_param(vw->var_buf + vw->var_off[vi], vw->var_hash[vi]);
    if (!mbc_is_writable_int(pm))
	return NULL;
    pms[vi] = pm;
    return pm;
}

static int
mbc_eval(const char *s, int no_comma, mnumber *out, unsigned *out_len)
{
    unsigned h, len;
    int cprec;
    struct mbc_view vw;
    struct mbc_hdr *bc;
    Param pms[MBC_MAX_VARS];
    zlong stk[MBC_STACK_SZ];
    int top = -1;
    unsigned pc = 0, nops;
    int demote = 0;

    if (errflag || noeval || mlevel >= MAX_MLEVEL ||
	!isset(EXECOPT) || isset(FORCEFLOAT) ||
	isset(OCTALZEROES) || isset(ALLEXPORT) ||
	!psh_paramtab_is_standard())
	return 0;

    if (!mbc_table_ready)
	mbc_init_table();

    cprec = isset(CPRECEDENCES) ? 1 : 0;
    h = 2166136261U ^ (unsigned)cprec;
    {
	const unsigned char *p = (const unsigned char *)s;
	const unsigned char *end = p + MBC_LARGE_SRC;
	unsigned char ch;
	while (p < end && (ch = *p)) {
	    if (mbc_bad_char[ch])
		return 0;
	    h = (h ^ ch) * 16777619U;
	    p++;
	}
	if (p == end)
	    return 0;
	len = (unsigned)(p - (const unsigned char *)s);
    }
    if (!len)
	return 0;

    if (len <= MBC_SMALL_SRC) {
	struct math_bc_small *sm =
	    &mbc_small[(h ^ (h >> 7)) & (MBC_SMALL_CACHE_SIZE - 1)];
	vw.h = &sm->h;
	vw.src = sm->src;
	vw.var_buf = sm->var_buf;
	vw.var_off = sm->var_off;
	vw.var_hash = sm->var_hash;
	vw.consts = sm->consts;
	vw.ops = sm->ops;
	vw.max_vars = MBC_SMALL_VARS;
	vw.max_varbuf = MBC_SMALL_VARBUF;
	vw.max_consts = MBC_SMALL_CONSTS;
	vw.max_ops = MBC_SMALL_OPS;
    } else {
	struct math_bc_large *lg =
	    &mbc_large[(h ^ (h >> 3)) & (MBC_LARGE_CACHE_SIZE - 1)];
	vw.h = &lg->h;
	vw.src = lg->src;
	vw.var_buf = lg->var_buf;
	vw.var_off = lg->var_off;
	vw.var_hash = lg->var_hash;
	vw.consts = lg->consts;
	vw.ops = lg->ops;
	vw.max_vars = MBC_LARGE_VARS;
	vw.max_varbuf = MBC_LARGE_VARBUF;
	vw.max_consts = MBC_LARGE_CONSTS;
	vw.max_ops = MBC_LARGE_OPS;
    }
    bc = vw.h;

    if (!(bc->valid && bc->src_len == (unsigned short)len && bc->hash == h &&
	  bc->cprec == (unsigned char)cprec && memcmp(vw.src, s, len) == 0)) {
	if (!mbc_compile(&vw, s, len, h, cprec))
	    return 0;
    } else if (bc->valid != 1) {
	return 0;
    }

    if (no_comma && (bc->flags & MBC_F_HAS_COMMA))
	return 0;

    {
	unsigned vi;
	for (vi = 0; vi < bc->nvars; vi++)
	    pms[vi] = NULL;
    }

    queue_signals();

    /* For multi-write expressions, pre-verify every variable before op 0 so
     * no partial mutation can occur on bail-out. */
    if ((bc->flags & MBC_F_HAS_WRITE) && !(bc->flags & MBC_F_SAFE_SINGLE_END)) {
	unsigned vi;
	for (vi = 0; vi < bc->nvars; vi++) {
	    if (bc->write_mask & (1U << vi)) {
		if (!mbc_get_writable_int(&vw, pms, vi)) {
		    demote = 1;
		    goto fallback;
		}
	    } else {
		zlong dummy;
		if (!mbc_read_var(&vw, pms, vi, &dummy)) {
		    demote = 1;
		    goto fallback;
		}
	    }
	}
    }

    nops = bc->nops;
    while (pc < nops) {
	unsigned short ins = vw.ops[pc++];
	unsigned op_code = ins >> 8;
	unsigned arg = ins & 0xffU;

	switch (op_code) {
	case MBC_PUSH_CONST:
	    stk[++top] = vw.consts[arg];
	    break;
	case MBC_LOAD_VAR: {
	    zlong v;
	    if (!mbc_read_var(&vw, pms, arg, &v)) {
		demote = 1;
		goto fallback;
	    }
	    stk[++top] = v;
	    break;
	}
	case MBC_STORE_VAR: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    if (!pm) {
		demote = 1;
		goto fallback;
	    }
	    pm->u.val = stk[top];
	    break;
	}
	case MBC_PREINC: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong v;
	    if (!pm) {
		demote = 1;
		goto fallback;
	    }
	    v = (zlong)((zulong)pm->u.val + 1U);
	    pm->u.val = v;
	    stk[++top] = v;
	    break;
	}
	case MBC_PREDEC: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong v;
	    if (!pm) {
		demote = 1;
		goto fallback;
	    }
	    v = (zlong)((zulong)pm->u.val - 1U);
	    pm->u.val = v;
	    stk[++top] = v;
	    break;
	}
	case MBC_POSTINC: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong v;
	    if (!pm) {
		demote = 1;
		goto fallback;
	    }
	    v = pm->u.val;
	    pm->u.val = (zlong)((zulong)v + 1U);
	    stk[++top] = v;
	    break;
	}
	case MBC_POSTDEC: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong v;
	    if (!pm) {
		demote = 1;
		goto fallback;
	    }
	    v = pm->u.val;
	    pm->u.val = (zlong)((zulong)v - 1U);
	    stk[++top] = v;
	    break;
	}
	case MBC_C_ADD: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = (zlong)((zulong)pm->u.val + (zulong)stk[top]);
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_SUB: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = (zlong)((zulong)pm->u.val - (zulong)stk[top]);
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_MUL: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = (zlong)((zulong)pm->u.val * (zulong)stk[top]);
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_DIV: {
	    Param pm;
	    zlong b = stk[top], res;
	    if (b == 0)
		goto fallback;
	    pm = mbc_get_writable_int(&vw, pms, arg);
	    if (!pm) { demote = 1; goto fallback; }
	    res = (b == -1) ? (zlong)(-(zulong)pm->u.val) : (pm->u.val / b);
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_MOD: {
	    Param pm;
	    zlong b = stk[top], res;
	    if (b == 0)
		goto fallback;
	    pm = mbc_get_writable_int(&vw, pms, arg);
	    if (!pm) { demote = 1; goto fallback; }
	    res = (b == -1) ? 0 : (pm->u.val % b);
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_AND: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = pm->u.val & stk[top];
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_XOR: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = pm->u.val ^ stk[top];
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_OR: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = pm->u.val | stk[top];
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_SHL: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = pm->u.val << stk[top];
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_C_SHR: {
	    Param pm = mbc_get_writable_int(&vw, pms, arg);
	    zlong res;
	    if (!pm) { demote = 1; goto fallback; }
	    res = pm->u.val >> stk[top];
	    pm->u.val = res;
	    stk[top] = res;
	    break;
	}
	case MBC_NEG:
	    stk[top] = (zlong)(-(zulong)stk[top]);
	    break;
	case MBC_NOT:
	    stk[top] = !stk[top];
	    break;
	case MBC_COMP:
	    stk[top] = ~stk[top];
	    break;
	case MBC_TOBOOL:
	    stk[top] = (stk[top] != 0);
	    break;
	case MBC_POP:
	    top--;
	    break;
	case MBC_ADD:
	    top--;
	    stk[top] = (zlong)((zulong)stk[top] + (zulong)stk[top + 1]);
	    break;
	case MBC_SUB:
	    top--;
	    stk[top] = (zlong)((zulong)stk[top] - (zulong)stk[top + 1]);
	    break;
	case MBC_MUL:
	    top--;
	    stk[top] = (zlong)((zulong)stk[top] * (zulong)stk[top + 1]);
	    break;
	case MBC_DIV: {
	    zlong b = stk[top--];
	    if (b == 0)
		goto fallback;
	    stk[top] = (b == -1) ? (zlong)(-(zulong)stk[top]) : (stk[top] / b);
	    break;
	}
	case MBC_MOD: {
	    zlong b = stk[top--];
	    if (b == 0)
		goto fallback;
	    stk[top] = (b == -1) ? 0 : (stk[top] % b);
	    break;
	}
	case MBC_AND:
	    top--;
	    stk[top] &= stk[top + 1];
	    break;
	case MBC_XOR:
	    top--;
	    stk[top] ^= stk[top + 1];
	    break;
	case MBC_OR:
	    top--;
	    stk[top] |= stk[top + 1];
	    break;
	case MBC_SHL:
	    top--;
	    stk[top] = stk[top] << stk[top + 1];
	    break;
	case MBC_SHR:
	    top--;
	    stk[top] = stk[top] >> stk[top + 1];
	    break;
	case MBC_LES:
	    top--;
	    stk[top] = (zlong)(stk[top] < stk[top + 1]);
	    break;
	case MBC_LEQ:
	    top--;
	    stk[top] = (zlong)(stk[top] <= stk[top + 1]);
	    break;
	case MBC_GRE:
	    top--;
	    stk[top] = (zlong)(stk[top] > stk[top + 1]);
	    break;
	case MBC_GEQ:
	    top--;
	    stk[top] = (zlong)(stk[top] >= stk[top + 1]);
	    break;
	case MBC_DEQ:
	    top--;
	    stk[top] = (zlong)(stk[top] == stk[top + 1]);
	    break;
	case MBC_NEQ:
	    top--;
	    stk[top] = (zlong)(stk[top] != stk[top + 1]);
	    break;
	case MBC_DXOR:
	    top--;
	    stk[top] = (zlong)((stk[top] && !stk[top + 1]) ||
			       (!stk[top] && stk[top + 1]));
	    break;
	case MBC_POWER: {
	    zlong exp = stk[top--];
	    zulong res = 1, b = (zulong)stk[top];
	    if (exp < 0 || exp > 62)
		goto fallback;
	    while (exp > 0) {
		if (exp & 1)
		    res *= b;
		exp >>= 1;
		if (exp)
		    b *= b;
	    }
	    stk[top] = (zlong)res;
	    break;
	}
	case MBC_JZ_KEEP:
	    if (!stk[top])
		pc = arg;
	    else
		top--;
	    break;
	case MBC_JNZ_ONE:
	    if (stk[top]) {
		stk[top] = 1;
		pc = arg;
	    } else {
		top--;
	    }
	    break;
	case MBC_JZ_POP:
	    if (!stk[top--])
		pc = arg;
	    break;
	case MBC_JMP:
	    pc = arg;
	    break;
	default:
	    goto fallback;
	}
    }

    unqueue_signals();
    if (!mlevel)
	lastbase = -1;
    out->type = MN_INTEGER;
    out->u.l = stk[0];
    if (out_len)
	*out_len = len;
    return 1;

fallback:
    if (demote)
	bc->valid = 2;
    unqueue_signals();
    return 0;
}

/*
 * Get a number from a variable.
 * Try to be clever about reusing subscripts by caching the Value structure.
 */
static mnumber
getmathparam(struct mathvalue *mptr, int keep)
{
    mnumber result;
    struct value scratch;
    Value v = mptr->pval;

    if (!v) {
	char *s;
	if (mptr->lval_len > 0) {
	    char name[64];
	    Param pm;
	    memcpy(name, mptr->lval, (size_t)mptr->lval_len);
	    name[mptr->lval_len] = '\0';
	    pm = (Param) paramtab->getnode(paramtab, name);
	    if (pm && !(pm->node.flags & PM_UNSET)) {
		int pmt = PM_TYPE(pm->node.flags);
		if (pmt == PM_INTEGER) {
		    zlong lv = (pm->gsu.i == &stdinteger_gsu) ?
			pm->u.val : pm->gsu.i->getfn(pm);
		    if (keep)
			mptr->cached_pm = pm;
		    if (isset(FORCEFLOAT)) {
			result.type = MN_FLOAT;
			result.u.d = (double)lv;
		    } else {
			result.type = MN_INTEGER;
			result.u.l = lv;
		    }
		    return result;
		}
		if (pmt == PM_FFLOAT || pmt == PM_EFLOAT) {
		    result.type = MN_FLOAT;
		    result.u.d = (pm->gsu.f == &stdfloat_gsu) ?
			pm->u.dval : pm->gsu.f->getfn(pm);
		    if (keep)
			mptr->cached_pm = pm;
		    return result;
		}
		if (pmt == PM_SCALAR && pm->gsu.s == &stdscalar_gsu &&
		    mlevel < MAX_MLEVEL) {
		    const char *sv = pm->u.str;
		    zlong lv;
		    if (!sv || !*sv) {
			if (keep)
			    mptr->cached_pm = pm;
			if (isset(FORCEFLOAT)) {
			    result.type = MN_FLOAT;
			    result.u.d = 0.0;
			    return result;
			}
			return zero_mnumber;
		    }
		    if (math_parse_plain_decimal(sv, &lv)) {
			if (keep)
			    mptr->cached_pm = pm;
			if (isset(FORCEFLOAT)) {
			    result.type = MN_FLOAT;
			    result.u.d = (double)lv;
			} else {
			    result.type = MN_INTEGER;
			    result.u.l = lv;
			}
			return result;
		    }
		}
	    }
	    mptr->lval = dupstrpfx(mptr->lval, mptr->lval_len);
	    mptr->lval_len = 0;
	}
	s = mptr->lval;
	/* Only a later use of this operand needs a saved subscript. */
	v = keep ? (Value)zhalloc(sizeof(*v)) : &scratch;
	if (!getvalue(v, &s, 1))
	{
	    if (unset(UNSET))
		zerr("%s: parameter not set", mptr->lval);
	    if (isset(FORCEFLOAT)) {
		result.type = MN_FLOAT;
		result.u.d = 0.0;
		return result;
	    }
	    return zero_mnumber;
	}
	if (keep)
	    mptr->pval = v;
	if (errflag)
	    return zero_mnumber;
    }
    result = getnumvalue(v);
    if (isset(FORCEFLOAT) && result.type == MN_INTEGER) {
	result.type = MN_FLOAT;
	result.u.d = (double)result.u.l;
    }
    return result;
}

static mnumber
mathevall(char *s, enum prec_type prec_tp, char **ep)
{
    int xlastbase, xnoeval, xunary, *xprec;
    char *xptr;
    mnumber xyyval;
    char *xyylval;
    int xyylval_len;
    int xsp;
    struct mathvalue *xstack = 0, nstack[STACKSZ];
    mnumber ret;

    if (mlevel >= MAX_MLEVEL) {
	xyyval.type = MN_INTEGER;
	xyyval.u.l = 0;
	*ep = s;

	zerr("math recursion limit exceeded: %s", *ep);

	return xyyval;
    }
    if (mlevel++) {
	MATH_EVAL_SAVE_FIELDS(SAVE_MATH_FIELD)
    } else {
	xlastbase = xnoeval = xunary = xsp = 0;
	xyyval.type = MN_INTEGER;
	xyyval.u.l = 0;
	xyylval = NULL;
	xyylval_len = 0;
	xptr = NULL;
	xprec = NULL;
    }
    prec = isset(CPRECEDENCES) ? c_prec : z_prec;
    stack = nstack;
    lastbase = -1;
    ptr = s;
    sp = -1;
    unary = 1;
    stack[0].val.type = MN_INTEGER;
    stack[0].val.u.l = 0;
    queue_signals();
    mathparse(prec_tp == MPREC_TOP ? TOPPREC : ARGPREC);
    unqueue_signals();
    /*
     * Internally, we parse the contents of parentheses at top
     * precedence... so we can return a parenthesis here if
     * there are too many at the end.
     */
    if (mtok == M_OUTPAR && !errflag)
	zerr("bad math expression: unexpected ')'");
    *ep = ptr;
    DPUTS(!errflag && sp > 0,
	  "BUG: math: wallabies roaming too freely in outback");

    if (errflag) {
	/*
	 * This used to set the return value to errflag.
	 * I don't understand how that could be useful; the
	 * caller doesn't know that's what's happened and
	 * may not get a value at all.
	 * Worse, we reset errflag in execarith() and setting
	 * this explicitly non-zero means a (( ... )) returns
	 * status 0 if there's an error.  That surely can't
	 * be right.  execarith() now detects an error and returns
	 * status 2.
	 */
	ret.type = MN_INTEGER;
	ret.u.l = 0;
    } else {
	if (stack[0].val.type == MN_UNSET)
	    ret = getmathparam(stack, 0);
	else
	    ret = stack[0].val;
    }

    if (--mlevel) {
	MATH_EVAL_SAVE_FIELDS(RESTORE_MATH_FIELD)
    }
    return lastmathval = ret;
}

#undef MATH_EVAL_SAVE_FIELDS
#undef SAVE_MATH_FIELD
#undef RESTORE_MATH_FIELD

/* Keep locale setup off the integer lexer's hot path. */
#if defined(__GNUC__)
__attribute__((__noinline__))
#endif
static double
math_strtod(char *text, char **end)
{
    double value;
#ifdef USE_LOCALE
    char *prev_locale;
#endif
#ifdef PSH_MATH_LOCALE_OBJECT
    {
	int saved_errno = errno;
	int ordinary_token = ((*text >= '0' && *text <= '9') || *text == '.') &&
	    uselocale((locale_t)0) == LC_GLOBAL_LOCALE;
	if (ordinary_token && !math_c_locale)
	    math_c_locale = newlocale(LC_ALL_MASK, "C", (locale_t)0);
	errno = saved_errno;
	if (ordinary_token && math_c_locale)
	    return strtod_l(text, end, math_c_locale);
    }
#endif
#ifdef USE_LOCALE
    prev_locale = dupstring(setlocale(LC_NUMERIC, NULL));
    setlocale(LC_NUMERIC, "POSIX");
#endif
    value = strtod(text, end);
#ifdef USE_LOCALE
    if (prev_locale) setlocale(LC_NUMERIC, prev_locale);
#endif
    return value;
}

static int
lexconstant(void)
{
    char *nptr;

    nptr = ptr;
    if ((unsigned char)(*nptr - '0') <= 9U) {
	if (*nptr == '0') {
	    unsigned char c1 = (unsigned char)nptr[1];
	    if (c1 != 'x' && c1 != 'X' && c1 != 'b' && c1 != 'B' &&
		c1 != '.' && c1 != 'e' && c1 != 'E' && c1 != '#' &&
		c1 != '_' && (unsigned char)(c1 - '0') > 9U) {
		ptr = nptr + 1;
		if (isset(FORCEFLOAT)) {
		    yyval.type = MN_FLOAT;
		    yyval.u.d = 0.0;
		} else {
		    yyval.u.l = 0;
		}
		return NUM;
	    }
	} else {
	    zulong acc = (zulong)(*nptr - '0');
	    char *p = nptr + 1;
	    int digits = 1;
	    while ((unsigned char)(*p - '0') <= 9U && digits < 18) {
		acc = acc * 10 + (zulong)(*p - '0');
		p++;
		digits++;
	    }
	    if (*p != '.' && *p != 'e' && *p != 'E' && *p != '#' &&
		*p != '_' && (unsigned char)(*p - '0') > 9U) {
		ptr = p;
		if (isset(FORCEFLOAT)) {
		    yyval.type = MN_FLOAT;
		    yyval.u.d = (double)(zlong)acc;
		} else {
		    yyval.u.l = (zlong)acc;
		}
		return NUM;
	    }
	}
    }
    if (IS_DASH(*nptr))
	nptr++;

    if (*nptr == '0') {
	int lowchar;
	nptr++;
	lowchar = tolower(*nptr);
	if (lowchar == 'x' || lowchar == 'b') {
	    /* Let zstrtol parse number with base */
	    yyval.u.l = zstrtol_underscore(ptr, &ptr, 0, 1);
	    /* Should we set lastbase here? */
	    lastbase = (lowchar == 'b') ? 2 : 16;
	    if (isset(FORCEFLOAT))
	    {
		yyval.type = MN_FLOAT;
		yyval.u.d = (double)yyval.u.l;
	    }
	    return NUM;
	}
	else if (isset(OCTALZEROES))
	{
	    char *ptr2;

	    /*
	     * Make sure this is a real octal constant;
	     * it can't be a base indication (always decimal)
	     * or a floating point number.
	     */
	    for (ptr2 = nptr; idigit(*ptr2) || *ptr2 == '_'; ptr2++)
		;

	    if (ptr2 > nptr && *ptr2 != '.' && *ptr2 != 'e' &&
		*ptr2 != 'E' && *ptr2 != '#')
	    {
		yyval.u.l = zstrtol_underscore(ptr, &ptr, 0, 1);
		lastbase = 8;
		if (isset(FORCEFLOAT))
		{
		    yyval.type = MN_FLOAT;
		    yyval.u.d = (double)yyval.u.l;
		}
		return NUM;
	    }
	    nptr = ptr2;
	}
    }
    while (idigit(*nptr) || *nptr == '_')
	nptr++;

    if (*nptr == '.' || *nptr == 'e' || *nptr == 'E') {
	char *ptr2;
	/* it's a float */
	yyval.type = MN_FLOAT;
	if (*nptr == '.') {
	    nptr++;
	    while (idigit(*nptr) || *nptr == '_')
		nptr++;
	}
	if (*nptr == 'e' || *nptr == 'E') {
	    nptr++;
	    if (*nptr == '+' || IS_DASH(*nptr))
		nptr++;
	    while (idigit(*nptr) || *nptr == '_')
		nptr++;
	}
	for (ptr2 = ptr; ptr2 < nptr; ptr2++) {
	    if (*ptr2 == '_') {
		int len = nptr - ptr;
		char *readp, *writep;
		ptr = dupstring(ptr);
		/* Compact the numeric span, then move the remaining expression once. */
		for (readp = writep = ptr; len; len--, readp++) {
		    if (*readp != '_')
			*writep++ = *readp;
		}
		memmove(writep, readp, strlen(readp) + 1);
		break;
	    }
	}
	yyval.u.d = math_strtod(ptr, &nptr);
	if (ptr == nptr || *nptr == '.') {
	    zerr("bad floating point constant");
	    return EOI;
	}
	ptr = nptr;
    } else {
	/* it's an integer */
	yyval.u.l = zstrtol_underscore(ptr, &ptr, 10, 1);

	if (*ptr == '#') {
	    ptr++;
	    lastbase = yyval.u.l;
	    yyval.u.l = zstrtol_underscore(ptr, &ptr, lastbase, 1);
	}
	if (isset(FORCEFLOAT))
	{
	    yyval.type = MN_FLOAT;
	    yyval.u.d = (double)yyval.u.l;
	}
    }
    return NUM;
}

/**/
int outputradix;

/**/
int outputunderscore;

#ifndef HAVE_ISINF
/**/
int
isinf(double x)
{
    if ((-1.0 < x) && (x < 1.0))       /* x is small, and thus finite */
       return (0);
    else if ((x + x) == x)             /* only true if x == Infinity */
       return (1);
    else                               /* must be finite (normal or subnormal), or NaN */
       return (0);
}
#endif

#if !defined(HAVE_ISNAN)
static double
store(double *x)
{
    return (*x);
}

/**/
int
isnan(double x)
{
    /* (x != x) should be sufficient, but some compilers incorrectly optimize it away */
    return (store(&x) != store(&x));
}
#endif

/**/
static int
zzlex(void)
{
    int cct = 0;
    char *ie;
    yyval.type = MN_INTEGER;

    for (;; cct = 0)
	switch (*ptr++) {
	case '+':
	    if (*ptr == '+') {
		ptr++;
		return (unary) ? PREPLUS : POSTPLUS;
	    }
	    if (*ptr == '=') {
		ptr++;
		return PLUSEQ;
	    }
	    return (unary) ? UPLUS : PLUS;
	case '-':
	case Dash:
	    if (IS_DASH(*ptr)) {
		ptr++;
		return (unary) ? PREMINUS : POSTMINUS;
	    }
	    if (*ptr == '=') {
		ptr++;
		return MINUSEQ;
	    }
	    if (unary) {
		if (idigit(*ptr) || *ptr == '.') {
		    int ctype = lexconstant();
		    if (ctype == NUM)
		    {
			if (yyval.type == MN_FLOAT)
			{
			    yyval.u.d = -yyval.u.d;
			}
			else
			{
			    yyval.u.l = -yyval.u.l;
			}
		    }
		    return ctype;
		} else
		    return UMINUS;
	    } else
		return MINUS;
	case '(':
	    return M_INPAR;
	case ')':
	    return M_OUTPAR;
	case '!':
	    if (*ptr == '=') {
		ptr++;
		return NEQ;
	    }
	    return NOT;
	case '~':
	    return COMP;
	case '&':
	    if (*ptr == '&') {
		if (*++ptr == '=') {
		    ptr++;
		    return DANDEQ;
		}
		return DAND;
	    } else if (*ptr == '=') {
		ptr++;
		return ANDEQ;
	    }
	    return AND;
	case '|':
	    if (*ptr == '|') {
		if (*++ptr == '=') {
		    ptr++;
		    return DOREQ;
		}
		return DOR;
	    } else if (*ptr == '=') {
		ptr++;
		return OREQ;
	    }
	    return OR;
	case '^':
	    if (*ptr == '^') {
		if (*++ptr == '=') {
		    ptr++;
		    return DXOREQ;
		}
		return DXOR;
	    } else if (*ptr == '=') {
		ptr++;
		return XOREQ;
	    }
	    return XOR;
	case '*':
	    if (*ptr == '*') {
		if (*++ptr == '=') {
		    ptr++;
		    return POWEREQ;
		}
		return POWER;
	    }
	    if (*ptr == '=') {
		ptr++;
		return MULEQ;
	    }
	    return MUL;
	case '/':
	    if (*ptr == '=') {
		ptr++;
		return DIVEQ;
	    }
	    return DIV;
	case '%':
	    if (*ptr == '=') {
		ptr++;
		return MODEQ;
	    }
	    return MOD;
	case '<':
	    if (*ptr == '<') {
		if (*++ptr == '=') {
		    ptr++;
		    return SHLEFTEQ;
		}
		return SHLEFT;
	    } else if (*ptr == '=') {
		ptr++;
		return LEQ;
	    }
	    return LES;
	case '>':
	    if (*ptr == '>') {
		if (*++ptr == '=') {
		    ptr++;
		    return SHRIGHTEQ;
		}
		return SHRIGHT;
	    } else if (*ptr == '=') {
		ptr++;
		return GEQ;
	    }
	    return GRE;
	case '=':
	    if (*ptr == '=') {
		ptr++;
		return DEQ;
	    }
	    return EQ;
	case '$':
	    yyval.u.l = mypid;
	    return NUM;
	case '?':
	    if (unary) {
		yyval.u.l = lastval;
		return NUM;
	    }
	    return QUEST;
	case ':':
	    return COLON;
	case ',':
	    return COMMA;
	case '\0':
	    ptr--;
	    return EOI;
	case '[':
	    {
		int n, checkradix = 0;

		if (idigit(*ptr)) {
		    n = zstrtol(ptr, &ptr, 10);
		    if (*ptr != ']' || !idigit(*++ptr)) {
			zerr("bad base syntax");
			return EOI;
		    }
		    yyval.u.l = zstrtol(ptr, &ptr, lastbase = n);
		    return NUM;
		}
		if (*ptr == '#') {
		    n = 1;
		    if (*++ptr == '#') {
			n = -1;
			ptr++;
		    }
		    if (!idigit(*ptr) && *ptr != '_')
			goto bofs;
		    if (idigit(*ptr)) {
			outputradix = n * zstrtol(ptr, &ptr, 10);
			checkradix = 1;
		    }
		    if (*ptr == '_') {
			ptr++;
			if (idigit(*ptr))
			    outputunderscore = zstrtol(ptr, &ptr, 10);
			else
			    outputunderscore = 3;
		    }
		} else {
		    bofs:
		    zerr("bad output format specification");
		    return EOI;
		}
		if(*ptr != ']')
			goto bofs;
		if (checkradix) {
		    n = (outputradix < 0) ? -outputradix : outputradix;
		    if (n < 2 || n > 36) {
			zerr("invalid base (must be 2 to 36 inclusive): %d",
			     outputradix);
			return EOI;
		    }
		}
		ptr++;
		break;
	    }
	case ' ': /* Fall through! */
	case '\t':
	case '\n':
	case '"': /* POSIX says ignore these */
	case Dnull:
	    break;
	default:
	    if (idigit(*--ptr) || *ptr == '.')
		return lexconstant();
	    if (*ptr == '#') {
		if (*++ptr == '\\' || *ptr == '#') {
		    int v;
		    char *optr = ptr;

		    ptr++;
		    if (!*ptr) {
			zerr("bad math expression: character missing after ##");
			return EOI;
		    }
		    if(!(ptr = getkeystring(ptr, NULL, GETKEYS_MATH, &v))) {
			zerr("bad math expression: bad character after ##");
			ptr = optr;
			return EOI;
		    }
		    yyval.u.l = v;
		    return NUM;
		}
		cct = 1;
	    }
	    {
		char *p = ptr;
		int ascii_only = 1;

		while (typtab[(unsigned char)*ptr] & IIDENT)
		    ptr++;
		if ((unsigned char)*ptr > 0x7f) {
		    ie = itype_end(ptr, IIDENT, 0);
		    if (ie != ptr) {
			ptr = ie;
			ascii_only = 0;
		    }
		}
		if (ptr != p) {
		    int func = 0;

		    if (ptr - p == 3 && !EMULATION(EMULATE_SH)) {
			if ((p[0] == 'N' || p[0] == 'n') &&
			    (p[1] == 'A' || p[1] == 'a') &&
			    (p[2] == 'N' || p[2] == 'n')) {
			    yyval.type = MN_FLOAT;
			    yyval.u.d = 0.0;
			    yyval.u.d /= yyval.u.d;
			    return NUM;
			}
			else if ((p[0] == 'I' || p[0] == 'i') &&
				 (p[1] == 'N' || p[1] == 'n') &&
				 (p[2] == 'F' || p[2] == 'f')) {
			    yyval.type = MN_FLOAT;
			    yyval.u.d = 0.0;
			    yyval.u.d = 1.0 / yyval.u.d;
			    return NUM;
			}
		    }
		    if (*ptr == '[' || (!cct && *ptr == '(')) {
			char op = *ptr, cp = ((*ptr == '[') ? ']' : ')');
			int l;
			func = (op == '(');
			for (ptr++, l = 1; *ptr && l; ptr++) {
			    if (*ptr == op)
				l++;
			    if (*ptr == cp)
				l--;
			    if (*ptr == '\\' && ptr[1])
				ptr++;
			}
			yylval = dupstrpfx(p, ptr - p);
			yylval_len = 0;
			return (func ? FUNC : (cct ? CID : ID));
		    }
		    if (!cct && ascii_only && (size_t)(ptr - p) < 64) {
			yylval = p;
			yylval_len = (int)(ptr - p);
			return ID;
		    }
		    yylval = dupstrpfx(p, ptr - p);
		    yylval_len = 0;
		    return (cct ? CID : ID);
		}
	    }
	    if (cct) {
		yyval.u.l = poundgetfn(NULL);
		return NUM;
	    }
	    return EOI;
	}
}

/**/
static void
push(mnumber val, char *lval, int lval_len, int getme)
{
    if (sp == STACKSZ - 1)
	zerr("stack overflow");
    else
	sp++;
    stack[sp].val = val;
    stack[sp].lval = lval;
    stack[sp].lval_len = lval_len;
    stack[sp].pval = NULL;
    stack[sp].cached_pm = NULL;
    if (getme)
	stack[sp].val.type = MN_UNSET;
}

/**/
static inline mnumber
pop(int noget, int keep)
{
    struct mathvalue *mv = stack+sp;

    if (mv->val.type == MN_UNSET && !noget)
	mv->val = getmathparam(mv, keep);
    sp--;
    return errflag ? zero_mnumber : mv->val;
}

/**/
static mnumber
getcvar(char *s)
{
    char *t;
    mnumber mn;
    mn.type = MN_INTEGER;

    queue_signals();
    if (!(t = getsparam(s)))
	mn.u.l = 0;
    else {
#ifdef MULTIBYTE_SUPPORT
	if (isset(MULTIBYTE)) {
	    wint_t wc;
	    (void)mb_metacharlenconv(t, &wc);
	    if (wc != WEOF) {
		mn.u.l = (zlong)wc;
		unqueue_signals();
		return mn;
	    }
	}
#endif
	mn.u.l = (unsigned char) (*t == Meta ? t[1] ^ 32 : *t);
    }
    unqueue_signals();
    return mn;
}

/**/
static mnumber
setmathvar(struct mathvalue *mvp, mnumber v)
{
    Param pm;

    if (mvp->pval) {
	/*
	 * This value may have been hanging around for a while.
	 * Be ultra-paranoid in checking the variable is still valid.
	 */
	char *s = mvp->lval, *ptr;
	Param pm;
	DPUTS(!mvp->lval, "no variable name but variable value in math");
	if ((ptr = strchr(s, '[')))
	    s = dupstrpfx(s, ptr - s);
	pm = (Param) paramtab->getnode(paramtab, s);
	if (pm == mvp->pval->pm) {
	    if (noeval)
		return v;
	    setnumvalue(mvp->pval, v);
	    return v;
	}
	/* Different parameter, start again from scratch */
	mvp->pval = NULL;
    }
    if (!mvp->lval) {
	zerr("bad math expression: lvalue required");
	v.type = MN_INTEGER;
	v.u.l = 0;
	return v;
    }
    if (noeval)
	return v;
    if (mvp->lval_len > 0) {
	char name[64];
	int same_pm;
	memcpy(name, mvp->lval, (size_t)mvp->lval_len);
	name[mvp->lval_len] = '\0';
	pm = (Param) paramtab->getnode(paramtab, name);
	same_pm = (mvp->cached_pm != NULL && pm == mvp->cached_pm);
	if (pm && isset(EXECOPT) && !isset(ALLEXPORT) && !pm->env &&
	    !(pm->node.flags & (PM_UNSET|PM_READONLY|PM_RESTRICTED|PM_EXPORTED)) &&
	    (same_pm || !isset(WARNNESTEDVAR) || pm->level >= locallevel)) {
	    int pmt = PM_TYPE(pm->node.flags);
	    if (pmt == PM_INTEGER && pm->gsu.i == &stdinteger_gsu) {
		zlong iv = (v.type == MN_INTEGER) ? v.u.l : (zlong)v.u.d;
		pm->u.val = iv;
		if (!same_pm) {
		    pm->node.flags &= ~PM_DEFAULTED;
		    if (v.type != MN_INTEGER) {
			v.u.l = iv;
			v.type = MN_INTEGER;
		    }
		}
		if (!pm->base && lastbase != -1)
		    pm->base = lastbase;
		return v;
	    }
	    if ((pmt == PM_FFLOAT || pmt == PM_EFLOAT) &&
		pm->gsu.f == &stdfloat_gsu) {
		double dv = (v.type == MN_FLOAT) ? v.u.d : (double)v.u.l;
		pm->u.dval = dv;
		if (!same_pm) {
		    pm->node.flags &= ~PM_DEFAULTED;
		    if (v.type != MN_FLOAT) {
			v.u.d = dv;
			v.type = MN_FLOAT;
		    }
		}
		return v;
	    }
	}
	if (same_pm) {
	    struct value sv;
	    memset(&sv, 0, sizeof(sv));
	    sv.pm = pm;
	    sv.end = -1;
	    setnumvalue(&sv, v);
	    return v;
	}
	mvp->cached_pm = NULL;
	mvp->lval = dupstrpfx(mvp->lval, mvp->lval_len);
	mvp->lval_len = 0;
    }
    untokenize(mvp->lval);
    pm = setnparam(mvp->lval, v);
    if (pm) {
	/*
	 * If we are performing an assignment, we return the
	 * number with the same type as the parameter we are
	 * assigning to, in the spirit of the way assignments
	 * in C work.  Note this was a change to long-standing
	 * zsh behaviour.
	 */
	switch (PM_TYPE(pm->node.flags)) {
	case PM_INTEGER:
	    if (v.type != MN_INTEGER) {
		v.u.l = (zlong)v.u.d;
		v.type = MN_INTEGER;
	    }
	    break;

	case PM_EFLOAT:
	case PM_FFLOAT:
	    if (v.type != MN_FLOAT) {
		v.u.d = (double)v.u.l;
		v.type = MN_FLOAT;
	    }
	    break;
	}
    }
    return v;
}


/**/
static mnumber
callmathfunc(char *o)
{
    MathFunc f;
    char *a, *n;
    static mnumber dummy;

    n = a = dupstring(o);

    while (*a != '(')
	a++;
    *a++ = '\0';
    a[strlen(a) - 1] = '\0';

    if ((f = getmathfunc(n, 1))) {
	if ((f->flags & (MFF_STR|MFF_USERFUNC)) == MFF_STR) {
	    return f->sfunc(n, a, f->funcid);
	} else {
	    int argc = 0;
	    mnumber *argv = NULL, *q, marg;
	    LinkList l = newlinklist();
	    LinkNode node;

	    if (f->flags & MFF_USERFUNC) {
		/* first argument is function name: always use mathfunc */
		addlinknode(l, n);
	    }

	    if (f->flags & MFF_STR) {
		if (!*a) {
		    addlinknode(l, dupstring(""));
		    argc++;
		}
	    } else {
		while (iblank(*a))
		    a++;
	    }
	    while (*a) {
		if (*a) {
		    argc++;
		    if (f->flags & MFF_USERFUNC) {
			/* need to pass strings */
			char *str;
			if (f->flags & MFF_STR) {
			    str = dupstring(a);
			    a = "";
			} else {
			    marg = mathevall(a, MPREC_ARG, &a);
			    if (marg.type & MN_FLOAT) {
				/* convfloat is off the heap */
				str = convfloat(marg.u.d, 0, 0, NULL);
			    } else {
				char buf[BDIGBUFSIZE];
				convbase(buf, marg.u.l, 10);
				str = dupstring(buf);
			    }
			}
			addlinknode(l, str);
		    } else {
			q = (mnumber *) zhalloc(sizeof(mnumber));
			*q = mathevall(a, MPREC_ARG, &a);
			addlinknode(l, q);
		    }
		    if (errflag || mtok != COMMA)
			break;
		}
	    }
	    if (*a && !errflag)
		zerr("bad math expression: illegal character: %c", *a);
	    if (!errflag) {
		if (argc >= f->minargs && (f->maxargs < 0 ||
					   argc <= f->maxargs)) {
		    if (f->flags & MFF_USERFUNC) {
			char *shfnam = f->module ? f->module : n;
			Shfunc shfunc = getshfunc(shfnam);
			if (!shfunc)
			    zerr("no such function: %s", shfnam);
			else {
			    doshfunc(shfunc, l, 1);
			    return lastmathval;
			}
		    } else {
			if (argc) {
			    q = argv =
				(mnumber *)zhalloc(argc * sizeof(mnumber));
			    for (node = firstnode(l); node; incnode(node))
				*q++ = *(mnumber *)getdata(node);
			}
			return f->nfunc(n, argc, argv, f->funcid);
		    }
		} else
		    zerr("wrong number of arguments: %s", o);
	    }
	}
    } else {
	zerr("unknown function: %s", n);
    }

    dummy.type = MN_INTEGER;
    dummy.u.l = 0;

    return dummy;
}

/**/
static int
notzero(mnumber a)
{
    if ((a.type & MN_INTEGER) && a.u.l == 0) {
        zerr("division by zero");
        return 0;
    }
    return 1;
}

/* macro to pop three values off the value stack */

static void
op(int what)
{
    mnumber a, b, c, *spval;
    int tp = type[what];

    if (errflag)
	return;
    if (sp < 0) {
	zerr("bad math expression: stack empty");
	return;
    }

    if (tp & (OP_A2|OP_A2IR|OP_A2IO|OP_E2|OP_E2IO)) {
	/* Make sure anyone seeing this message reports it. */
	DPUTS(sp < 1, "BUG: math: not enough wallabies in outback.");
	b = pop(0, 0);
	a = pop(what == EQ, tp & (OP_E2|OP_E2IO));
	if (errflag)
	    return;

	if (tp & (OP_A2IO|OP_E2IO)) {
	    /* coerce to integers */
	    if (a.type & MN_FLOAT) {
		a.type = MN_INTEGER;
		a.u.l = (zlong)a.u.d;
	    }
	    if (b.type & MN_FLOAT) {
		b.type = MN_INTEGER;
		b.u.l = (zlong)b.u.d;
	    }
	} else if (a.type != b.type && what != COMMA &&
		   (a.type != MN_UNSET || what != EQ)) {
	    /*
	     * Different types, so coerce to float.
	     * It may happen during an assignment that the LHS
	     * variable is actually an integer, but there's still
	     * no harm in doing the arithmetic in floating point;
	     * the assignment will do the correct conversion.
	     * This way, if the parameter is actually a scalar, but
	     * used to contain an integer, we can write a float into it.
	     */
	    if (a.type & MN_INTEGER) {
		a.type = MN_FLOAT;
		a.u.d = (double)a.u.l;
	    }
	    if (b.type & MN_INTEGER) {
		b.type = MN_FLOAT;
		b.u.d = (double)b.u.l;
	    }
	}

	if (noeval) {
	    c.type = MN_INTEGER;
	    c.u.l = 0;
	} else {
	    /*
	     * type for operation: usually same as operands, but e.g.
	     * (a == b) returns int.
	     */
	    c.type = (tp & OP_A2IR) ? MN_INTEGER : a.type;

	    switch(what) {
	    case AND:
	    case ANDEQ:
		c.u.l = a.u.l & b.u.l;
		break;
	    case XOR:
	    case XOREQ:
		c.u.l = a.u.l ^ b.u.l;
		break;
	    case OR:
	    case OREQ:
		c.u.l = a.u.l | b.u.l;
		break;
	    case MUL:
	    case MULEQ:
		if (c.type == MN_FLOAT)
		    c.u.d = a.u.d * b.u.d;
		else
		    c.u.l = a.u.l * b.u.l;
		break;
	    case DIV:
	    case DIVEQ:
		if (!notzero(b))
		    return;
		if (c.type == MN_FLOAT)
		    c.u.d = a.u.d / b.u.d;
		else {
		    /*
		     * Avoid exception when dividing the smallest
		     * negative integer by -1.  Always treat it the
		     * same as multiplication.  This still doesn't give
		     * numerically the right answer in two's complement,
		     * but treating both these in the same way seems
		     * reasonable.
		     */
		    if (b.u.l == -1)
			c.u.l = - a.u.l;
		    else
			c.u.l = a.u.l / b.u.l;
		}
		break;
	    case MOD:
	    case MODEQ:
		if (!notzero(b))
		    return;
		/*
		 * Avoid exception as above.
		 * Any integer mod -1 is the same as any integer mod 1
		 * i.e. zero.
		 */
		if (c.type == MN_FLOAT)
		    c.u.d = fmod(a.u.d, b.u.d);
		else if (b.u.l == -1)
		    c.u.l = 0;
		else
		    c.u.l = a.u.l % b.u.l;
		break;
	    case PLUS:
	    case PLUSEQ:
		if (c.type == MN_FLOAT)
		    c.u.d = a.u.d + b.u.d;
		else
		    c.u.l = a.u.l + b.u.l;
		break;
	    case MINUS:
	    case MINUSEQ:
		if (c.type == MN_FLOAT)
		    c.u.d = a.u.d - b.u.d;
		else
		    c.u.l = a.u.l - b.u.l;
		break;
	    case SHLEFT:
	    case SHLEFTEQ:
		c.u.l = a.u.l << b.u.l;
		break;
	    case SHRIGHT:
	    case SHRIGHTEQ:
		c.u.l = a.u.l >> b.u.l;
		break;
	    case LES:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d < b.u.d) : (a.u.l < b.u.l));
		break;
	    case LEQ:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d <= b.u.d) : (a.u.l <= b.u.l));
		break;
	    case GRE:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d > b.u.d) : (a.u.l > b.u.l));
		break;
	    case GEQ:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d >= b.u.d) : (a.u.l >= b.u.l));
		break;
	    case DEQ:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d == b.u.d) : (a.u.l == b.u.l));
		break;
	    case NEQ:
		c.u.l = (zlong)
		    (a.type == MN_FLOAT ? (a.u.d != b.u.d) : (a.u.l != b.u.l));
		break;
	    case DAND:
	    case DANDEQ:
		c.u.l = (zlong)(a.u.l && b.u.l);
		break;
	    case DOR:
	    case DOREQ:
		c.u.l = (zlong)(a.u.l || b.u.l);
		break;
	    case DXOR:
	    case DXOREQ:
		c.u.l = (zlong)((a.u.l && !b.u.l) || (!a.u.l && b.u.l));
		break;
	    case COMMA:
		c = b;
		break;
	    case POWER:
	    case POWEREQ:
		if (c.type == MN_INTEGER && b.u.l < 0) {
		    /* produces a real result, so cast to real. */
		    a.type = b.type = c.type = MN_FLOAT;
		    a.u.d = (double) a.u.l;
		    b.u.d = (double) b.u.l;
		}
		if (c.type == MN_INTEGER) {
		    for (c.u.l = 1; b.u.l--; c.u.l *= a.u.l);
		} else {
		    if (b.u.d <= 0 && !notzero(a))
			return;
		    if (a.u.d < 0) {
			/* Error if (-num ** b) and b is not an integer */
			double tst = (double)(zlong)b.u.d;
			if (tst != b.u.d) {
			    zerr("bad math expression: imaginary power");
			    return;
			}
		    }
		    c.u.d = pow(a.u.d, b.u.d);
		}
		break;
	    case EQ:
		c = b;
		break;
	    }
	}
	if (tp & (OP_E2|OP_E2IO)) {
	    struct mathvalue *mvp = stack + sp + 1;
	    c = setmathvar(mvp, c);
	    push(c, mvp->lval, mvp->lval_len, 0);
	} else
	    push(c, NULL, 0, 0);
	return;
    }

    spval = &stack[sp].val;
    if (stack[sp].val.type == MN_UNSET) {
	*spval = getmathparam(stack + sp, 1);
	if (errflag)
	    return;
    }
    switch (what) {
    case NOT:
	if (spval->type & MN_FLOAT) {
	    spval->u.l = !spval->u.d;
	    spval->type = MN_INTEGER;
	} else
	    spval->u.l = !spval->u.l;
	break;
    case COMP:
	if (spval->type & MN_FLOAT) {
	    spval->u.l = ~((zlong)spval->u.d);
	    spval->type = MN_INTEGER;
	} else
	    spval->u.l = ~spval->u.l;
	break;
    case POSTPLUS:
	a = *spval;
	if (spval->type & MN_FLOAT)
	    a.u.d++;
	else
	    a.u.l++;
	(void)setmathvar(stack + sp, a);
	break;
    case POSTMINUS:
	a = *spval;
	if (spval->type & MN_FLOAT)
	    a.u.d--;
	else
	    a.u.l--;
	(void)setmathvar(stack + sp, a);
	break;
    case UPLUS:
	break;
    case UMINUS:
	if (spval->type & MN_FLOAT)
	    spval->u.d = -spval->u.d;
	else
	    spval->u.l = -spval->u.l;
	break;
    case QUEST:
	DPUTS(sp < 2, "BUG: math: three shall be the number of the counting.");
	c = pop(0, 0);
	b = pop(0, 0);
	a = pop(0, 0);
	if (errflag)
	    return;
	/* b and c can stay different types in this case. */
	push(((a.type & MN_FLOAT) ? a.u.d : a.u.l) ? b : c, NULL, 0, 0);
	break;
    case COLON:
	zerr("bad math expression: ':' without '?'");
	break;
    case PREPLUS:
	if (spval->type & MN_FLOAT)
	    spval->u.d++;
	else
	    spval->u.l++;
	setmathvar(stack + sp, *spval);
	break;
    case PREMINUS:
	if (spval->type & MN_FLOAT)
	    spval->u.d--;
	else
	    spval->u.l--;
	setmathvar(stack + sp, *spval);
	break;
    default:
	zerr("bad math expression: out of integers");
	return;
    }
    stack[sp].lval = NULL;
    stack[sp].lval_len = 0;
    stack[sp].pval = NULL;
    stack[sp].cached_pm = NULL;
}


/**/
static void
bop(int tk)
{
    mnumber *spval = &stack[sp].val;
    int tst;

    if (stack[sp].val.type == MN_UNSET)
	*spval = getmathparam(stack + sp, 1);
    tst = (spval->type & MN_FLOAT) ? (zlong)spval->u.d : spval->u.l; 

    switch (tk) {
    case DAND:
    case DANDEQ:
	if (!tst)
	    noeval++;
	break;
    case DOR:
    case DOREQ:
	if (tst)
	    noeval++;
	break;
    };
}


/**/
mod_export mnumber
matheval(char *s)
{
    char *junk;
    mnumber x;
    int xmtok = mtok;
    /* maintain outputradix and outputunderscore across levels of evaluation */
    if (!mlevel)
	outputradix = outputunderscore = 0;

    if (*s == Nularg)
	s++;
    if (!*s) {
	x.type = MN_INTEGER;
	x.u.l = 0;
	return x;
    }
    if (mbc_eval(s, 0, &x, NULL))
	return lastmathval = x;
    x = mathevall(s, MPREC_TOP, &junk);
    mtok = xmtok;
    if (*junk)
	zerr("bad math expression: illegal character: %c", *junk);
    return x;
}

/**/
mod_export zlong
mathevali(char *s)
{
    mnumber x = matheval(s);
    return (x.type & MN_FLOAT) ? (zlong)x.u.d : x.u.l;
}


/**/
zlong
mathevalarg(char *s, char **ss)
{
    mnumber x;
    int xmtok = mtok;
    unsigned len;

    /*
     * At this entry point we don't allow an empty expression,
     * whereas we do with matheval().  I'm not sure if this
     * difference is deliberate, but it does mean that e.g.
     * $array[$ind] where ind hasn't been set produces an error,
     * which is probably safe.
     *
     * To avoid a more opaque error further in, bail out here.
     */
    if (*s == Nularg)
	s++;
    if (!*s) {
	zerr("bad math expression: empty string");
	return (zlong)0;
    }
    if (!errflag && !noeval && mlevel < MAX_MLEVEL &&
	isset(EXECOPT) && !isset(FORCEFLOAT) && !isset(OCTALZEROES)) {
	const char *p = s;
	zlong val;
	if ((unsigned char)(*p - '0') <= 9U || IS_DASH(*p)) {
	    int neg = 0;
	    if (IS_DASH(*p)) {
		neg = 1;
		p++;
	    }
	    if (mbc_lex_decimal(&p, &val) && *p == '\0') {
		if (neg)
		    val = -val;
		if (!mlevel)
		    lastbase = -1;
		lastmathval.type = MN_INTEGER;
		lastmathval.u.l = val;
		*ss = (char *)p;
		return val;
	    }
	} else if ((unsigned char)*p <= 0x7f &&
		   (typtab[(unsigned char)*p] & IIDENT) &&
		   psh_paramtab_is_standard()) {
	    unsigned hv = 0;
	    while ((unsigned char)*p <= 0x7f &&
		   (typtab[(unsigned char)*p] & IIDENT)) {
		hv += (hv << 5) + (unsigned char)*p;
		p++;
	    }
	    if (*p == '\0') {
		size_t nlen = (size_t)(p - s);
		if (nlen < 32 &&
		    !(nlen == 3 &&
		      ((((s[0] | 32) == 'n') && ((s[1] | 32) == 'a') &&
			((s[2] | 32) == 'n')) ||
		       (((s[0] | 32) == 'i') && ((s[1] | 32) == 'n') &&
			((s[2] | 32) == 'f'))))) {
		    Param pm;
		    queue_signals();
		    pm = mbc_lookup_param(s, hv);
		    if (pm && !(pm->node.flags & (PM_UNSET|PM_AUTOLOAD))) {
			int pmt = PM_TYPE(pm->node.flags);
			if (pmt == PM_INTEGER && pm->gsu.i == &stdinteger_gsu) {
			    val = pm->u.val;
			    unqueue_signals();
			    if (!mlevel)
				lastbase = -1;
			    lastmathval.type = MN_INTEGER;
			    lastmathval.u.l = val;
			    *ss = (char *)p;
			    return val;
			}
			if (pmt == PM_SCALAR && pm->gsu.s == &stdscalar_gsu) {
			    const char *sv = pm->u.str;
			    if (!sv || !*sv) {
				unqueue_signals();
				if (!mlevel)
				    lastbase = -1;
				lastmathval.type = MN_INTEGER;
				lastmathval.u.l = 0;
				*ss = (char *)p;
				return 0;
			    }
			    if (math_parse_plain_decimal(sv, &val)) {
				unqueue_signals();
				if (!mlevel)
				    lastbase = -1;
				lastmathval.type = MN_INTEGER;
				lastmathval.u.l = val;
				*ss = (char *)p;
				return val;
			    }
			}
		    }
		    unqueue_signals();
		}
		goto slow_arg;
	    }
	}
    }
    if (mbc_eval(s, 1, &x, &len)) {
	*ss = s + len;
	lastmathval = x;
	return x.u.l;
    }
slow_arg:
    x = mathevall(s, MPREC_ARG, ss);
    if (mtok == COMMA)
	(*ss)--;
    mtok = xmtok;
    return (x.type & MN_FLOAT) ? (zlong)x.u.d : x.u.l;
}

/*
 * Make sure we have an operator or an operand, whatever is expected.
 * For this purpose, unary operators constitute part of an operand.
 */

/**/
static inline void
checkunary(int mtokc, char *mptr)
{
    int errmsg = 0;
    int tp = type[mtokc];
    if (tp & (OP_A2|OP_A2IR|OP_A2IO|OP_E2|OP_E2IO|OP_OP)) {
	if (unary)
	    errmsg = 1;
    } else {
	if (!unary)
	    errmsg = 2;
    }
    if (errmsg) {
	int len, over = 0;
	char *errtype = errmsg == 2 ? "operator" : "operand";
	while (inblank(*mptr))
	    mptr++;
	len = ztrlen(mptr);
	if (len > 10) {
	    len = 10;
	    over = 1;
	}
	if (!*mptr)
	    zerr("bad math expression: %s expected at end of string",
		errtype);
	else
	    zerr("bad math expression: %s expected at `%l%s'",
		 errtype, mptr, len, over ? "..." : "");
    }
    unary = !(tp & OP_OPF);
}

/* operator-precedence parse the string and execute */

/**/
static void
mathparse(int pc)
{
    zlong q;
    int otok, onoeval;
    int cur_pc = pc;
    int op_tok[64], op_pc[64];
    int osp = 0;
    char *optr = ptr;

    if (errflag)
	return;
    mtok = zzlex();
    /* Handle empty input */
    if (pc == TOPPREC && mtok == EOI)
	return;
    checkunary(mtok, optr);
    for (;;) {
	while (prec[mtok] <= cur_pc) {
	    if (errflag)
		return;
	    switch (mtok) {
	    case NUM:
		push(yyval, NULL, 0, 0);
		break;
	    case ID:
		push(zero_mnumber, yylval, yylval_len, !noeval);
		break;
	    case CID:
		push((noeval ? zero_mnumber : getcvar(yylval)), yylval, 0, 0);
		break;
	    case FUNC:
		push((noeval ? zero_mnumber : callmathfunc(yylval)), yylval, 0, 0);
		break;
	    case M_INPAR:
		mathparse(TOPPREC);
		if (mtok != M_OUTPAR) {
		    if (!errflag)
			zerr("bad math expression: ')' expected");
		    return;
		}
		break;
	    case QUEST:
		if (stack[sp].val.type == MN_UNSET)
		    stack[sp].val = getmathparam(stack + sp, 1);
		q = (stack[sp].val.type == MN_FLOAT) ?
		    (stack[sp].val.u.d == 0 ? 0 : 1) :
		    stack[sp].val.u.l;

		if (!q)
		    noeval++;
		mathparse(prec[COLON] - 1);
		if (!q)
		    noeval--;
		if (mtok != COLON) {
		    if (!errflag)
			zerr("bad math expression: ':' expected");
		    return;
		}
		if (q)
		    noeval++;
		mathparse(prec[QUEST]);
		if (q)
		    noeval--;
		op(QUEST);
		continue;
	    default:
		otok = mtok;
		if (MTYPE(type[otok]) == BOOL || osp == 64) {
		    onoeval = noeval;
		    if (MTYPE(type[otok]) == BOOL)
			bop(otok);
		    mathparse(prec[otok] - (MTYPE(type[otok]) != RL));
		    noeval = onoeval;
		    op(otok);
		    continue;
		}
		op_tok[osp] = otok;
		op_pc[osp] = cur_pc;
		osp++;
		cur_pc = prec[otok] - (MTYPE(type[otok]) != RL);
		optr = ptr;
		mtok = zzlex();
		checkunary(mtok, optr);
		continue;
	    }
	    optr = ptr;
	    mtok = zzlex();
	    checkunary(mtok, optr);
	}
	if (!osp)
	    break;
	osp--;
	cur_pc = op_pc[osp];
	op(op_tok[osp]);
	if (errflag)
	    return;
    }
}
