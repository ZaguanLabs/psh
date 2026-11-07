/* Test-only public array-length API fixture, built with pristine headers. */
#include "zsh.mdh"

static int
check_bounds(char **array, unsigned length, unsigned bound, unsigned *checks)
{
    unsigned next = bound + 1U;
    /* Preserve the existing unsigned wrap in the gt/le wrappers. */
    if (arrlen_ge(array, bound) != (length >= bound) ||
	arrlen_gt(array, bound) != (length >= next) ||
	arrlen_lt(array, bound) != (length < bound) ||
	arrlen_le(array, bound) != (length < next)) {
	fprintf(stderr, "array length=%u bound=%u\n", length, bound);
	return 1;
    }
    *checks += 4;
    return 0;
}

static int
check_no_read(char **array, unsigned *checks)
{
    if (arrlen_ge(array, 0) != 1 || arrlen_lt(array, 0) != 0 ||
	arrlen_gt(array, UINT_MAX) != 1 || arrlen_le(array, UINT_MAX) != 0)
	return 1;
    *checks += 4;
    return 0;
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned bounds[] = {
	0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 31, 32, 33,
	63, 64, 65, 127, 128, 129, UINT_MAX - 1, UINT_MAX
    };
    static const unsigned large[] = {255, 256, 257, 1023, 1024, 1025, 4095, 4096, 4097};
    static char marker, empty[] = "";
    unsigned test, shift, n, i, checks = 0;

    if (check_no_read(NULL, &checks)) return 1;
    for (test = 0; test < 139; test++) {
	n = test < 130 ? test : large[test - 130];
	for (shift = 0; shift < 8; shift++) {
	    size_t bytes = (shift + n + 1) * sizeof(char *);
	    char **allocation = zalloc(bytes), **array = allocation + shift;
	    char *before = zalloc(bytes);
	    unsigned near[] = {n - 1U, n, n + 1U, n + 2U};
	    int failed = 0;
	    for (i = 0; i < shift + n; i++)
		allocation[i] = i % 3 == 0 ? empty : i % 3 == 1 ? &marker : &marker + 1;
	    array[n] = NULL;
	    memcpy(before, allocation, bytes);
	    if (arrlen(array) != (int)n) failed = 1;
	    checks++;
	    for (i = 0; i < sizeof(bounds)/sizeof(bounds[0]) && !failed; i++)
		failed = check_bounds(array, n, bounds[i], &checks);
	    for (i = 0; i < 4 && !failed; i++)
		failed = check_bounds(array, n, near[i], &checks);
	    if (!failed) failed = check_no_read(array + n + 1, &checks);
	    if (memcmp(before, allocation, bytes)) failed = 1;
	    zfree(before, bytes);
	    zfree(allocation, bytes);
	    if (failed) return 1;
	}
    }
    printf("checks=%u\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-array-length-check", 0, bin_check, 0, 0, 0, NULL, NULL)
};
static struct features module_features = {
    bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0
};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) {
    *features = featuresarray(m, &module_features); return 0;
}
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
