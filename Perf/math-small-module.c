/* Test-only arithmetic token/state and input-boundary comparisons. */
#include "zsh.mdh"
#include <fenv.h>
#include <inttypes.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
/* Existing internal entry point, used only by this regression fixture. */
extern zlong mathevalarg(char *, char **);
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
static void one(char *text, size_t bytes, int api, int known) {
    mnumber value;
    char *end = NULL;
    unsigned char *before = zalloc(bytes);
    int saved_errno = errno, got_errno, exceptions;
    memcpy(before, text, bytes);
    pushheap();
    errflag = 0; lastbase = 17; outputradix = 8; outputunderscore = 4;
    lastmathval.type = MN_FLOAT; lastmathval.u.d = 2.5;
    feclearexcept(FE_ALL_EXCEPT); feraiseexcept(FE_INEXACT);
    errno = E2BIG;
    if (api) { value.type = MN_INTEGER; value.u.l = mathevalarg(text, &end); }
    else value = matheval(text);
    got_errno = errno; exceptions = fetestexcept(FE_ALL_EXCEPT);
    if (known && (errflag || (api ? value.u.l != known :
        (opts[FORCEFLOAT] ? value.type != MN_FLOAT || value.u.d != known :
         value.type != MN_INTEGER || value.u.l != known)))) bad = 1;
    if (memcmp(before, text, bytes)) bad = 1;
    number(value); mix(errflag); mix(got_errno); mix(exceptions);
    mix(lastbase); mix(outputradix); mix(outputunderscore); number(lastmathval);
    if (end) {
        uintptr_t begin = (uintptr_t)text, tail = (uintptr_t)end;
        if (tail >= begin && tail - begin < bytes) { mix(1); mix(tail - begin); }
        else { const unsigned char *p = (unsigned char *)end; mix(2); while (*p) mix(*p++); }
    } else mix(0);
    checks++; errflag = 0;
    popheap(); zfree(before, bytes); errno = saved_errno;
}
static void cases(const char *s, size_t n, int known, char *boundary) {
    unsigned offset, api;
    for (offset = 0; offset < 2 && !bad; offset++) {
        unsigned gap = offset ? 3 : 0;
        char *block = zalloc(n + gap + 1);
        memset(block, 0xa5, n + gap + 1); memcpy(block + gap, s, n); block[gap+n] = 0;
        for (api = 0; api < 2 && !bad; api++) one(block + gap, n + 1, api, known);
        zfree(block, n + gap + 1);
    }
    if (boundary && !bad) {
        char *p = boundary - n - 1;
        memcpy(p, s, n); p[n] = 0;
        for (api = 0; api < 2 && !bad; api++) one(p, n + 1, api, known);
    }
}
static int bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func)) {
    static const char *fixed[] = {"", "0", "1", "9", "10", "99", "01", "0x1", "0b1", "16#1",
        "1#0", "1_0", "1.0", "1e0", "1e+2", "-1", "+1", "-0.0", "1,2", "1?2:3",
        "0 && 1/0", "1 || 1/0", "1+2*3", "[#8_3]1", "[##16]1", "1234567890123456789", "9007199254740993", "999999999999999999",
        "9999999999999999999", "1 e0", "1x.25"};
    static const int rounds[] = {FE_TONEAREST, FE_DOWNWARD, FE_UPWARD, FE_TOWARDZERO};
    short classes[256]; char saved_opts[OPT_SIZE], text[8];
    int saved_err = errflag, saved_noerrs = noerrs, saved_errno = errno;
    int saved_base = lastbase, saved_radix = outputradix, saved_under = outputunderscore;
    mnumber saved_last = lastmathval; fenv_t env;
    unsigned r, option, mutation, digit, successor, tail, i;
    long page = sysconf(_SC_PAGESIZE); char *map;
    if (sizeof(double) != 8 || page < 4096) return 2;
    map = mmap(NULL, 2*page, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (map == MAP_FAILED) return 2;
    if (mprotect(map+page, page, PROT_NONE)) { munmap(map, 2*page); return 2; }
    memcpy(classes, typtab, sizeof(classes)); memcpy(saved_opts, opts, sizeof(saved_opts));
    fegetenv(&env); queue_signals(); noerrs = 1; checks = 0; digest = 0; bad = 0;
    for (r = 0; r < 4 && !bad; r++) {
        if (fesetround(rounds[r])) { bad = 1; break; }
        for (option = 0; option < 8 && !bad; option++) {
            opts[FORCEFLOAT] = !!(option & 1); opts[OCTALZEROES] = !!(option & 2);
            opts[CPRECEDENCES] = !!(option & 4);
            for (mutation = 0; mutation < 5 && !bad; mutation++) {
                memcpy(typtab, classes, sizeof(classes));
                if (mutation == 1) typtab['1'] |= IBLANK;
                if (mutation == 2) typtab['2'] &= ~IDIGIT;
                if (mutation == 3) typtab['x'] |= IDIGIT;
                if (mutation == 4) typtab[' '] |= IDIGIT;
                for (digit = 0; digit < 10 && !bad; digit++) {
                    text[0] = '0' + digit;
                    cases(text, 1, !mutation && digit ? digit : 0, map+page);
                    for (successor = 0; successor < 128 && !bad; successor++)
                    for (tail = 0; tail < 2 && !bad; tail++) {
                        text[1] = successor; text[2] = '2';
                        cases(text, tail ? 3 : 2, 0, NULL);
                    }
                }
                for (i = 0; i < sizeof(fixed)/sizeof(fixed[0]) && !bad; i++)
                    cases(fixed[i], strlen(fixed[i]), 0, map+page);
            }
        }
    }
    memcpy(typtab, classes, sizeof(classes)); memcpy(opts, saved_opts, sizeof(saved_opts));
    lastbase = saved_base; outputradix = saved_radix; outputunderscore = saved_under;
    lastmathval = saved_last; errflag = saved_err; noerrs = saved_noerrs;
    unqueue_signals(); fesetenv(&env); errno = saved_errno; munmap(map, 2*page);
    if (bad) { fprintf(stderr,"small-token fixture failed after %u checks\n", checks); return 1; }
    printf("checks=%u digest=%" PRIu64 "\nsmall-math-done\n", checks, digest); fflush(stdout);
    return 0;
}
static struct builtin bintab[] = {BUILTIN("psh-small-math-check",0,bin_check,0,0,0,NULL,NULL)};
static struct features features = {bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
