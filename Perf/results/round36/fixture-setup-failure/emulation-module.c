/*
 * options.c - shell options
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

/* Test-only option-table fixture. The entry point is exported by the host
 * executable but is internal, not a new supported native-module interface. */
#include "zsh.mdh"
#include <limits.h>
extern void installemulation(int, char *);

/* These private flags are copied from the original release options.c. */
#define F_EMULATE EMULATE_UNUSED
#define F_SPECIAL (EMULATE_UNUSED << 1)
#define F_ALIAS (EMULATE_UNUSED << 2)
static int ref_mode, expected_queue, bad, generated_count, generated_flags;
static unsigned generated_trace, checks, digest, saw_queued, saw_unqueued;
static char *ref_opts;

static void
reference_set(HashNode hn, int fully)
{
    Optname on = (Optname)hn;
    if (!(on->node.flags & F_ALIAS) &&
        ((fully && !(on->node.flags & F_SPECIAL)) || (on->node.flags & F_EMULATE)))
        ref_opts[on->optno] = !!(on->node.flags & ref_mode);
}

static void
reference_install(int mode, char *out)
{
    ref_mode = mode; ref_opts = out;
    scanhashtable(optiontab, 0, 0, 0, reference_set, !!(mode & EMULATE_FULLY));
}

static void
generated(HashTable ht, ScanFunc fn, int flags)
{
    int i;
    generated_count++;
    generated_flags = flags;
    if (queue_signal_level() != expected_queue) bad = 1;
    for (i = ht->hsize - 1; i >= 0; i--) {
        HashNode hn;
        for (hn = ht->nodes[i]; hn; hn = hn->next) {
            generated_trace = generated_trace * 33 + (unsigned)((Optname)hn)->optno;
            fn(hn, flags);
        }
    }
}

static void
free_option(HashNode hn)
{
    zsfree(hn->nam); zfree(hn, sizeof(struct optname));
}

static void
empty_options(HashTable ht)
{
    int i;
    for (i = 0; i < ht->hsize; i++) {
        HashNode hn = ht->nodes[i];
        while (hn) { HashNode next = hn->next; ht->freenode(hn); hn = next; }
        ht->nodes[i] = NULL;
    }
    ht->ct = 0;
}

static int
one(HashTable ht, int mode, unsigned pattern, int queued, int own_level)
{
    HashTable saved_table = optiontab;
    unsigned offset = checks & 1, i, count, trace;
    char *a = zalloc(OPT_SIZE + offset), *b = zalloc(OPT_SIZE + offset);
    int flags;
    for (i = 0; i < OPT_SIZE + offset; i++) a[i] = b[i] =
        pattern == 0 ? 0 : pattern == 1 ? 1 : (char)(i * 37 + 0xa5);
    dont_queue_signals();
    restore_queue_signals(queued ? own_level : 0);
    expected_queue = queue_signal_level();
    if (expected_queue) saw_queued++; else saw_unqueued++;
    optiontab = ht;
    generated_count = generated_trace = 0; generated_flags = -99;
    reference_install(mode, a + offset);
    count = generated_count; trace = generated_trace; flags = generated_flags;
    generated_count = generated_trace = 0; generated_flags = -99;
    installemulation(mode, b + offset);
    if (memcmp(a, b, OPT_SIZE + offset) || generated_count != count ||
        generated_trace != trace || generated_flags != flags ||
        queue_signal_level() != expected_queue) bad = 1;
    optiontab = saved_table;
    restore_queue_signals(own_level);
    for (i = 0; i < OPT_SIZE + offset; i++) digest = digest * 33 + (unsigned char)b[i];
    zfree(a, OPT_SIZE + offset); zfree(b, OPT_SIZE + offset);
    checks++;
    if (bad) fprintf(stderr, "emulation mismatch: mode=%d pattern=%u queued=%d count=%u\n",
                     mode, pattern, queued, checks);
    return bad;
}

static int
matrix(HashTable ht, int own_level)
{
    unsigned mode, pattern, queued;
    for (mode = 0; mode < 128 && !bad; mode++)
        for (pattern = 0; pattern < 3 && !bad; pattern++)
            for (queued = 0; queued < 2 && !bad; queued++)
                one(ht, mode, pattern, queued, own_level);
    one(ht, INT_MAX, 2, 1, own_level);
    one(ht, INT_MIN, 2, 0, own_level);
    return bad;
}

