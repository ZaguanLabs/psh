/* Test-only integer-power oracle and arithmetic state comparisons. */
#include "zsh.mdh"
#include <fenv.h>
#include <inttypes.h>
#include <stdint.h>
#include <math.h>

extern int lastbase, outputradix, outputunderscore;
extern mnumber lastmathval;
static unsigned checks;
static uint64_t digest;
static int bad;
static void mix(uint64_t x) { digest = digest * UINT64_C(1099511628211) + x; }
static void number(mnumber x) {
    uint64_t bits = 0;
    mix(x.type);
    if (x.type == MN_FLOAT) memcpy(&bits, &x.u.d, sizeof(bits));
    else if (x.type == MN_INTEGER) bits = (uint64_t)x.u.l;
    mix(bits);
}
static mnumber readparam(Param p) {
    mnumber n;
    if (PM_TYPE(p->node.flags) == PM_INTEGER) {
        n.type = MN_INTEGER; n.u.l = p->gsu.i->getfn(p);
    } else {
        n.type = MN_FLOAT; n.u.d = p->gsu.f->getfn(p);
    }
    return n;
}
static void writeparam(Param p, zlong integer, double real) {
    if (PM_TYPE(p->node.flags) == PM_INTEGER) p->gsu.i->setfn(p, integer);
    else p->gsu.f->setfn(p, real);
}
static void one(Param base, Param exponent, zlong a, zlong e,
                double fa, double fe, int assign, int oracle, zulong expected) {
    char text[128], before[128];
    mnumber value;
    int got_errno, exceptions;
    writeparam(base, a, fa); writeparam(exponent, e, fe);
    snprintf(text, sizeof(text), "psh_native_power_base %s psh_native_power_exp",
             assign ? "**=" : "**");
    strcpy(before, text);
    pushheap();
    errflag = 0; lastbase = 17; outputradix = 8; outputunderscore = 4;
    lastmathval.type = MN_FLOAT; lastmathval.u.d = 2.5;
    feclearexcept(FE_ALL_EXCEPT); feraiseexcept(FE_INEXACT); errno = E2BIG;
    value = matheval(text);
    got_errno = errno; exceptions = fetestexcept(FE_ALL_EXCEPT);
    if (strcmp(text, before)) bad = 1;
    if (oracle && (errflag || value.type != MN_INTEGER || (zulong)value.u.l != expected))
        bad = 1;
    number(value); mix(errflag); mix(got_errno); mix(exceptions);
    number(readparam(base)); number(readparam(exponent));
    mix(lastbase); mix(outputradix); mix(outputunderscore); number(lastmathval);
    checks++; errflag = 0; popheap();
}
static int run(int huge) {
    static const zlong bases[] = {0,1,-1,2,-2,3,-3,7,-7,16,-16,46340,-46340,
        ZLONG_MAX,-ZLONG_MAX,(-ZLONG_MAX-1),(-ZLONG_MAX-1)+1};
    static const zlong exponents[] = {-2,-1,0,1,2,3,4,7,8,15,16,31,32,63,64,65,127,128,255,256,1024};
    static const int rounds[] = {FE_TONEAREST,FE_DOWNWARD,FE_UPWARD,FE_TOWARDZERO};
    static const double reals[] = {0.0,-0.0,0.5,-0.5,1.0,-1.0,1.25,-1.25};
    static const double nonfinite[] = {0.0,-0.0,INFINITY,-INFINITY,NAN};
    char saved_opts[OPT_SIZE];
    int saved_err = errflag, saved_noerrs = noerrs, saved_errno = errno;
    int saved_base = lastbase, saved_radix = outputradix, saved_under = outputunderscore;
    mnumber saved_last = lastmathval; fenv_t env;
    unsigned r, option, types, i, j, op;
    Param base = NULL, exponent = NULL;
    uint64_t random = UINT64_C(0x129ab78901);
    if (sizeof(double) != 8 || sizeof(zlong) != sizeof(zulong)) return 2;
    memcpy(saved_opts, opts, sizeof(saved_opts)); fegetenv(&env);
    queue_signals(); noerrs = 1; checks = 0; digest = 0; bad = 0;
    for (r = 0; r < 4 && !bad; r++) {
        if (fesetround(rounds[r])) { bad = 1; break; }
        for (option = 0; option < (huge ? 1U : 4U) && !bad; option++) {
            opts[FORCEFLOAT] = !!(option & 1); opts[CPRECEDENCES] = !!(option & 2);
            for (types = 0; types < (huge ? 1U : 4U) && !bad; types++) {
                base = createparam("psh_native_power_base", (types & 1) ? PM_FFLOAT : PM_INTEGER);
                exponent = createparam("psh_native_power_exp", (types & 2) ? PM_FFLOAT : PM_INTEGER);
                if (!base || !exponent) { bad = 1; break; }
                if (huge) {
                    zlong large[] = {ZLONG_MAX,ZLONG_MAX-1,ZLONG_MAX/2,
                        ((zlong)1 << (sizeof(zlong)*8-2))};
                    for (i = 0; i < 5; i++) for (j = 0; j < 4; j++)
                    for (op = 0; op < 2; op++) {
                        zlong a = bases[i], e = large[j];
                        zulong expected = a == 1 ? 1 : (a == -1 ?
                            ((e & 1) ? (zulong)-1 : 1) : 0);
                        one(base,exponent,a,e,0,0,op,1,expected);
                    }
                } else {
                    for (i = 0; i < sizeof(bases)/sizeof(bases[0]) && !bad; i++)
                    for (j = 0; j < sizeof(exponents)/sizeof(exponents[0]) && !bad; j++) {
                        zlong a = bases[i], e = exponents[j];
                        zulong expected = 1; zlong k;
                        if (!types && !(option & 1) && e >= 0)
                            for (k = 0; k < e; k++) expected *= (zulong)a;
                        for (op = 0; op < 2; op++)
                            one(base,exponent,a,e,(double)a,(double)e,op,
                                !types && !(option & 1) && e >= 0,expected);
                    }
                    if (types) {
                        for (i = 0; i < sizeof(reals)/sizeof(reals[0]); i++)
                        for (j = 0; j < sizeof(reals)/sizeof(reals[0]); j++)
                        for (op = 0; op < 2; op++)
                            one(base,exponent,(zlong)reals[i],(zlong)reals[j],
                                reals[i],reals[j],op,0,0);
                        if (types == 3)
                            for (i = 0; i < sizeof(nonfinite)/sizeof(nonfinite[0]); i++)
                            for (j = 0; j < sizeof(nonfinite)/sizeof(nonfinite[0]); j++)
                            for (op = 0; op < 2; op++)
                                one(base,exponent,0,0,nonfinite[i],nonfinite[j],op,0,0);
                    } else if (!(option & 1)) {
                        for (i = 0; i < 512 && !bad; i++) {
                            zulong bits, expected = 1; zlong a, e, k;
                            random = random * UINT64_C(6364136223846793005) + 1;
                            bits = (zulong)random; memcpy(&a,&bits,sizeof(a));
                            e = (random >> 32) & 127;
                            for (k = 0; k < e; k++) expected *= bits;
                            for (op = 0; op < 2; op++) one(base,exponent,a,e,0,0,op,1,expected);
                        }
                    }
                }
                unsetparam("psh_native_power_base"); unsetparam("psh_native_power_exp");
                base = exponent = NULL;
            }
        }
    }
    if (base) unsetparam("psh_native_power_base");
    if (exponent) unsetparam("psh_native_power_exp");
    memcpy(opts,saved_opts,sizeof(saved_opts)); lastbase=saved_base;
    outputradix=saved_radix; outputunderscore=saved_under; lastmathval=saved_last;
    errflag=saved_err; noerrs=saved_noerrs; fesetenv(&env); errno=saved_errno;
    unqueue_signals();
    if (bad) { fprintf(stderr,"power fixture failed after %u observations\n",checks); return 1; }
    printf("checks=%u digest=%" PRIu64 "\npower-done\n",checks,digest); fflush(stdout);
    return 0;
}
static int bin_common(UNUSED(char *n), UNUSED(char **a), UNUSED(Options o), UNUSED(int f)) { return run(0); }
static int bin_huge(UNUSED(char *n), UNUSED(char **a), UNUSED(Options o), UNUSED(int f)) { return run(1); }
static struct builtin bintab[] = {
    BUILTIN("psh-power-check",0,bin_common,0,0,0,NULL,NULL),
    BUILTIN("psh-power-huge-check",0,bin_huge,0,0,0,NULL,NULL)
};
static struct features features = {bintab,2,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
