/* Test-only fixture for the exported bounded metafied-length helper. */
#include "zsh.mdh"

static int
check_spans(char *raw, int length, int *checks)
{
    char *encoded = metafy(raw, length, META_DUP);
    char *boundary[257], *p = encoded;
    int first, last;

    /* Map logical byte boundaries in the encoded test data. Expected lengths
     * come from positions in the original raw input, not from ztrsub(). */
    for (first = 0; first < length; first++) {
	boundary[first] = p;
	p += imeta(raw[first]) ? 2 : 1;
    }
    boundary[length] = p;
    if (p != encoded + strlen(encoded)) {
	zsfree(encoded);
	return 1;
    }
    for (first = 0; first <= length; first++) {
	for (last = first; last <= length; last++) {
	    if (ztrsub(boundary[last], boundary[first]) != last - first) {
		zsfree(encoded);
		return 1;
	    }
	    (*checks)++;
	}
    }
    zsfree(encoded);
    return 0;
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops),
	  UNUSED(int func))
{
    char raw[256], *plain;
    int i, checks = 0, failed;
    const int large = 1048576;

    for (i = 0; i < 256; i++) raw[i] = (char)i;
    if (check_spans(raw, 256, &checks)) return 1;
    memset(raw, 'x', sizeof(raw));
    if (check_spans(raw, 256, &checks)) return 1;
    memset(raw, 0, sizeof(raw));
    if (check_spans(raw, 256, &checks)) return 1;
    for (i = 0; i < 256; i++) raw[i] = i % 2 ? Meta : 'x';
    if (check_spans(raw, 256, &checks)) return 1;

    /* No NUL delimiter. A Meta immediately outside the supplied span must
     * not affect its length. Memcheck also checks the allocation boundary. */
    plain = zalloc(large + 1);
    memset(plain, 'x', large);
    plain[large] = Meta;
    failed = ztrsub(plain + large, plain) != large ||
	ztrsub(plain + large, plain + 1) != large - 1 ||
	ztrsub(plain + large + 1, plain + large + 1) != 0;
    zfree(plain, large + 1);
    if (failed) return 1;
    checks += 3;
    printf("checks=%d\n", checks);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-ztrsub-check", 0, bin_check, 0, 0, 0, NULL, NULL)
};
static struct features module_features = {
    bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0
};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) {
    *features = featuresarray(m, &module_features);
    return 0;
}
int enables_(Module m, int **enables) {
    return handlefeatures(m, &module_features, enables);
}
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