struct alias_option { struct optname on; char payload[OPT_SIZE]; };
static unsigned alias_hash(UNUSED(const char *name)) { return 0; }
static void free_alias(HashNode hn) {
    zsfree(hn->nam); zfree(hn, sizeof(struct alias_option));
}

static HashTable nested_table;
static char *nested_out;
static int nested_mode;

/* The released setter uses shared state. A generated provider can overwrite
 * it by installing defaults recursively: later outer visits then write into
 * the inner destination using the inner mode but the outer fully argument. */
static void
reentrant_generated(HashTable ht, ScanFunc fn, int flags)
{
    HashNode hn = ht->nodes[0];
    HashTable saved_table = optiontab;
    if (queue_signal_level() != expected_queue) bad = 1;
    generated_count++;
    fn(hn, flags);
    optiontab = nested_table;
    if (fn == reference_set)
        reference_install(nested_mode, nested_out);
    else
        installemulation(nested_mode, nested_out);
    optiontab = saved_table;
    for (hn = hn->next; hn; hn = hn->next)
        fn(hn, flags);
}

static void
reentry_cases(int own_level)
{
    HashTable saved_table = optiontab;
    HashTable outer = newhashtable(1, "outer emulation provider", NULL);
    unsigned i, mode, variant, queued, gen;
    char a[OPT_SIZE], b[OPT_SIZE], ia[OPT_SIZE], ib[OPT_SIZE];
    outer->hash = alias_hash; outer->cmpnodes = strcmp;
    outer->emptytable = empty_options; outer->freenode = free_option;
    outer->scantab = reentrant_generated;
    nested_table = newhashtable(7, "inner emulation table", NULL);
    nested_table->hash = hasher; nested_table->cmpnodes = strcmp;
    nested_table->emptytable = empty_options; nested_table->freenode = free_option;
    for (i = 0; i < 8; i++) {
        char key[16];
        Optname on = zshcalloc(sizeof(*on)), inner = zshcalloc(sizeof(*inner));
        sprintf(key, "nested_%u", i);
        on->optno = inner->optno = i + 1;
        on->node.flags = i == 7 ? F_EMULATE | EMULATE_SH : (i * 73) & 511;
        inner->node.flags = F_EMULATE | EMULATE_ZSH | EMULATE_KSH;
        addhashnode(outer, ztrdup(key), on);
        addhashnode(nested_table, ztrdup(key), inner);
    }
    for (mode = 0; mode < 128 && !bad; mode++)
    for (variant = 0; variant < 3 && !bad; variant++)
    for (queued = 0; queued < 2 && !bad; queued++)
    for (gen = 0; gen < 2 && !bad; gen++) {
        unsigned count, trace;
        int flags;
        nested_table->scantab = gen ? generated : NULL;
        nested_mode = variant == 0 ? (mode ^ 127) :
            variant == 1 ? EMULATE_ZSH : EMULATE_SH | EMULATE_FULLY;
        for (i = 0; i < OPT_SIZE; i++) {
            a[i] = b[i] = (char)(i * 37 + mode);
            ia[i] = ib[i] = (char)(i * 19 + variant);
        }
        dont_queue_signals(); restore_queue_signals(queued ? own_level : 0);
        expected_queue = queue_signal_level();
        if (expected_queue) saw_queued++; else saw_unqueued++;
        optiontab = outer; nested_out = ia;
        generated_count = generated_trace = 0; generated_flags = -99;
        reference_install(mode, a);
        count = generated_count; trace = generated_trace; flags = generated_flags;
        nested_out = ib;
        generated_count = generated_trace = 0; generated_flags = -99;
        installemulation(mode, b);
        if (memcmp(a, b, OPT_SIZE) || memcmp(ia, ib, OPT_SIZE) ||
            generated_count != count || generated_trace != trace ||
            generated_flags != flags || queue_signal_level() != expected_queue)
            bad = 1;
        restore_queue_signals(own_level);
        for (i = 0; i < OPT_SIZE; i++)
            digest = digest * 33 + (unsigned char)b[i] + (unsigned char)ib[i];
        checks++;
    }
    optiontab = saved_table;
    deletehashtable(outer); deletehashtable(nested_table);
}

/* A valid character-array view into an extended node lets earlier writes
 * change a later node's flags. Selection must observe those live changes. */
