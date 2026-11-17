/* glibc-only diagnostic; never linked into the interpreter or installed.
 * Compile separately against each tested shell's matching SDK. */
#include "zsh.mdh"
#include <malloc.h>

static int
bin_trim(UNUSED(char *name), UNUSED(char **args),
         UNUSED(Options ops), UNUSED(int func))
{
    /* A zero return means no pages released, not a fixture failure. */
    (void)malloc_trim(0);
    return 0;
}

static struct builtin builtins[] = {
    BUILTIN("memory-trim-probe", 0, bin_trim, 0, 0, 0, NULL, NULL)
};
static struct features features = {
    builtins, 1, NULL, 0, NULL, 0, NULL, 0, 0
};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
