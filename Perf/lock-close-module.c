/* Test-only direct caller of the exported lock-descriptor helper. */
#include "zsh.mdh"

static int
bin_lockclose(UNUSED(char *name), char **args, UNUSED(Options ops),
              UNUSED(int func))
{
    char *end;
    long parsed = strtol(args[0], &end, 10);
    int result, saved;

    if (*end || parsed < INT_MIN || parsed > INT_MAX)
        return 1;
    errno = EDOM;
    result = zcloselockfd((int)parsed);
    saved = errno;
    printf("%d:%d\n", result, saved == EDOM);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-test-lockclose", 0, bin_lockclose, 1, 1, 0, NULL, NULL)
};
static struct features features = {bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0};
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
