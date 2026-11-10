/* Test-only, read-only observation of the visible parameter table. */
#include "zsh.mdh"

static int
bin_observe(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops),
            UNUSED(int func))
{
    HashTable table;
    HashNode node;
    int bucket, visible = 0, local = 0, shadowed = 0;

    queue_signals();
    table = paramtab;
    for (bucket = 0; bucket < table->hsize; bucket++)
        for (node = table->nodes[bucket]; node; node = node->next) {
            Param pm = (Param)node;
            visible++;
            local += pm->level > 0;
            shadowed += pm->old != NULL;
        }
    printf("{\"count\":%d,\"buckets\":%d,\"visible\":%d,"
           "\"local\":%d,\"shadowed\":%d,\"level\":%d}\n",
           table->ct, table->hsize, visible, local, shadowed, locallevel);
    unqueue_signals();
    return 0;
}

static int
bin_tracking(UNUSED(char *n), UNUSED(char **a), UNUSED(Options o), UNUSED(int f))
{
#ifdef PSH_SCOPE_INDEX_VERSION
    printf("%d\n", psh_scope_tracking());
#else
    printf("0\n");
#endif
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-scope-observe", 0, bin_observe, 0, 0, 0, NULL, NULL),
    BUILTIN("psh-scope-tracking", 0, bin_tracking, 0, 0, 0, NULL, NULL)
};
static struct features features = {bintab, 2, NULL, 0, NULL, 0, NULL, 0, 0};
int setup_(UNUSED(Module m)) {
#ifdef PSH_SCOPE_INDEX_VERSION
    psh_scope_module_ack(m);
#endif
    return 0;
}
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
