/* Legacy-header parser ownership contract, also called from glob qualifiers. */
#include "zsh.mdh"

static int
check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    Eprog p;
    int mode, ok = 1;
    for (mode = 0; mode < 2; mode++) {
        pushheap();
        if (!mode)
            p = parse_string(dupstring("psh_parser_value=legacy"), 0);
        else {
            zcontext_save();
            inpush(dupstring("psh_parser_value=legacy"), INP_LINENO, NULL);
            strinbeg(0);
            p = parse_list(); /* Intentionally compiled with the old prototype. */
            strinend();
            inpop();
            zcontext_restore();
        }
        if (!p || !(p->flags & EF_HEAP) || p->nref != -1)
            ok = 0;
        if (ok) {
            execode(p, 1, 0, "legacy-parser");
            freeeprog(p); /* A no-op for the legacy arena-backed program. */
            if (p->nref != -1 || !getsparam("psh_parser_value") ||
                strcmp(getsparam("psh_parser_value"), "legacy"))
                ok = 0;
            /* The old contract permits reuse until popheap(). */
            execode(p, 1, 0, "legacy-parser-reuse");
        }
        popheap();
    }
    if (!ok)
        zerr("legacy parser ownership changed");
    return !ok;
}

static struct builtin bintab[] = {
    BUILTIN("psh-glob-parser-check", 0, check, 0, 0, 0, NULL, NULL)
};
static struct features features = {bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
