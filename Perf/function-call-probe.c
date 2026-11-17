/* Model a native caller making repeated callbacks within one shell heap. */
#include "zsh.mdh"

static int
bin_callbacks(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int i;
    for (i = 0; i < 4096; i++) {
        Shfunc shfunc = getshfunc(args[0]);
        if (!shfunc || doshfunc(shfunc, NULL, 1))
            return 1;
    }
    return 0;
}

static struct builtin builtins[] = {
    BUILTIN("call-probe-repeat", 0, bin_callbacks, 1, 1, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
