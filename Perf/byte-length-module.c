/* Test-only byte-count oracle, built with the selected pristine host headers. */
#include "zsh.mdh"

static int
check_raw(char *raw, unsigned length, unsigned *checks)
{
    static const int widths[] = {-1, 0, 1, 2};
    char *encoded = metafy(raw, length, META_DUP);
    size_t encoded_length = strlen(encoded);
    unsigned offset, max_offset = length >= 1048576 ? 2 : 8;
    int failed = 0;

    for (offset = 0; offset < max_offset && !failed; offset++) {
	size_t bytes = offset + encoded_length + 1;
	char *allocation = zalloc(bytes), *s = allocation + offset;
	char *before = zalloc(bytes);
	memset(allocation, 0xa5, bytes);
	memcpy(s, encoded, encoded_length + 1);
	memcpy(before, allocation, bytes);
	failed = ztrlen(s) != (int)length;
	(*checks)++;
#ifdef MULTIBYTE_SUPPORT
	if (!failed && encoded_length <= 2048 &&
	    (unset(MULTIBYTE) || MB_CUR_MAX == 1)) {
	    unsigned i;
	    for (i = 0; i < sizeof(widths)/sizeof(widths[0]); i++) {
		/* Preserve the byte-mode API's distinct explicit-end behavior. */
		if (mb_metastrlenend(s, widths[i], NULL) != (int)length ||
		    mb_metastrlenend(s, widths[i], s + encoded_length) != (int)encoded_length)
		    failed = 1;
		*checks += 2;
	    }
	    /* A non-NULL end at the start must not read this one-past pointer. */
	    if (mb_metastrlenend(allocation + bytes, 0, allocation + bytes) != 0)
		failed = 1;
	    (*checks)++;
	}
#else
	if (!failed && encoded_length <= 2048) {
	    if (ztrlenend(s, s + encoded_length) != (int)length)
		failed = 1;
	    (*checks)++;
	}
#endif
	if (memcmp(before, allocation, bytes)) failed = 1;
	zfree(before, bytes);
	zfree(allocation, bytes);
    }
    zsfree(encoded);
    return failed;
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned large[] = {127, 128, 129, 255, 256, 257, 1024, 1048576};
    unsigned test, pattern, n, i, checks = 0, malformed = 0;

    for (test = 0; test < 74; test++) {
	n = test < 66 ? test : large[test - 66];
	for (pattern = 0; pattern < 6; pattern++) {
	    char *raw = zalloc(n + 1);
	    for (i = 0; i < n; i++)
		raw[i] = pattern == 0 || pattern >= 4 ? 'x' :
		    pattern == 1 ? 0 : pattern == 2 ? Meta : (char)i;
	    if (n && pattern == 4) raw[n - 1] = Meta;
	    if (n && pattern == 5) raw[n / 2] = Meta;
	    raw[n] = 0;
	    if (check_raw(raw, n, &checks)) {
		zfree(raw, n + 1);
		fprintf(stderr, "byte length mismatch: n=%u pattern=%u\n", n, pattern);
		return 1;
	    }
	    zfree(raw, n + 1);
	}
    }
    for (i = 0; i < 256; i++) {
	char raw[] = {(char)i, Meta, 0};
	if (check_raw(raw, sizeof(raw), &checks)) return 1;
    }
#ifdef DEBUG
    /* Preserve the existing diagnostic and count for an incomplete Meta pair. */
    {
	static const unsigned lengths[] = {0, 1, 15, 16, 17, 31, 32, 33, 1024};
	unsigned offset;
	for (i = 0; i < sizeof(lengths)/sizeof(lengths[0]); i++) {
	    n = lengths[i];
	    for (offset = 0; offset < 8; offset++) {
		size_t bytes = offset + n + 2;
		char *allocation = zalloc(bytes), *s = allocation + offset;
		memset(allocation, 'x', bytes);
		s[n] = Meta; s[n + 1] = 0;
		if (ztrlen(s) != (int)n) {
		    zfree(allocation, bytes);
		    return 1;
		}
		zfree(allocation, bytes);
		checks++; malformed++;
	    }
	}
    }
#endif
    printf("checks=%u malformed=%u\n", checks, malformed);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-byte-length-check", 0, bin_check, 0, 0, 0, NULL, NULL)
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
