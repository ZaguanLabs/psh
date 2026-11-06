/* Test-only fixture for public null-marker removal, using pristine headers. */
#include "zsh.mdh"

static int checks;

static int
check_input(const char *raw, int n, int alignment, const char *expected)
{
    char *allocation = zalloc(alignment + n + 1), *text = allocation + alignment;
    int i;
    memset(allocation, 0xc7, alignment);
    memcpy(text, raw, n + 1);
    remnulargs(text);
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
	"", "abc", { Bnullkeep, 'a', 0 },
	{ Snull, Bnullkeep, 'a', 0 },
	{ 'a', Bnullkeep, Snull, Bnullkeep, 'b', 0 },
	{ Snull, Dnull, 0 }, { Snull, Nularg, Bnullkeep, 0 },
	{ Nularg, 'a', Bnullkeep, 0 }, { 'a', Bnullkeep, 0 },
	{ Meta, ' ', 0 }
    };
    static const char expected[][8] = {
	"", "abc", { Bnullkeep, 'a', 0 }, "\\a",
	{ 'a', Bnullkeep, '\\', 'b', 0 }, { Nularg, 0 },
	"\\", "a\\", { 'a', Bnullkeep, 0 }, { Meta, ' ', 0 }
    };
    static const int prefixes[] = { 0, 1, 63, 64, 65, 127, 255, 575, 576, 577, 1024 };
    short saved[256];
    char raw[1032], *large;
    int mode, p, byte, variant, n, i, alignment, failed = 0;
    checks = 0;
    for (i = 0; i < 10; i++)
	if (check_input(inputs[i], strlen(inputs[i]), 0, expected[i])) return 1;

    memcpy(saved, typtab, sizeof(saved));
    for (mode = 0; mode < 5 && !failed; mode++) {
	memcpy(typtab, saved, sizeof(saved));
	if (mode == 1) typtab['S'] |= INULL;
	if (mode == 2) typtab[(unsigned char)Snull] &= ~INULL;
	if (mode == 3 || mode == 4)
	    for (i = 0; i < 256; i++) {
		if (mode == 3) typtab[i] &= ~INULL;
		else typtab[i] |= INULL;
	    }
	/* A long preserved-backslash prefix reaches the dynamic-set path
	 * even when every other byte is classified as removable. */
	memset(raw, Bnullkeep, 1024);
	raw[1024] = 'S'; raw[1025] = Snull;
	raw[1026] = Bnullkeep; raw[1027] = '\0';
	if (check_input(raw, 1027, 0, NULL)) { failed = 1; break; }
	for (p = 0; p < (int)(sizeof(prefixes)/sizeof(prefixes[0])) && !failed; p++) {
	    for (byte = 1; byte < 256 && !failed; byte++) {
		for (variant = 0; variant < 2; variant++) {
		    n = prefixes[p];
		    memset(raw, 'y', n);
		    raw[n++] = (char)byte;
		    if (variant) {
			raw[n++] = Bnullkeep;
			raw[n++] = 'z';
			raw[n++] = Snull;
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
    if (failed) return 1;

    /* Exact allocations at all alignments and lengths around the cutoff. */
    for (alignment = 0; alignment < 8; alignment++) {
	for (n = 0; n <= 129; n++) {
	    memset(raw, 'y', n);
	    raw[n] = '\0';
	    if (check_input(raw, n, alignment, raw)) return 1;
	    if (n) {
		raw[n - 1] = Snull;
		if (check_input(raw, n, alignment, NULL)) return 1;
	    }
	}
    }
    for (alignment = 0; alignment < 8; alignment++) {
	static const int boundaries[] = { 575, 576, 577, 1024 };
	for (i = 0; i < 4; i++) {
	    n = boundaries[i];
	    memset(raw, 'y', n);
	    raw[n] = '\0';
	    if (check_input(raw, n, alignment, raw)) return 1;
	    raw[n - 1] = Snull;
	    if (check_input(raw, n, alignment, NULL)) return 1;
	}
    }
    large = zalloc(1048577);
    memset(large, 'y', 1048576);
    large[1048576] = '\0';
    failed = check_input(large, 1048576, 0, large);
    large[1048575] = Snull;
    if (!failed) failed = check_input(large, 1048576, 0, NULL);
    zfree(large, 1048577);
    if (failed) return 1;
    printf("checks=%d\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-remnulargs-check", 0, bin_check, 0, 0, 0, NULL, NULL)
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
