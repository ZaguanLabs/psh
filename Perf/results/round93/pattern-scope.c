/* Check each return against an independent snapshot of the public flag array. */
#include "zsh.mdh"

static int
nested(int levels, unsigned int *checks)
{
    int mask, local, i, failures = 0;
    char saved[ZPC_COUNT], expected[ZPC_COUNT];

    for (mask = 0; mask < 4; ++mask) {
	for (local = 0; local <= 1; ++local) {
	    for (i = 0; i < ZPC_COUNT; ++i)
		zpc_disables[i] = (mask & (1 << (i % 2))) ? 3 : 0;
	    memcpy(saved, zpc_disables, sizeof(saved));
	    startpatternscope();
	    if (levels > 1)
		failures += nested(levels - 1, checks);
	    for (i = 0; i < ZPC_COUNT; ++i) {
		zpc_disables[i] = i % 3 ? 0 : 7;
		expected[i] = local ? !!saved[i] : zpc_disables[i];
	    }
	    opts[LOCALPATTERNS] = local;
	    endpatternscope();
	    failures += memcmp(expected, zpc_disables, sizeof(expected)) != 0;
	    ++*checks;
	}
    }
    return failures;
}

static int
probe(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    char original[ZPC_COUNT];
    int local = opts[LOCALPATTERNS], failures;
    unsigned int checks = 0;

    queue_signals();
    memcpy(original, zpc_disables, sizeof(original));
    failures = nested(4, &checks);
    memcpy(zpc_disables, original, sizeof(original));
    opts[LOCALPATTERNS] = local;
    unqueue_signals();
    printf("%u pattern scope restores, %d mismatches\n", checks, failures);
    return failures != 0;
}

static struct builtin builtins[] = {
    BUILTIN("pattern-scope-probe", 0, probe, 0, 0, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
