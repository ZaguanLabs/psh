/* Isolated public conversion API timings; no warning-producing input. */
#include "zsh.mdh"
#include <time.h>

static int
bin_bench(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const struct { const char *name, *text; int base; } cases[] = {
        {"short", "7", 10}, {"nine", "123456789", 10},
        {"ten", "1234567890", 10}, {"eighteen", "123456789012345678", 10},
        {"signed", "-123456789", 10}, {"underscores", "123_456_789", 10},
        {"base16", "123456789abcdef", 16}, {"base0", "123456789", 0},
        {"nondigit", "text", 10}, {"nineteen", "1234567890123456789", 10}
    };
    struct timespec begin, end;
    unsigned i, n;
    zulong digest = 0;
    char *tail;
    for (i = 0; i < sizeof(cases)/sizeof(cases[0]); i++)
        if (!strcmp(cases[i].name, args[0])) break;
    if (i == sizeof(cases)/sizeof(cases[0])) return 1;
    queue_signals();
    if (clock_gettime(CLOCK_MONOTONIC, &begin)) { unqueue_signals(); return 2; }
    for (n = 0; n < 1000000; n++) {
        zlong value = zstrtol_underscore(cases[i].text, &tail, cases[i].base, 1);
        digest += (zulong)value + (zulong)(tail - cases[i].text);
    }
    if (clock_gettime(CLOCK_MONOTONIC, &end)) { unqueue_signals(); return 3; }
    unqueue_signals();
    printf("%lld\n%llu\n", (long long)(end.tv_sec - begin.tv_sec) * 1000000000 +
           end.tv_nsec - begin.tv_nsec, (unsigned long long)digest);
    return 0;
}
static struct builtin bintab[] = {BUILTIN("psh-strtol-bench", 0, bin_bench, 1, 1, 0, NULL, NULL)};
static struct features module_features = {bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features = featuresarray(m, &module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
