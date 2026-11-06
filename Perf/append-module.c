/* Test-only native module: exercise custom array accessors and the public API.
 * Build against pristine configured headers; load only in isolated test shells. */
#include "zsh.mdh"

static char fixture_name[] = "psh_fixture_array";
static char *short_view[] = { "first", NULL };
static int mode, getter_calls, setter_calls;

static char **
fixture_get(Param pm)
{
    getter_calls++;
    if (getter_calls == 1 && (mode == 1 || mode == 2)) {
        if (mode == 2)
            pm->gsu.a = &stdarray_gsu;
        return short_view;
    }
    return arrgetfn(pm);
}

static void
fixture_set(Param pm, char **value)
{
    setter_calls++;
    arrsetfn(pm, value);
}

static const struct gsu_array fixture_gsu =
    { fixture_get, fixture_set, stdunsetfn };
static const struct gsu_array custom_setter_gsu =
    { arrgetfn, fixture_set, stdunsetfn };

static int
bin_fixture(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    Param pm;
    char *initial[] = { "a", "b", "c", NULL };
    if (!strcmp(args[0], "report")) {
        char **p;
        pm = (Param)gethashnode2(paramtab, fixture_name);
        if (!pm)
            return 1;
        printf("gets=%d sets=%d values=", getter_calls, setter_calls);
        for (p = pm->u.arr; p && *p; p++)
            printf("[%s]", *p);
        putchar('\n');
        fflush(stdout);
        return 0;
    }
    if (!strcmp(args[0], "stable")) mode = 0;
    else if (!strcmp(args[0], "changing")) mode = 1;
    else if (!strcmp(args[0], "self-replacing")) mode = 2;
    else if (!strcmp(args[0], "custom-setter")) mode = 3;
    else if (!strcmp(args[0], "public-api")) mode = 4;
    else return 2;

    unsetparam(fixture_name);
    pm = createparam(fixture_name, PM_ARRAY);
    if (!pm)
        return 1;
    arrsetfn(pm, zarrdup(initial));
    pm->node.flags &= ~PM_UNSET;
    pm->gsu.a = mode == 3 ? &custom_setter_gsu : &fixture_gsu;
    getter_calls = setter_calls = 0;
    if (mode == 4) {
        struct value v;
        char *replacement[] = { "api", NULL };
        memset(&v, 0, sizeof(v));
        v.pm = pm;
        v.start = 1;
        v.end = 2;
        setarrvalue(&v, zarrdup(replacement));
    }
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-array-fixture", 0, bin_fixture, 1, 1, 0, NULL, NULL)
};
static struct features module_features = {
    bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0
};

int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) {
    *features = featuresarray(m, &module_features);
    return 0;
}
int enables_(Module m, int **enables) {
    return handlefeatures(m, &module_features, enables);
}
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) {
    unsetparam(fixture_name);
    return setfeatureenables(m, &module_features, NULL);
}
int finish_(UNUSED(Module m)) { return 0; }
