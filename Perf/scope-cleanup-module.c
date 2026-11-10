/* Test-only live parameter levels, restoration callbacks and scan mutations. */
#include "zsh.mdh"
#include <stdint.h>
#include <inttypes.h>

static HashTable table;
static int mode, baselevel, recording, triggered, bad, expected_queue;
static int scope_trace[256], ntrace, generated_calls;
static uint64_t digest;
static char fixture_names[3][96][64];
static int fixture_name_size;
static void initialize_names(int size) {
    int layout, id;
    if (fixture_name_size == size) return;
    for (layout = 0; layout < 3; layout++) for (id = 0; id < 96; id++) {
        unsigned salt = 0, bucket = (layout == 1 && id >= 4) || (layout == 2 && id == 0);
        do {
            snprintf(fixture_names[layout][id], 64, "p%03d_%u", id, salt++);
        } while (hasher(fixture_names[layout][id]) % size != bucket);
    }
    fixture_name_size = size;
}
static void notify(Param pm) {
#if defined(PSH_SCOPE_INDEX_VERSION) && defined(PSH_SCOPE_FIXTURE_AWARE)
    psh_scope_mark(pm);
#else
    (void)pm;
#endif
}
static void mix(uint64_t x) { digest = digest * UINT64_C(1099511628211) + x; }
static void token(int value) {
    if (ntrace >= 256) bad = 1;
    else scope_trace[ntrace++] = value;
}
static void name(int id, char *s) {
    int layout = mode == 8 || mode == 9 ? 1 : mode == 12 ? 2 : 0;
    strcpy(s, fixture_names[layout][id]);
}
static Param lookup(int id) {
    char s[64]; name(id, s); return (Param)gethashnode2(table, s);
}
static void fixture_unset(Param, int);
static void fixture_set(Param pm, char *value) {
    if (recording) {
        token(20000 + atoi(pm->node.nam + 1) * 10);
        if (pm->level != baselevel || queueing_enabled != expected_queue) bad = 1;
    }
    strsetfn(pm, value);
}
static const struct gsu_scalar ordinary = {strgetfn, strsetfn, fixture_unset};
static const struct gsu_scalar special = {strgetfn, fixture_set, fixture_unset};
static Param insert(int id, int generation, int level) {
    char s[64]; Param pm = (Param)zshcalloc(sizeof(*pm));
    name(id, s); pm->level = level; pm->base = generation;
    pm->node.flags = PM_SCALAR; pm->gsu.s = &ordinary;
    pm->u.str = ztrdup("local");
    addhashnode(table, ztrdup(s), pm);
    return pm;
}
static int observed;
static void observe(UNUSED(HashNode hn), UNUSED(int flags)) { observed++; }
static void fixture_unset(Param pm, int explicit) {
    if (recording) {
        int i, size = table->hsize;
        token(atoi(pm->node.nam + 1) * 10 + pm->base + (explicit ? 10000 : 0));
        if (queueing_enabled != expected_queue) bad = 1;
        if (!triggered++) {
            switch (mode) {
            case 3: case 12: lookup(0)->level = baselevel + 1; notify(lookup(0)); break;
            case 4: lookup(2)->level = baselevel; break;
            case 5: unsetparam_pm(lookup(2), 0, 1); break;
            case 6: {
                Param old = lookup(2);
                stdunsetfn(old, 1);
                insert(2, 1, baselevel + 1); break;
            }
            case 7: case 8: insert(4, 0, baselevel + 1); break;
            case 9:
                for (i = 4; i < 96; i++) insert(i, 0, baselevel + 1);
                if (table->hsize != size) bad = 1;
                break;
            case 11:
                observed = 0;
                if (scanhashtable(table, 0, 0, 0, observe, 0) != 4 || observed != 4)
                    bad = 1;
                break;
            }
        }
    }
    stdunsetfn(pm, explicit);
}
static void generated(HashTable ht, ScanFunc fn, int flags) {
    generated_calls++;
    if (flags != 0) bad = 1;
    ht->scantab = NULL;
    scanhashtable(ht, 0, 0, 0, fn, flags);
    ht->scantab = generated;
}
static int scenario(int size, int generated_table, int queued) {
    HashTable saved = paramtab, saved_real = realparamtab;
    int saved_level = locallevel, start_queue = queueing_enabled, saved_errno = errno;
    int expected[256], count = 0, i, j, remaining;
    initialize_names(size);
    table = newparamtable(size, "scope-cleanup-fixture"); realparamtab = table;
    paramtab = table; locallevel = baselevel; startparamscope();
    recording = triggered = ntrace = generated_calls = 0;
    if (mode) for (i = 0; i < 4; i++) {
        Param pm = insert(i, 0, mode == 1 || i == 0 ? baselevel : locallevel + (i == 1 ? 2 : 0));
        if (mode == 10 && i == 2) {
            Param old = (Param)zshcalloc(sizeof(*old));
            old->node.flags = PM_SPECIAL; old->level = baselevel;
            old->u.str = ztrdup("outer");
            pm->node.flags |= PM_SPECIAL; pm->old = old; pm->gsu.s = &special;
        }
    }
    if (generated_table) table->scantab = generated;
    if (queued) queue_signals();
    expected_queue = queueing_enabled + 1; recording = 1;
    errno = E2BIG;
    endparamscope(); mix(errno); recording = 0;
    if (queued) unqueue_signals();
    if (mode >= 2) {
        expected[count++] = 30;
        if (mode != 4) expected[count++] = mode == 5 ? 10020 : mode == 6 ? 21 : mode == 10 ? 20020 : 20;
        expected[count++] = 10;
        if (mode == 3 || mode == 12) expected[count++] = 0;
        if (mode == 8) expected[count++] = 40;
        if (mode == 9) for (i = 95; i >= 4; i--) expected[count++] = i * 10;
    }
    remaining = mode == 0 || mode == 3 || mode == 12 ? 0 : mode == 1 ? 4 : mode == 4 || mode == 7 || mode == 10 ? 2 : 1;
    if (ntrace != count || table->ct != remaining || locallevel != baselevel ||
        queueing_enabled != start_queue || generated_calls != generated_table) bad = 1;
    for (i = 0; i < count; i++) if (scope_trace[i] != expected[i]) bad = 1;
    if (mode == 10) {
        Param pm = lookup(2);
        if (!pm || pm->level != baselevel || pm->old || strcmp(pm->u.str, "outer")) bad = 1;
    }
    mix(count); for (i = 0; i < ntrace; i++) mix(scope_trace[i]); mix(table->ct);
    for (i = 0; i < table->hsize; i++) for (j = 0; j < 4; j++) {
        Param pm = lookup(j);
        if (pm && hasher(pm->node.nam) % table->hsize == (unsigned)i) {
            mix(j); mix(pm->level); mix(pm->node.flags); mix(pm->base);
        }
    }
    table->scantab = NULL;
    paramtab = saved; realparamtab = saved_real; locallevel = saved_level; deleteparamtable(table); errno = saved_errno;
    if (bad) fprintf(stderr, "scope fixture: size=%d generated=%d queued=%d base=%d mode=%d scope_trace=%d expected=%d\n",
                     size, generated_table, queued, baselevel, mode, ntrace, count);
    return bad;
}
static int run(UNUSED(char *n), char **a, UNUSED(Options o), UNUSED(int f)) {
    static const int sizes[] = {4,5,7,17,31,151,257};
    static const int levels[] = {0,2,9};
    unsigned s, l, checks = 0; int g, q;
#ifdef PSH_SCOPE_INDEX_VERSION
    {
        int expected = 0;
# ifdef PSH_SCOPE_FIXTURE_AWARE
        expected = !(a[0] && !strcmp(a[0], "legacy"));
# endif
        if (psh_scope_tracking() != expected) {
            fprintf(stderr, "unexpected scope tracking state\n"); return 2;
        }
    }
#endif
    bad = 0; digest = 0;
    for (s = 0; s < sizeof(sizes)/sizeof(sizes[0]); s++)
    for (l = 0; l < sizeof(levels)/sizeof(levels[0]); l++)
    for (g = 0; g < 2; g++) for (q = 0; q < 2; q++)
    for (mode = 0; mode < 13; mode++) {
        baselevel = levels[l];
        if (scenario(sizes[s], g, q)) return 1;
        checks++;
    }
    printf("checks=%u digest=%" PRIu64 "\nscope-done\n", checks, digest); fflush(stdout);
    return 0;
}
static struct builtin bintab[] = {BUILTIN("psh-scope-cleanup-check",0,run,0,1,0,NULL,NULL)};
static struct features features = {bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) {
#if defined(PSH_SCOPE_INDEX_VERSION) && defined(PSH_SCOPE_FIXTURE_AWARE)
    psh_scope_module_ack(m);
#endif
    return 0;
}
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
