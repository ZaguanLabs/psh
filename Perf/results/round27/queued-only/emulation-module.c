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
        while (hn) { HashNode next = hn->next; free_option(hn); hn = next; }
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
