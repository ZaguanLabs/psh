/* Exercise temporary heap lifetimes through the exported module API. */
#include "zsh.mdh"

static int
filled(const unsigned char *bytes, size_t count, unsigned char value)
{
    size_t i;
    for (i = 0; i < count; ++i)
        if (bytes[i] != value)
            return 0;
    return 1;
}

static int
bin_heap_probe(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops),
               UNUSED(int func))
{
    Heap shell_heap = new_heaps();
    int i, ok = 1;
    unsigned char *outer = zhalloc(128);
    memset(outer, 'a', 128);
    for (i = 0; i < 32; ++i) {
        Heap parent = new_heaps();
        unsigned char *child = zhalloc(256);
        unsigned char *blocks[3];
        int j;
        char *large;
        Heap suspended;
        memset(child, i, 256);
        pushheap();
        memset(zhalloc(15000), 'x', 15000);
        freeheap();
        memset(zhalloc(7000), 'y', 7000);
        popheap();
        suspended = switch_heaps(parent);
        ok &= filled(outer, 128, 'a');
        parent = switch_heaps(suspended);
        ok &= filled(child, 256, i);
        large = zhalloc(20000);
        memset(large, 'z', 20000);
        large = hrealloc(large, 20000, 70000);
        ok &= filled((unsigned char *)large, 20000, 'z');
        memset(large, 'q', 70000);
        ok &= hrealloc(large, 70000, 0) == NULL;
        /* End the scope with more standard arenas than the shell retains. */
        for (j = 0; j < 3; ++j) {
            blocks[j] = zhalloc(12000);
            memset(blocks[j], i + j + 1, 12000);
        }
        for (j = 0; j < 3; ++j)
            ok &= filled(blocks[j], 12000, i + j + 1);
        ok &= filled(child, 256, i);
        old_heaps(parent);
    }
    ok &= filled(outer, 128, 'a');
    old_heaps(shell_heap);
    return !ok;
}

static struct builtin builtins[] = {
    BUILTIN("heap-probe", 0, bin_heap_probe, 0, 0, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
