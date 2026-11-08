/* Test-only public classification API fixture, built with pristine headers. */
#include "zsh.mdh"
#include <limits.h>
#include "itype-reference.c"

static int
check_buffer(const char *source, unsigned *checks)
{
    static const int types[] = {IIDENT, IUSER, ISEP, IWORD, IALNUM, IDIGIT,
                                0, ITOK, IIDENT | IUSER, ISEP | IWORD, -1};
    static const int once_values[] = {0, 1, -7, INT_MAX};
    static const char probe[] = "\xc3\xa9";
    unsigned offset, type, once, seed;
    size_t n = strlen(source);
    for (offset = 0; offset < 2; offset++) {
	size_t bytes = offset + n + 1;
	char *allocation = zalloc(bytes), *s = allocation + offset;
	char *before = zalloc(bytes);
	memset(allocation, 0xa5, bytes);
	memcpy(s, source, n + 1);
	memcpy(before, allocation, bytes);
	for (type = 0; type < sizeof(types)/sizeof(types[0]); type++) {
	    /* The byte-mode API requires its terminator not to match. */
	    if (zistype(0, types[type]))
		continue;
	    for (once = 0; once < sizeof(once_values)/sizeof(once_values[0]); once++) {
		for (seed = 0; seed < 2; seed++) {
		    char *expected, *actual;
		    wint_t expected_wc, actual_wc;
		    int expected_len, actual_len;
		    mb_charinit();
		    if (seed) mb_metacharlenconv("\xc3", NULL);
		    expected = reference_itype_end(s, types[type], once_values[once]);
		    expected_len = mb_metacharlenconv(probe, &expected_wc);
		    mb_charinit();
		    if (seed) mb_metacharlenconv("\xc3", NULL);
		    actual = itype_end(s, types[type], once_values[once]);
		    actual_len = mb_metacharlenconv(probe, &actual_wc);
		    (*checks)++;
		    if (actual != expected || actual < s || actual > s + n ||
			expected_len != actual_len || expected_wc != actual_wc ||
			memcmp(before, allocation, bytes)) {
			fprintf(stderr, "itype mismatch: n=%lu type=%d once=%d seed=%u\n",
				(unsigned long)n, types[type], once_values[once], seed);
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
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned lengths[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 16, 17,
                                      31, 32, 33, 63, 64, 65, 127, 128, 129,
                                      255, 256, 257, 1024};
    short saved[256];
    unsigned variant, byte, i, checks = 0;
    int failed = 0;

    queue_signals();
    memcpy(saved, typtab, sizeof(saved));
#ifdef MULTIBYTE_SUPPORT
    reference_set_widearray(ifs ? ifs :
        EMULATION(EMULATE_KSH|EMULATE_SH) ? DEFAULT_IFS_SH : DEFAULT_IFS, &ifs_wide);
    reference_set_widearray(wordchars, &wordchars_wide);
#endif
    for (variant = 0; variant < 2 && !failed; variant++) {
	if (variant) {
	    typtab['a'] ^= IIDENT;
	    typtab['7'] |= IUSER | ITOK;
	    typtab['_'] ^= ISEP | IWORD;
	}
	for (byte = 0; byte < 256 && !failed; byte++) {
	    char raw[] = {'a', (char)byte, '9', '\0'};
	    char *encoded = metafy(raw, 3, META_DUP);
	    failed = check_buffer(encoded, &checks);
	    zsfree(encoded);
	    if (!failed) failed = check_buffer(raw, &checks);
	}
	for (i = 0; i < sizeof(lengths)/sizeof(lengths[0]) && !failed; i++) {
	    size_t n = lengths[i];
	    char *raw = zalloc(n + 6), *encoded;
	    memset(raw, 'a', n);
	    memcpy(raw + n, "_7\xc3\xa9.", 6);
	    encoded = metafy(raw, n + 5, META_DUP);
	    failed = check_buffer(encoded, &checks);
	    zsfree(encoded);
	    raw[n] = '\0';
	    if (!failed) failed = check_buffer(raw, &checks);
	    zfree(raw, n + 6);
	}
    }
#ifdef MULTIBYTE_SUPPORT
    free(ifs_wide.chars); ifs_wide.chars = NULL; ifs_wide.len = 0;
    free(wordchars_wide.chars); wordchars_wide.chars = NULL; wordchars_wide.len = 0;
#endif
    memcpy(typtab, saved, sizeof(saved));
    unqueue_signals();
    if (failed) return 1;
    printf("checks=%u\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-itype-check", 0, bin_check, 0, 0, 0, NULL, NULL)
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
