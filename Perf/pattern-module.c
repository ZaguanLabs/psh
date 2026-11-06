/* Test-only native API checks for bounded terminal-star matching. */
#include "zsh.mdh"

static Patprog
compile_pattern(const char *pattern)
{
    char *text = dupstring(pattern);
    tokenize(text);
    return patcompile(text, PAT_ZDUP, NULL);
}

static int
check_boundaries(int utf8chars)
{
    static const int positions[] = { 1, 7, 8, 9, 15, 16, 17, 31, 32, 33, 62, 63 };
    Patprog prog = compile_pattern("a*");
    int alignment, n, position, variant, checks = 0;
    if (!prog) return -1;

    /* All alignments and short lengths around eight-byte boundaries.
     * These allocations have no NUL or guard after the requested span. */
    for (alignment = 0; alignment < 8; alignment++) {
	for (n = 1; n <= 65; n++) {
	    char *allocation, *input;
	    int end = -99, result, failed;
	    if (n > 33 && n < 63) continue;
	    allocation = zalloc(alignment + n);
	    memset(allocation, 'x', alignment + n);
	    input = allocation + alignment;
	    input[0] = 'a';
	    result = pattryrefs(prog, input, n, n, NULL, 7, NULL, NULL, &end);
	    failed = result != 1 || end != n + 7 || patmatchlen() != n;
	    zfree(allocation, alignment + n);
	    if (failed) {
		fprintf(stderr, "bounded ASCII alignment=%d length=%d\n", alignment, n);
		freepatprog(prog);
		return -1;
	    }
	    checks++;
	}
    }
    for (position = 0; position < 12; position++) {
	for (variant = 0; variant < 3; variant++) {
	    char raw[64], *encoded;
	    int p = positions[position], chars = 64, metalen, end = -99, result, failed;
	    memset(raw, 'x', sizeof(raw));
	    raw[0] = 'a';
	    if (variant == 0) raw[p] = '\0';
	    else if (variant == 1) raw[p] = (char)0xff;
	    else {
		raw[p] = (char)0xc3;
		if (p + 1 < 64) {
		    raw[p + 1] = (char)0xa9;
		    if (utf8chars == 3) chars--;
		}
	    }
	    encoded = metafy(raw, 64, META_DUP);
	    metalen = strlen(encoded);
	    result = pattryrefs(prog, encoded, metalen, 64, NULL, 7, NULL, NULL, &end);
	    failed = result != 1 || end != chars + 7 || patmatchlen() != metalen;
	    zsfree(encoded);
	    if (failed) {
		fprintf(stderr, "mixed boundary position=%d variant=%d\n", p, variant);
		freepatprog(prog);
		return -1;
	    }
	    checks++;
	}
    }
    freepatprog(prog);
    return checks;
}

static int
check_api(char **args)
{
    static const struct {
	const char *raw;
	int bytes, chars;
    } inputs[] = {
	{ "a!", 1, 1 }, { "axxx!", 4, 4 }, { "a\0bc!", 4, 4 },
	{ "a\303\251b!", 4, -1 }, { "a\303!", 2, 2 },
	{ "a\377b!", 3, 3 }, { "!", 0, 0 }
    };
    static const char *patterns[] = {
	"a*", "a***", "(#b)(a)*", "(#b)(a*)", "a*X"
    };
    int input, variant, offset, checks = 0, utf8chars = atoi(args[0]), bounded;

    for (input = 0; input < 7; input++) {
	int n = inputs[input].bytes, metalen = n, i;
	int chars = inputs[input].chars < 0 ? utf8chars : inputs[input].chars;
	char *encoded = metafy((char *)inputs[input].raw, n + 1, META_DUP);
	for (i = 0; i < n; i++)
	    if (imeta(inputs[input].raw[i])) metalen++;
	for (offset = 0; offset <= 7; offset += 7) {
	    for (variant = 0; variant < 5; variant++) {
		Patprog prog = compile_pattern(patterns[variant]);
		int expected = n > 0 && variant != 4;
		int captures = variant == 2 || variant == 3;
		int num = 2, beg[2] = {-99, -99}, end[2] = {-99, -99};
		int result, failed;
		if (!prog) return 1;
		result = pattryrefs(prog, encoded, metalen, -1, NULL, offset,
				    captures ? &num : NULL, captures ? beg : NULL, end);
		failed = result != expected;
		if (expected) {
		    failed |= patmatchlen() != metalen;
		    if (captures)
			failed |= num != 1 || beg[0] != offset ||
			    end[0] != offset + (variant == 2 ? 0 : chars - 1);
		    else
			failed |= end[0] != offset + chars;
		}
		freepatprog(prog);
		if (failed) {
		    fprintf(stderr, "input=%d pattern=%s offset=%d\n",
			    input, patterns[variant], offset);
		    return 1;
		}
		checks++;
	    }
	    {
		Patprog prog = compile_pattern("a*");
		struct patstralloc allocation;
		char *unmetafied;
		int end = -99, expected = n > 0, result;
		if (!prog) return 1;
		result = pattrylen(prog, encoded, metalen, n, NULL, offset);
		if (result != expected || (expected && patmatchlen() != metalen)) return 1;
		checks++;
		unmetafied = patallocstr(prog, encoded, metalen, n, 1, &allocation);
		result = pattryrefs(prog, unmetafied, n, -1, &allocation,
				    offset, NULL, NULL, &end);
		if (result != expected || (expected && end != offset + chars)) return 1;
		freepatprog(prog);
		checks++;
	    }
	}
	zsfree(encoded);
    }
    bounded = check_boundaries(utf8chars);
    if (bounded < 0) return 1;
    checks += bounded;
    printf("checks=%d\n", checks);
    fflush(stdout);
    return 0;
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int saved = queue_signal_level(), result;
    if (!strcmp(args[1], "unqueued")) {
	dont_queue_signals();
	result = check_api(args);
	restore_queue_signals(saved);
    } else {
	queue_signals();
	result = check_api(args);
	unqueue_signals();
    }
    return result;
}

static struct builtin bintab[] = {
    BUILTIN("psh-pattern-check", 0, bin_check, 2, 2, 0, NULL, NULL)
};
static struct features module_features = {
    bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0
};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features = featuresarray(m, &module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