static void
alias_case(int mode, int queued, unsigned initial_alias, int own_level)
{
    HashTable saved_table = optiontab;
    HashTable ht = newhashtable(1, "aliased emulation output", NULL);
    struct alias_option *target = NULL;
    char before[OPT_SIZE], expected[OPT_SIZE], *out;
    unsigned i;
    ht->hash = alias_hash; ht->cmpnodes = strcmp; ht->addnode = addhashnode;
    ht->freenode = free_alias; ht->emptytable = empty_options;
    for (i = 0; i < 4; i++) {
        struct alias_option *node = zshcalloc(sizeof(*node));
        char name[16]; sprintf(name, "alias_%u", i);
        node->on.node.flags = F_EMULATE | EMULATE_SH | (i == 0 && initial_alias ? F_ALIAS : 0);
        node->on.optno = i;
        addhashnode(ht, ztrdup(name), node);
        if (!i) target = node;
    }
    out = (char *)&target->on.node.flags;
    memcpy(before, out, OPT_SIZE);
    dont_queue_signals();
    restore_queue_signals(queued ? own_level : 0);
    if (queue_signal_level()) saw_queued++; else saw_unqueued++;
    optiontab = ht;
    reference_install(mode, out); memcpy(expected, out, OPT_SIZE);
    memcpy(out, before, OPT_SIZE);
    installemulation(mode, out);
    if (memcmp(out, expected, OPT_SIZE) || queue_signal_level() != (queued ? own_level : 0)) bad = 1;
    digest = digest * 33 + (unsigned)target->on.node.flags;
    optiontab = saved_table; restore_queue_signals(own_level);
    deletehashtable(ht); checks++;
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned sizes[] = {0, 1, 7, 32, 185, 257};
    static const unsigned buckets[] = {1, 7, 101};
    HashTable saved_table = optiontab;
    char saved_opts[OPT_SIZE];
    unsigned n, h, seed, gen, i;
    int entry_queue = queue_signal_level(), own_level;
    memcpy(saved_opts, opts, sizeof(saved_opts));
    queue_signals(); own_level = queue_signal_level();
    checks = digest = saw_queued = saw_unqueued = bad = 0;
    matrix(saved_table, own_level);
    for (n = 0; n < sizeof(sizes)/sizeof(sizes[0]) && !bad; n++)
    for (h = 0; h < sizeof(buckets)/sizeof(buckets[0]) && !bad; h++)
    for (seed = 0; seed < 2 && !bad; seed++) {
        HashTable ht = newhashtable(buckets[h], "emulation fixture", NULL);
        ht->hash = hasher; ht->cmpnodes = strcmp;
        ht->addnode = addhashnode; ht->getnode = gethashnode; ht->getnode2 = gethashnode2;
        ht->removenode = removehashnode; ht->freenode = free_option; ht->emptytable = empty_options;
        for (i = 0; i < sizes[n]; i++) {
            char key[32];
            Optname on = zshcalloc(sizeof(*on));
            sprintf(key, "option_%03u", i);
            on->node.flags = (i + seed * 256) & 511;
            on->optno = on->node.flags & F_ALIAS ? -1 - (int)(i % OPT_SIZE) : (int)(i % OPT_SIZE);
            addhashnode(ht, ztrdup(key), on);
        }
        for (gen = 0; gen < 2 && !bad; gen++) {
            ht->scantab = gen ? generated : NULL;
            matrix(ht, own_level);
        }
        deletehashtable(ht);
    }
    for (i = 0; i < 128 && !bad; i++) {
        unsigned alias, queued;
        for (alias = 0; alias < 2; alias++)
            for (queued = 0; queued < 2; queued++)
                alias_case(i, queued, alias, own_level);
    }
    reentry_cases(own_level);
    optiontab = saved_table;
    installemulation(emulation, opts);
    memcpy(opts, saved_opts, sizeof(saved_opts));
    unqueue_signals();
    if (queue_signal_level() != entry_queue || !saw_queued || !saw_unqueued) bad = 1;
    if (bad) return 1;
    printf("checks=%u digest=%u queued=%u unqueued=%u\nmatrix-done\n",
           checks, digest, saw_queued, saw_unqueued);
    return 0;
}
static struct builtin bintab[] = {BUILTIN("psh-emulation-check", 0, bin_check, 0, 0, 0, NULL, NULL)};
static struct features module_features = {bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features = featuresarray(m, &module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
