/* Native lifetime tests, compiled against the preceding unmodified SDK. */
#include "zsh.mdh"

static char array_name[] = "psh_cache_array";
static char **loan;
static char *saved_tail;
static int cut_at;

static void
restore_loan(void)
{
    if (saved_tail) {
        loan[cut_at] = saved_tail;
        saved_tail = NULL;
    }
}

static int
bin_cache_fixture(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    Param pm = (Param)gethashnode2(paramtab, array_name);
    if (!strcmp(args[0], "init")) {
        char **value = (char **)zalloc(2049 * sizeof(char *));
        int i;
        restore_loan();
        for (i = 0; i < 1024; i++) value[i] = ztrdup("item");
        for (; i <= 2048; i++) value[i] = NULL;
        loan = NULL;
        return setaparam(array_name, value) ? 0 : 1;
    }
    if (!pm) return 2;
    if (!strcmp(args[0], "loan")) {
        if (!args[1]) return 2;
        if (!strcmp(args[1], "getaparam")) loan = getaparam(array_name);
        else if (!strcmp(args[1], "getter")) loan = pm->gsu.a->getfn(pm);
        /* Deliberate contract-bypass reproducer, never a supported loan. */
        else if (!strcmp(args[1], "raw")) loan = pm->u.arr;
        else if (!strcmp(args[1], "getarrvalue")) {
            struct value v;
            memset(&v, 0, sizeof(v));
            v.pm = pm;
            v.isarr = SCANPM_ARRONLY;
            v.end = -1;
            loan = getarrvalue(&v);
        } else return 2;
        return loan ? 0 : 1;
    }
    if (!strcmp(args[0], "same")) {
        int same = loan == pm->u.arr;
        printf("same_pointer=%d\n", same);
        fflush(stdout);
        return !same;
    }
    if (!strcmp(args[0], "same-set")) {
        if (!loan || loan != pm->u.arr) return 2;
        pm->gsu.a->setfn(pm, loan);
        return 0;
    }
    if (!strcmp(args[0], "cut")) {
        if (!loan || loan != pm->u.arr || saved_tail) return 2;
        cut_at = 3;
        saved_tail = loan[cut_at];
        loan[cut_at] = NULL;
        return 0;
    }
    if (!strcmp(args[0], "restore")) {
        if (!loan || loan != pm->u.arr) return 2;
        restore_loan();
        return 0;
    }
    return 2;
}

static struct builtin bintab[] = {
    BUILTIN("psh-cache-fixture", 0, bin_cache_fixture, 1, 2, 0, NULL, NULL)
};
static struct features module_features = { bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) {
    *features = featuresarray(m, &module_features); return 0;
}
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) {
    restore_loan(); loan = NULL; unsetparam(array_name);
    return setfeatureenables(m, &module_features, NULL);
}
int finish_(UNUSED(Module m)) { return 0; }
