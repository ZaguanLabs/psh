/* Test-only fixture for public token conversion, using pristine headers. */
#include "zsh.mdh"

static int checks;

static int
check_input(const char *raw, int n, int alignment, const char *expected)
{
    char *allocation = zalloc(alignment + n + 1), *text = allocation + alignment;
    int i;
    memset(allocation, 0xc7, alignment);
    memcpy(text, raw, n + 1);
    untokenize(text);
    for (i = 0; i < alignment; i++)
	if ((unsigned char)allocation[i] != 0xc7) {
	    zfree(allocation, alignment + n + 1);
	    return 1;
	}
    if (expected && strcmp(text, expected)) {
	zfree(allocation, alignment + n + 1);
	return 1;
    }
    /* Include bytes beyond the new terminator: in-place tail writes are
     * part of the pristine comparison, as well as the resulting string. */
    printf("%d:%d:", alignment, n);
    fwrite(allocation, 1, alignment + n + 1, stdout);
    putchar('\n');
    zfree(allocation, alignment + n + 1);
    checks++;
    return 0;
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const char inputs[][8] = {
	"", "abc", { Star, 0 }, { Pound, String, Qstring, Equals, 0 },
	{ Nularg, 0 }, { 'a', Nularg, 'b', 0 },
	{ Snull, 'a', Snull, 0 }, { Dnull, 'a', Dnull, 0 },
	{ Bnull, Bnullkeep, 0 }, { Meta, ' ', 0 }
    };
    static const char expected[][8] = {
	"", "abc", "*", "#$$=", "", "ab", "'a'", "\"a\"",
	{ '\\', '\\', 0 }, { Meta, ' ', 0 }
    };
    static const int prefixes[] = { 0, 1, 63, 64, 65, 127, 255, 575, 576, 577, 1024, 1087, 1088, 1089, 2048 };
    short saved[256];
    char saved_tokens[Nularg - Pound + 1];
    char raw[2056], *large;
    int mode, p, byte, variant, n, i, alignment, failed = 0;
    checks = 0;
    for (i = 0; i < 10; i++)
	if (check_input(inputs[i], strlen(inputs[i]), 0, expected[i])) return 1;

    memcpy(saved, typtab, sizeof(saved));
    memcpy(saved_tokens, ztokens, sizeof(saved_tokens));
    for (mode = 0; mode < 10 && !failed; mode++) {
	memcpy(typtab, saved, sizeof(saved));
	memcpy(ztokens, saved_tokens, sizeof(saved_tokens));
	if (mode == 1) typtab[(unsigned char)Star] &= ~ITOK;
	if (mode == 2 || mode == 3) {
	    for (i = 0; i < 256; i++) typtab[i] &= ~ITOK;
	    if (mode == 3) {
		typtab[(unsigned char)Star] |= ITOK;
		typtab[(unsigned char)Nularg] |= ITOK;
	    }
	}
	if (mode == 4) typtab[(unsigned char)Nularg] &= ~ITOK;
	if (mode == 5) ztokens[Star - Pound] = 'Z';
	if (mode == 6) ztokens[Star - Pound] = '\0';
	if (mode >= 7) {
	    int first = (unsigned char)Pound + (mode == 9 ? 15 : 0);
	    int count = mode == 8 ? 16 : 15;
	    for (i = 0; i < 256; i++) typtab[i] &= ~ITOK;
	    for (i = first; i < first + count; i++) typtab[i] |= ITOK;
	}
	/* Non-token high bytes must stay inert in all valid table variants. */
	memset(raw, 0xe9, 2048);
	raw[2048] = Star; raw[2049] = Snull;
	raw[2050] = Nularg; raw[2051] = '\0';
	if (check_input(raw, 2051, 0, NULL)) { failed = 1; break; }
	/* Exercise the opposite ordering of tokens from different groups. */
	raw[2048] = Bnullkeep; raw[2049] = Star;
	if (check_input(raw, 2051, 0, NULL)) { failed = 1; break; }
	for (p = 0; p < (int)(sizeof(prefixes)/sizeof(prefixes[0])) && !failed; p++) {
	    for (byte = 1; byte < 256 && !failed; byte++) {
		for (variant = 0; variant < 2; variant++) {
		    n = prefixes[p];
		    memset(raw, 'y', n);
		    raw[n++] = (char)byte;
		    if (variant) {
			raw[n++] = Bnullkeep;
			raw[n++] = 'z';
			raw[n++] = Nularg;
			raw[n++] = Bnullkeep;
			raw[n++] = 'q';
		    }
		    raw[n] = '\0';
		    if (check_input(raw, n, 0, NULL)) { failed = 1; break; }
		}
	    }
	}
    }
    memcpy(typtab, saved, sizeof(saved));
    memcpy(ztokens, saved_tokens, sizeof(saved_tokens));
    if (failed) return 1;

    /* Exact allocations at all alignments and lengths around the cutoff. */
    for (alignment = 0; alignment < 8; alignment++) {
	for (n = 0; n <= 129; n++) {
	    memset(raw, 'y', n);
	    raw[n] = '\0';
	    if (check_input(raw, n, alignment, raw)) return 1;
	    if (n) {
		raw[n - 1] = Nularg;
		if (check_input(raw, n, alignment, NULL)) return 1;
	    }
	}
    }
    for (alignment = 0; alignment < 8; alignment++) {
	static const int boundaries[] = { 575, 576, 577, 1024, 1087, 1088, 1089, 2048 };
	for (i = 0; i < 8; i++) {
	    n = boundaries[i];
	    memset(raw, 'y', n);
	    raw[n] = '\0';
	    if (check_input(raw, n, alignment, raw)) return 1;
	    raw[n - 1] = Nularg;
	    if (check_input(raw, n, alignment, NULL)) return 1;
	}
    }
    large = zalloc(1048577);
    memset(large, 'y', 1048576);
    large[1048576] = '\0';
    failed = check_input(large, 1048576, 0, large);
    large[1048575] = Nularg;
    if (!failed) failed = check_input(large, 1048576, 0, NULL);
    zfree(large, 1048577);
    if (failed) return 1;
    printf("checks=%d\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-untokenize-check", 0, bin_check, 0, 0, 0, NULL, NULL)
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
