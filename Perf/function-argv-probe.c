/* Linux/glibc diagnostic for the current function's positional argument vector. */
#include "zsh.mdh"
#include <malloc.h>

static int
bin_argv_storage(UNUSED(char *name), UNUSED(char **args),
                 UNUSED(Options ops), UNUSED(int func))
{
    printf("%d %zu\n", arrlen(pparams), malloc_usable_size(pparams));
    return 0;
}

static struct builtin builtins[] = {
    BUILTIN("argv-storage", 0, bin_argv_storage, 0, 0, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
