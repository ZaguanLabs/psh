/* Compare supported mutable loans and custom accessor calls across shift. */
#include "zsh.mdh"
#include <stdint.h>
static char array_name[] = "probe_array";
static uintptr_t borrowed;
static const struct gsu_array *original;
static int reads, writes;

static char **observe_get(Param pm)
{
    reads++;
    return original->getfn(pm);
}
static void observe_set(Param pm, char **value)
{
    writes++;
    original->setfn(pm, value);
}
static const struct gsu_array observer = {observe_get, observe_set, stdunsetfn};

static int
bin_probe(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    Param pm = (Param)gethashnode2(paramtab, array_name);
    if (!pm || PM_TYPE(pm->node.flags) != PM_ARRAY)
        return 1;
    if (!strcmp(*args, "queue")) {
        Builtin shift = (Builtin)builtintab->getnode(builtintab, "shift");
        struct options flags = {{0}, NULL, 0, 0};
        char *names[] = {array_name, NULL};
        int depth = queue_signal_level();
        if (!shift || shift->handlerfunc("shift", names, &flags, shift->funcid))
            return 1;
        printf("queue delta=%d\n", queue_signal_level() - depth);
        return queue_signal_level() != depth;
    }
    if (!strcmp(*args, "loan")) {
        char **value = getaparam(array_name);
        if (!value || arrlen(value) != 3)
            return 1;
        borrowed = (uintptr_t)value[1];
        return 0;
    }
    if (!strcmp(*args, "check-copy")) {
        char **value = getaparam(array_name);
        return !value || !*value || !borrowed || (uintptr_t)*value == borrowed;
    }
    if (!strcmp(*args, "wrap") && !original) {
        original = pm->gsu.a;
        pm->gsu.a = &observer;
        reads = writes = 0;
        return 0;
    }
    if (!strcmp(*args, "unwrap") && pm->gsu.a == &observer) {
        pm->gsu.a = original;
        original = NULL;
        printf("getter=%d setter=%d\n", reads, writes);
        return reads != 2 || writes != 1;
    }
    return 1;
}
static struct builtin builtins[] = { BUILTIN("shift-probe", 0, bin_probe, 1, 1, 0, NULL, NULL) };
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) {
    Param pm = (Param)gethashnode2(paramtab, array_name);
    if (original && pm && pm->gsu.a == &observer)
        pm->gsu.a = original;
    original = NULL;
    return setfeatureenables(m, &features, NULL);
}
int finish_(UNUSED(Module m)) { return 0; }
