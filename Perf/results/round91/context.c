/* Check nested full and partial saves through the native module interface. */
#include "zsh.mdh"

static int
check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    int outer, inner, ok = 1;
    int history = stophist, lexer = lexstop, parser = incmdpos;
    unsigned char *commands = cmdstack;
    int depth = cmdsp;
    unsigned char *outer_commands;

    queue_signals();
    for (outer = 0; outer < 8; ++outer) {
        for (inner = 0; inner < 8; ++inner) {
            stophist = history;
            lexstop = lexer;
            incmdpos = parser;
            zcontext_save_partial(outer);
            outer_commands = cmdstack;
            ok &= (outer_commands != commands) == !!(outer & ZCONTEXT_HIST);
            stophist = 11;
            lexstop = 12;
            incmdpos = 13;

            zcontext_save_partial(inner);
            ok &= (cmdstack != outer_commands) == !!(inner & ZCONTEXT_HIST);
            stophist = 21;
            lexstop = 22;
            incmdpos = 23;
            zcontext_restore_partial(inner);
            ok &= cmdstack == outer_commands;
            ok &= stophist == (inner & ZCONTEXT_HIST ? 11 : 21);
            ok &= lexstop == (inner & ZCONTEXT_LEX ? 12 : 22);
            ok &= incmdpos == (inner & ZCONTEXT_PARSE ? 13 : 23);

            zcontext_restore_partial(outer);
            ok &= cmdstack == commands && cmdsp == depth;
            ok &= stophist == (outer & ZCONTEXT_HIST ? history :
                               inner & ZCONTEXT_HIST ? 11 : 21);
            ok &= lexstop == (outer & ZCONTEXT_LEX ? lexer :
                              inner & ZCONTEXT_LEX ? 12 : 22);
            ok &= incmdpos == (outer & ZCONTEXT_PARSE ? parser :
                               inner & ZCONTEXT_PARSE ? 13 : 23);
        }
    }
    stophist = history;
    lexstop = lexer;
    incmdpos = parser;
    unqueue_signals();
    return !ok;
}

static struct builtin builtins[] = {
    BUILTIN("context-probe", 0, check, 0, 0, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
