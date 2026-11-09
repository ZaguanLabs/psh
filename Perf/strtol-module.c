/* Test-only conversion API fixture; compile against the configured host SDK. */
#include "zsh.mdh"
#include <errno.h>
#include <limits.h>
#include "strtol-reference.c"

static unsigned checks;
static int use_reference;

static void
one(const char *source, int base, int underscore)
{
    unsigned offset, with_end, seed;
    size_t n = strlen(source);
    for (offset = 0; offset < 2; offset++) {
        char *allocation = zalloc(offset + n + 1), *s = allocation + offset;
        char *before = zalloc(offset + n + 1);
        memset(allocation, 0xa5, offset + n + 1);
        memcpy(s, source, n + 1);
        memcpy(before, allocation, offset + n + 1);
        for (with_end = 0; with_end < 2; with_end++)
            for (seed = 0; seed < 2; seed++) {
                char *end = NULL;
                zlong value;
                int saved_error;
                errflag = 0;
                errno = seed ? E2BIG : 0;
                value = use_reference ?
                    reference_zstrtol_underscore(s, with_end ? &end : NULL, base, underscore) :
                    zstrtol_underscore(s, with_end ? &end : NULL, base, underscore);
                saved_error = errno;
                printf("%u:%lld:%ld:%d:%d\n", ++checks, (long long)value,
                       end ? (long)(end - s) : -1L, errflag, saved_error);
                errflag = 0;
                if (memcmp(before, allocation, offset + n + 1)) {
                    fprintf(stderr, "fixture input changed\n");
                    exit(91);
                }
            }
        zfree(before, offset + n + 1);
        zfree(allocation, offset + n + 1);
    }
}

static void
buffer(const char *s)
{
    static const int bases[] = {0, 2, 8, 10, 16, 36, -1, 1, 37, INT_MIN, INT_MAX};
    static const int underscores[] = {0, 1, -7};
    unsigned b, u;
    for (b = 0; b < sizeof(bases)/sizeof(bases[0]); b++)
        for (u = 0; u < sizeof(underscores)/sizeof(underscores[0]); u++)
            one(s, bases[b], underscores[u]);
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const char *const atoms[] = {
        "", "0", "1", "9", "10", "99", "12345678", "123456789", "1234567890",
        "999999999", "1000000000", "_1", "1_", "1__2", "_", "__", "1.25", "1e2",
        "1#10", "09", "0x10", "0XfF", "0b10", "0B11", "00000000000000000001",
        "+1", "-1", " 1", "\t1", "\n1", "\r1", "  +17", " -0x10", "-0",
        "2147483647", "2147483648", "-2147483648", "-2147483649",
        "9223372036854775807", "9223372036854775808", "-9223372036854775808",
        "-9223372036854775809", "18446744073709551615", "18446744073709551616",
        "18446744073709551620", "1_234_567_890", "1___________________2",
        "abcdefghijklmnopqrstuvwxyz", "0aZ", "777777777777777777777777777",
        "\233" "1", "\203" "9", "\303\251" "1", NULL
    };
    static const unsigned lengths[] = {0, 1, 2, 7, 8, 9, 10, 18, 19, 20, 31, 64, 128};
    short saved[256];
    unsigned variant, i, byte;
    int saved_errflag = errflag;
    char s[132];
    use_reference = !strcmp(args[0], "reference");
    checks = 0;
    queue_signals();
    memcpy(saved, typtab, sizeof(saved));
    for (variant = 0; variant < 2; variant++) {
        if (variant) {
            typtab['1'] |= INBLANK;
            typtab['_'] |= INBLANK;
            typtab['q'] |= IDIGIT;
            typtab['9'] ^= IDIGIT;
        }
        for (i = 0; atoms[i]; i++) buffer(atoms[i]);
        for (i = 0; i < sizeof(lengths)/sizeof(lengths[0]); i++) {
            memset(s, '9', lengths[i]); s[lengths[i]] = 0; buffer(s);
            memset(s, '1', lengths[i]); s[lengths[i]] = 0; buffer(s);
        }
        for (i = 8; i <= 19; i++)
            for (byte = 0; byte < 256; byte++) {
                memset(s, '7', i); s[i] = (char)byte; s[i+1] = '2'; s[i+2] = 0;
                buffer(s);
            }
    }
    memcpy(typtab, saved, sizeof(saved));
    errflag = saved_errflag;
    unqueue_signals();
    printf("checks=%u\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-strtol-check", 0, bin_check, 1, 1, 0, NULL, NULL)
};
static struct features module_features = {bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features = featuresarray(m, &module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
