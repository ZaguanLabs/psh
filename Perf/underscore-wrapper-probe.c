/* Exercise all three outcomes of a shell function wrapper. */
#include "zsh.mdh"

static int
wrap(Eprog prog, FuncWrap next, char *name)
{
    char before[] = ": wrapper-before", after[] = ": wrapper-after";

    if (!strcmp(name, "psh_wrap_pass")) {
        execstring(before, 1, 0, "underscore-probe");
        return 1;
    }
    if (!strcmp(name, "psh_wrap_delegate")) {
        execstring(before, 1, 0, "underscore-probe");
        runshfunc(prog, next, name);
        execstring(after, 1, 0, "underscore-probe");
        return 0;
    }
    if (!strcmp(name, "psh_wrap_skip")) {
        execstring(after, 1, 0, "underscore-probe");
        return 0;
    }
    return 1;
}

static struct funcwrap wrapper[] = { WRAPDEF(wrap) };
static struct features features;
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(Module m) { return addwrapper(m, wrapper); }
int cleanup_(Module m) { return deletewrapper(m, wrapper); }
int finish_(UNUSED(Module m)) { return 0; }
