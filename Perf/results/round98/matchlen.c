/* Read the last match length before another shell pattern can overwrite it. */
#include "zsh.mdh"

static int
matchlen(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    printf("%s %s %d\n", args[0], args[1], patmatchlen());
    return 0;
}

static struct builtin builtins[] = {
    BUILTIN("match-result", 0, matchlen, 2, 2, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
