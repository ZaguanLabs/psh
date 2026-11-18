/* Linux/glibc diagnostics, compiled against each shell's own SDK. */
#include "zsh.mdh"
#include <malloc.h>

static int
check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const size_t lengths[] = {0, 1, 191, 192, 198, 199, 200, 201,
	255, 256, 257, 4096, 50000, 50000, 3};
    static const int storage[] = {PAT_STATIC, PAT_HEAPDUP, PAT_ZDUP,
	PAT_STATIC | PAT_ZDUP};
    size_t i, j;
    int file, checks = 0;
    char *text = zhalloc(50008);
    Patprog held, p;

    for (i = 0; i < sizeof(lengths) / sizeof(*lengths); ++i) {
	size_t n = lengths[i];
	for (file = 0; file < 2; ++file) {
	    for (j = 0; j < sizeof(storage) / sizeof(*storage); ++j) {
		char *end = NULL;
		int flags = storage[j] | (file ? PAT_FILE : 0);
		memset(text, 'x', n);
		strcpy(text + n, file ? "/tail" : "");
		patcompstart();
		p = patcompile(text, flags, &end);
		if (!p || !(p->flags & PAT_PURES) || end != text + n ||
		    p->patmlen != (long)n || p->startoff + (long)n >= p->size ||
		    memcmp((char *)p + p->startoff, text, n) ||
		    ((char *)p)[p->startoff + n])
		    return 1;
		if (storage[j] == PAT_STATIC && !file)
		    printf("literal %zu program %ld usable %zu\n",
			   n, p->size, malloc_usable_size(p));
		text[n] = '\0';
		if (!pattry(p, text))
		    return 1;
		if (storage[j] != PAT_STATIC) {
		    held = p;
		    p = patcompile(dupstring("replacement"), PAT_STATIC, NULL);
		    if (!p || !pattry(held, text))
			return 1;
		    if (storage[j] & PAT_ZDUP)
			freepatprog(held);
		}
		++checks;
	    }
	}
    }
    /* Switch back to the wildcard compiler and the header-only ANY program. */
    memset(text, 'x', 50000);
    text[50000] = '\0';
    held = patcompile(text, PAT_ZDUP, NULL);
    if (!held)
	return 1;
    {
	char *wild = dupstring("prefix*");
	tokenize(wild);
	p = patcompile(wild, PAT_STATIC, NULL);
    }
    if (!p || !pattry(p, "prefix-tail") || pattry(p, "other"))
	return 1;
    p = patcompile(dupstring(""), PAT_ANY | PAT_STATIC, NULL);
    if (!p || !(p->flags & PAT_ANY) || p->size != p->startoff ||
	!pattry(p, "anything") || !pattry(held, text))
	return 1;
    freepatprog(held);
    printf("%d literal checks and compiler transitions passed\n", checks);
    return 0;
}

static int
stats(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    struct mallinfo2 m = mallinfo2();
    printf("%s %zu %zu %zu %zu\n", args[0], m.arena, m.uordblks, m.fordblks, m.hblkhd);
    fflush(stdout);
    return 0;
}

static struct builtin builtins[] = {
    BUILTIN("literal-probe", 0, check, 0, 0, 0, NULL, NULL),
    BUILTIN("literal-stats", 0, stats, 1, 1, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 2 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
