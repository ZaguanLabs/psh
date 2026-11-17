/* Minimal native-module reproducer. Compile against the tested Zsh's headers. */
#include "zsh.mdh"

static int getter_calls;

static char *
nested_get(Param pm)
{
    getter_calls++;
    (void)gethparam("reentry_inner");
    return strgetfn(pm);
}

static const struct gsu_scalar nested_gsu = {
    nested_get, strsetfn, stdunsetfn
};

static int
outer_values(char **values)
{
    return values && arrlen(values) == 2 &&
        ((!strcmp(values[0], "A") && !strcmp(values[1], "B")) ||
         (!strcmp(values[0], "B") && !strcmp(values[1], "A")));
}

static void
show_values(const char *label, char **values)
{
    printf("%s:", label);
    if (values)
        for (; *values; values++)
            printf(" %s", *values);
    putchar('\n');
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args),
          UNUSED(Options ops), UNUSED(int func))
{
    Param outer, member;
    const struct gsu_scalar *saved_gsu;
    char **values;
    int ok;

    outer = (Param)paramtab->getnode(paramtab, "reentry_outer");
    if (!outer || PM_TYPE(outer->node.flags) != PM_HASHED)
        return 2;
    member = (Param)outer->u.hash->getnode(outer->u.hash, "a");
    if (!member || PM_TYPE(member->node.flags) != PM_SCALAR)
        return 2;
    values = gethparam("reentry_outer");
    show_values("before", values);
    if (!outer_values(values))
        return 2;

    saved_gsu = member->gsu.s;
    member->gsu.s = &nested_gsu;
    getter_calls = 0;
    values = gethparam("reentry_outer");
    member->gsu.s = saved_gsu;

    show_values("after", values);
    printf("getter calls: %d\n", getter_calls);
    ok = outer_values(values) && getter_calls == 1;
    /* Show that the ordinary parameter contents themselves were not changed. */
    printf("stored a: %s\n", strgetfn(member));
    member = (Param)outer->u.hash->getnode(outer->u.hash, "b");
    printf("stored b: %s\n", strgetfn(member));
    printf("result: %s\n", ok ? "PASS" : "FAIL");
    return !ok;
}

static struct builtin builtins[] = {
    BUILTIN("hash-reentry-check", 0, bin_check, 0, 0, 0, NULL, NULL)
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
