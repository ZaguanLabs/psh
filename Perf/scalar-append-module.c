/* Exercise the legacy native scalar interface; no psh SDK extensions. */
#include "zsh.mdh"
#include <limits.h>

static int gets, sets;

static char *
count_get(Param pm)
{
    gets++;
    return strgetfn(pm);
}

static void
count_set(Param pm, char *value)
{
    sets++;
    strsetfn(pm, value);
}

static const struct gsu_scalar counted = {count_get, count_set, stdunsetfn};

static int
bin_check(UNUSED(char *name), UNUSED(char **args),
          UNUSED(Options ops), UNUSED(int func))
{
    int mode, i, saved_queue = queue_signal_level(), failed = 0;
    for (mode = 0; mode < 3; mode++) {
        Param pm = setsparam("psh_append_fixture_value", ztrdup("abcdef"));
        char *borrowed = getsparam("psh_append_fixture_value");
        borrowed[2] = 'X'; /* An outstanding native loan may edit its bytes. */
        gets = sets = 0;
        if (mode == 2)
            pm->gsu.s = &counted;
        for (i = 0; i < 64; i++) {
            struct value value;
            char *ref = "psh_append_fixture_value";
            char *expected = zalloc(7 + i + 1);
            memset(expected, '!', 6 + i + 1);
            memcpy(expected, "abXdef", 6);
            expected[6 + i + 1] = 0;
            if (!getvalue(&value, &ref, 1)) {
                zsfree(expected); failed = 1; break;
            }
            value.start = value.end = INT_MAX;
            /* Public setstrvalue() also supports callers with no queue. */
            restore_queue_signals(mode == 0 ? 0 : saved_queue + 1);
            setstrvalue(&value, ztrdup("!"));
            restore_queue_signals(saved_queue);
            if (strcmp(pm->u.str, expected) || errflag)
                failed = 1;
            zsfree(expected);
            if (failed)
                break;
        }
        if (mode == 2 && (gets != 64 || sets != 64))
            failed = 1;
        printf("mode=%d length=%lu gets=%d sets=%d failed=%d\n",
               mode, (unsigned long)strlen(pm->u.str), gets, sets, failed);
        pm->gsu.s = &stdscalar_gsu;
        unsetparam("psh_append_fixture_value");
        if (failed)
            break;
    }
    fflush(stdout);
    return failed;
}

static struct builtin bintab[] = {
    BUILTIN("psh-scalar-append-check",0,bin_check,0,0,0,NULL,NULL)
};
static struct features features = {bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
