/* Native float-formatting oracle: output, callbacks, FP/locale and queue state. */
#include "zsh.mdh"
#include <dlfcn.h>
#include <fenv.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include "convfloat-reference.h"

struct observation {
    char text[4096];
    int error, exceptions, rounding, queue, global_ok, thread_ok, callback_ok;
    unsigned callbacks;
};

struct cookie {
    char text[4096];
    size_t used;
    int actual, recurse, busy, ok;
    unsigned calls;
};

static char *global_name, *posix_numeric;
static char inner_expected[128];
static locale_t expected_thread;
static unsigned checks;
static uint64_t digest;
static int fault_mode;
static void (*set_fault)(int);
static unsigned long (*get_faults)(void);

static void
mix(uint64_t value)
{
    digest = digest * UINT64_C(1099511628211) + value;
}

static ssize_t
write_cookie(void *opaque, const char *bytes, size_t count)
{
    struct cookie *cookie = opaque;
    char *inner;
    cookie->calls++;
    if (strcmp(setlocale(LC_NUMERIC, NULL), posix_numeric) ||
        uselocale((locale_t)0) != expected_thread)
        cookie->ok = 0;
    if (cookie->recurse && !cookie->busy) {
        cookie->busy = 1;
        inner = cookie->actual ? convfloat(1.25, 4, PM_FFLOAT, NULL) :
            reference_convfloat(1.25, 4, PM_FFLOAT, NULL);
        if (strcmp(inner, inner_expected) ||
            strcmp(setlocale(LC_NUMERIC, NULL), posix_numeric) ||
            uselocale((locale_t)0) != expected_thread)
            cookie->ok = 0;
        cookie->busy = 0;
    }
    if (count >= sizeof(cookie->text) - cookie->used) {
        cookie->ok = 0;
        return -1;
    }
    memcpy(cookie->text + cookie->used, bytes, count);
    cookie->used += count;
    cookie->text[cookie->used] = 0;
    return count;
}

