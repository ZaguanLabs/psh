/* Check bounded-copy contents and ownership using the original native SDK. */
#include "zsh.mdh"

static int
check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned sizes[] = {0, 1, 2, 31, 32, 33, 127, 128, 129, 4095, 4096, 4097, 16384};
    unsigned si, count = 0;
    for (si = 0; si < sizeof(sizes) / sizeof(*sizes); si++) {
        unsigned size = sizes[si], i, m, start, position;
        unsigned starts[] = {0, size/2, size};
        unsigned maxima[] = {0, 1, 2, 31, 32, 33, size/2, size, size+1, INT_MAX, UINT_MAX};
        char **source = (char **)zalloc((size + 1) * sizeof(char *));
        for (i = 0; i < size; i++)
            source[i] = ztrdup(i % 3 == 0 ? "" : i % 3 == 1 ? "two words" : "line\nbreak");
        source[size] = NULL;
        for (position = 0; position < sizeof(starts) / sizeof(*starts); position++) {
            start = starts[position];
            for (m = 0; m < sizeof(maxima) / sizeof(*maxima); m++) {
                unsigned want = maxima[m] < size-start ? maxima[m] : size-start;
                char **copy;
                int ok = 1;
                pushheap();
                copy = arrdup_max(source + start, maxima[m]);
                if (!copy || copy == source + start || copy[want]) ok = 0;
                for (i = 0; ok && i < want; i++) {
                    if (!copy[i] || copy[i] == source[start+i] || strcmp(copy[i], source[start+i]))
                        ok = 0;
                    else if (*source[start+i]) {
                        char original = source[start+i][0];
                        source[start+i][0] = '!';
                        if (copy[i][0] != original) ok = 0;
                        source[start+i][0] = original;
                    }
                }
                popheap();
                if (!ok) { freearray(source); return 1; }
                count++;
            }
        }
        freearray(source);
    }
    printf("bounded-copy-checks=%u ok=1\n", count);
    return 0;
}
static struct builtin bintab[] = {BUILTIN("psh-array-copy-check",0,check,0,0,0,NULL,NULL)};
static struct features features = {bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
