/* Independent native capabilities, constructor suspension and queued traps. */
#include "zsh.mdh"
#include <locale.h>

static int constructor_tracking;
static locale_t original_thread;
static char numeric_name[256];

__attribute__((constructor)) static void
constructor(void)
{
    constructor_tracking = psh_float_locale_tracking();
}

static int
bin_probe(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int expected = atoi(args[0]);
    char *scope = strchr(args[0], ':');
    if (constructor_tracking || psh_float_locale_tracking() != expected)
        return 1;
    if (scope && psh_scope_tracking() != atoi(scope + 1))
        return 6;
    if (args[1] && !strcmp(args[1], "signal")) {
        original_thread = uselocale((locale_t)0);
        strcpy(numeric_name, setlocale(LC_NUMERIC, NULL));
        queue_signals();
        kill(getpid(), SIGUSR1);
        pushheap();
        if (strcmp(convfloat(1.25, 4, PM_FFLOAT, NULL), "1.2500"))
            return 2;
        popheap();
        if (uselocale((locale_t)0) != original_thread ||
            strcmp(setlocale(LC_NUMERIC, NULL), numeric_name))
            return 3;
        unqueue_signals();
    } else if (args[1] && !strcmp(args[1], "trap")) {
        if (uselocale((locale_t)0) != original_thread ||
            strcmp(setlocale(LC_NUMERIC, NULL), numeric_name))
            return 4;
    } else if (args[1] && !strcmp(args[1], "disable")) {
        psh_float_locale_disable();
        if (psh_float_locale_tracking())
            return 5;
    }
    return 0;
}

static struct builtin bintab[]={BUILTIN("psh-float-policy-check",0,bin_probe,1,2,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(Module m) {
#ifdef FIXTURE_SCOPE
    psh_scope_module_ack(m);
#endif
#ifdef FIXTURE_FLOAT
    psh_float_module_ack(m);
#endif
#ifdef FIXTURE_FAIL
    return 1;
#else
    return 0;
#endif
}
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