static int
observe(struct observation *out, int actual, double value, int digits,
        int flags, int output, int seed)
{
    struct cookie cookie;
    cookie_io_functions_t io;
    FILE *file = NULL;
    char *text;
    memset(&cookie, 0, sizeof(cookie));
    memset(&io, 0, sizeof(io));
    memset(out, 0, sizeof(*out));
    cookie.ok = 1;
    cookie.actual = actual;
    cookie.recurse = output == 2;
    if (output) {
        io.write = write_cookie;
        file = fopencookie(&cookie, "w", io);
        if (!file || setvbuf(file, NULL, _IONBF, 0))
            return 1;
    }
    pushheap();
    if (set_fault) set_fault(fault_mode);
    feclearexcept(FE_ALL_EXCEPT);
    if (seed) feraiseexcept(FE_DIVBYZERO);
    errno = seed ? E2BIG : 0;
    text = actual ? convfloat(value, digits, flags, file) :
        reference_convfloat(value, digits, flags, file);
    out->error = errno;
    out->exceptions = fetestexcept(FE_ALL_EXCEPT);
    out->rounding = fegetround();
    out->queue = queue_signal_level();
    if (set_fault) set_fault(0);
    out->global_ok = !strcmp(setlocale(LC_ALL, NULL), global_name);
    out->thread_ok = uselocale((locale_t)0) == expected_thread;
    out->callback_ok = cookie.ok;
    out->callbacks = cookie.calls;
    if ((output && text) || (!output && !text)) {
        if (file) fclose(file);
        popheap();
        return 1;
    }
    if (output) text = cookie.text;
    if (strlen(text) >= sizeof(out->text)) {
        if (file) fclose(file);
        popheap();
        return 1;
    }
    strcpy(out->text, text);
    if (file) fclose(file);
    popheap();
    return 0;
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const uint64_t values[] = {
        UINT64_C(0), UINT64_C(0x8000000000000000), UINT64_C(0x3ff4000000000000),
        UINT64_C(0x7fefffffffffffff), UINT64_C(1), UINT64_C(0x7ff8000000000001),
        UINT64_C(0x7ff0000000000001), UINT64_C(0x7ff0000000000000),
        UINT64_C(0xfff0000000000000), UINT64_C(0xbff4000000000000),
        UINT64_C(0x0010000000000000), UINT64_C(0x000fffffffffffff),
        UINT64_C(0x4340000000000001), UINT64_C(0x3fb999999999999a),
        UINT64_C(0xc0875038e38e38e4), UINT64_C(0x123456789abcdef0),
        UINT64_C(0xfff8000000000001), UINT64_C(0xffefffffffffffff),
        UINT64_C(0x8000000000000001), UINT64_C(0x3fefffffffffffff)
    };
    static const int precisions[] = {-3, 0, 1, 2, 8, 17, 32, 128, 1024};
    static const int quick_precisions[] = {-3, 0, 8, 17, 1024};
    static const int flag_sets[] = {0, PM_EFLOAT, PM_FFLOAT, PM_EFLOAT | PM_FFLOAT};
    static const int rounds[] = {FE_TONEAREST, FE_DOWNWARD, FE_UPWARD, FE_TOWARDZERO};
    static const int levels[] = {0, 1, 3};
    unsigned i, j, k, r, q, output, seed, byte;
    unsigned nvalues, nprecisions, nrounds, nlevels;
    int quick = !strcmp(args[1], "quick"), failed = 0, saved_errno = errno;
    int saved_error = errflag, queued = 0;
    locale_t original = uselocale((locale_t)0), private_locale = (locale_t)0;
    fenv_t environment;
    char *numeric;
    double value;
    struct observation reference, actual;
    if (sizeof(value) != sizeof(values[0]) || queue_signal_level()) {
        fprintf(stderr, "fixture requires IEEE binary64 and an unqueued builtin entry\n");
        return 1;
    }
    fegetenv(&environment);
    if (strcmp(args[0], "global")) {
        private_locale = newlocale(LC_ALL_MASK, args[0], (locale_t)0);
        if (!private_locale || !uselocale(private_locale)) return 1;
    }
    expected_thread = uselocale((locale_t)0);
    global_name = ztrdup(setlocale(LC_ALL, NULL));
    numeric = ztrdup(setlocale(LC_NUMERIC, NULL));
    setlocale(LC_NUMERIC, "POSIX");
    posix_numeric = ztrdup(setlocale(LC_NUMERIC, NULL));
    setlocale(LC_NUMERIC, numeric);
    zsfree(numeric);
    pushheap();
    strcpy(inner_expected, reference_convfloat(1.25, 4, PM_FFLOAT, NULL));
    popheap();
    checks = 0;
    digest = 0;
    nvalues = quick ? 10 : sizeof(values)/sizeof(values[0]);
    nprecisions = quick ? sizeof(quick_precisions)/sizeof(quick_precisions[0]) :
        sizeof(precisions)/sizeof(precisions[0]);
    nrounds = quick ? 2 : 4;
    nlevels = quick ? 2 : 3;
    for (r=0; r<nrounds && !failed; r++) {
        if (fesetround(rounds[r])) { failed=1; break; }
        for (q=0; q<nlevels && !failed; q++) {
            for (queued=0; queued<levels[q]; queued++) queue_signals();
            for (i=0; i<nvalues && !failed; i++)
            for (j=0; j<nprecisions && !failed; j++)
            for (k=0; k<4 && !failed; k++)
            for (output=0; output<3 && !failed; output++)
            for (seed=0; seed<2 && !failed; seed++) {
                int digits = quick ? quick_precisions[j] : precisions[j];
                memcpy(&value, values+i, sizeof(value));
                if (observe(&reference, 0, value, digits, flag_sets[k], output, seed) ||
                    observe(&actual, 1, value, digits, flag_sets[k], output, seed) ||
                    memcmp(&reference, &actual, sizeof(reference)) ||
                    !actual.global_ok || !actual.thread_ok || !actual.callback_ok ||
                    actual.queue != levels[q]) {
                    fprintf(stderr, "format mismatch value=%u digits=%d flags=%d output=%u seed=%u queue=%d: text=%s/%s errno=%d/%d exceptions=%d/%d callbacks=%u/%u\n",
                            i,digits,flag_sets[k],output,seed,levels[q],actual.text,reference.text,
                            actual.error,reference.error,actual.exceptions,reference.exceptions,
                            actual.callbacks,reference.callbacks);
                    failed=1; break;
                }
                checks++;
                for (byte=0; actual.text[byte]; byte++) mix((unsigned char)actual.text[byte]);
                mix(actual.error); mix(actual.exceptions); mix(actual.callbacks);
                mix(actual.queue); mix(actual.rounding);
            }
            for (queued=0; queued<levels[q]; queued++) unqueue_signals();
        }
    }
    if (set_fault) set_fault(0);
    zsfree(global_name); zsfree(posix_numeric);
    uselocale(original);
    if (private_locale) freelocale(private_locale);
    fesetenv(&environment); errno=saved_errno; errflag=saved_error;
    if (failed) return 1;
    printf("checks=%u digest=%" PRIu64 " faults=%lu\n",checks,digest,get_faults ? get_faults() : 0);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[]={BUILTIN("psh-float-output-check",0,bin_check,2,2,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(Module m) {
    const char *mode=getenv("PSH_PRINTF_FAULT");
    set_fault=(void (*)(int))dlsym(RTLD_DEFAULT,"psh_printf_set_fault");
    get_faults=(unsigned long (*)(void))dlsym(RTLD_DEFAULT,"psh_printf_faults");
    fault_mode=mode && !strcmp(mode,"newlocale") ? 1 : mode && !strcmp(mode,"enter") ? 2 : 0;
    if (fault_mode && (!set_fault || !get_faults)) return 1;
#ifdef PSH_SCOPE_INDEX_VERSION
    psh_scope_module_ack(m);
#endif
#ifdef PSH_FLOAT_LOCALE_VERSION
    psh_float_module_ack(m);
#endif
    return 0;
}
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
