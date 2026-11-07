/* Test-only character/width counter, built with pristine release headers. */
#include "zsh.mdh"
#include "mb-length-reference.c"

/* Match the public wrapper's byte and token shortcuts before using the
 * exported reentrant converter with our independent reference state. */
static int
reference_next(const char *s, wint_t *wc)
{
    if (!isset(MULTIBYTE) || (unsigned char)*s <= 0x7f) {
	if (wc) *wc = (wint_t)(unsigned char)(*s == Meta ? s[1] ^ 32 : *s);
	return 1 + (*s == Meta);
    }
    if (itok(*s)) {
	if (wc) *wc = WEOF;
	return 1;
    }
    return mb_metacharlenconv_r(s, wc, &reference_state);
}

static int
check_buffer(const char *source, size_t n, unsigned *checks)
{
    static const int widths[] = {-7, 0, 1, 2, 7};
    static const char continuation[] = {Meta, (char)(0xa9 ^ 32), 0};
    static const char *probes[] = {continuation, "\xc3", "a", "\xe7", "\x95", "\x8c", "\xff"};
    size_t offset, endpoint, w, seed, probe;
    for (offset = 0; offset < 4; offset++) {
	size_t bytes = offset + n + 1;
	char *allocation = zalloc(bytes), *s = allocation + offset;
	char *before = zalloc(bytes);
	memset(allocation, 0xa5, bytes);
	memcpy(s, source, n + 1);
	memcpy(before, allocation, bytes);
	/* n+1 denotes no explicit bound. All explicit endpoints remain
	 * addressable: the original outer loop reads its endpoint byte.
	 * Meta pairs may cross an endpoint, exactly as in the original. */
	for (endpoint = 0; endpoint <= n + 1; endpoint++) {
	    if (n > 65 && endpoint > 2 && endpoint < n - 2 &&
		endpoint % 31 != 0)
		continue;
	    for (w = 0; w < sizeof(widths)/sizeof(widths[0]); w++) {
		for (seed = 0; seed < 2; seed++) {
		    int expected, actual, expected_len[7], actual_len[7];
		    int saved_mb;
		    wint_t expected_wc[7], actual_wc[7];
		    char *end = endpoint == n + 1 ? NULL : s + endpoint;
		    memset(&reference_state, 0, sizeof(reference_state));
		    mb_charinit();
		    if (seed) {
			int saved = opts[MULTIBYTE];
			opts[MULTIBYTE] = 1;
			reference_mb_metastrlenend("\xc3", 0, NULL);
			mb_metastrlenend("\xc3", 0, NULL);
			opts[MULTIBYTE] = saved;
		    }
		    expected = reference_mb_metastrlenend(s, widths[w], end);
		    actual = mb_metastrlenend(s, widths[w], end);
		    /* The host's shift state is private. Compare its observable
		     * continuation with the reference after each invocation. */
		    saved_mb = opts[MULTIBYTE];
		    opts[MULTIBYTE] = 1;
		    for (probe = 0; probe < 7; probe++) {
			expected_len[probe] = reference_next(probes[probe],
			    &expected_wc[probe]);
			actual_len[probe] = mb_metacharlenconv(probes[probe],
			    &actual_wc[probe]);
		    }
		    opts[MULTIBYTE] = saved_mb;
		    (*checks)++;
		    if (expected != actual ||
			memcmp(expected_len, actual_len, sizeof(expected_len)) ||
			memcmp(expected_wc, actual_wc, sizeof(expected_wc)) ||
			memcmp(before, allocation, bytes)) {
			fprintf(stderr, "count mismatch: n=%lu offset=%lu end=%lu width=%d seed=%lu expected=%d actual=%d\n",
				(unsigned long)n, (unsigned long)offset,
				(unsigned long)endpoint, widths[w], (unsigned long)seed,
				expected, actual);
			zfree(before, bytes);
			zfree(allocation, bytes);
			return 1;
		    }
		}
	    }
	}
	zfree(before, bytes);
	zfree(allocation, bytes);
    }
    return 0;
}

static int
check_raw(const char *raw, size_t n, unsigned *checks)
{
    char *encoded = metafy((char *)raw, n, META_DUP);
    int failed = check_buffer(encoded, strlen(encoded), checks);
    zsfree(encoded);
    return failed;
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned lengths[] = {0, 1, 2, 7, 8, 9, 15, 16, 17, 31, 32, 33,
	63, 64, 65, 127, 128, 129, 1024};
    static const char *mixed[] = {"\xc3\xa9", "\xe7\x95\x8c", "\xf0\x9f\x98\x80",
	"e\xcc\x81", "\xc3", "\xe7\x95", "\xff", "\xc3x", "\xe7\x95x"};
    unsigned checks = 0, i, j, byte;
    int failed = 0;
    queue_signals();
    for (i = 0; i < sizeof(lengths)/sizeof(lengths[0]) && !failed; i++) {
	size_t n = lengths[i];
	char *raw = zalloc(2 * n + 32);
	memset(raw, 'x', 2 * n + 32);
	failed = check_raw(raw, n, &checks);
	for (j = 0; j < sizeof(mixed)/sizeof(mixed[0]) && !failed; j++) {
	    size_t m = strlen(mixed[j]);
	    memcpy(raw + n, mixed[j], m);
	    memset(raw + n + m, 'y', n);
	    failed = check_raw(raw, 2 * n + m, &checks);
	    if (!failed) failed = check_raw(raw, n + m, &checks);
	}
	/* True locale-encoded wide character, including an ASCII tail. */
	if (*args && !failed) {
	    size_t m = strlen(*args);
	    memcpy(raw + n, *args, m);
	    memset(raw + n + m, 'y', n);
	    failed = check_raw(raw, 2 * n + m, &checks);
	}
	zfree(raw, 2 * n + 32);
    }
    /* Every raw byte, including embedded NUL and Meta, after several
     * prefixes. Metafy supplies valid storage for every Meta escape. */
    for (i = 0; i < 4 && !failed; i++) {
	for (byte = 0; byte < 256 && !failed; byte++) {
	    char raw[24];
	    memset(raw, 'a', sizeof(raw));
	    raw[i * 4] = (char)byte;
	    failed = check_raw(raw, i * 4 + 9, &checks);
	}
    }
    /* Interior literal terminator, with addressable explicit endpoints
     * after it. This is not a valid embedded Zsh NUL (which is Meta). */
    if (!failed) {
	char raw[] = "abcd\0tail";
	failed = check_buffer(raw, sizeof(raw) - 1, &checks);
    }
    unqueue_signals();
    if (failed) return 1;
    printf("checks=%u\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-mb-length-check", 0, bin_check, 0, 1, 0, NULL, NULL)
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
