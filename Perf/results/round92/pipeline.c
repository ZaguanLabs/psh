/* Observe the saved job name across recursive execstring() calls. */
#include "zsh.mdh"

static char names[][JOBTEXTSIZE] = {"short", "short", "", "", "outer", "", "short"};

static int
descend(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int depth = atoi(args[0]), ok;
    char command[64];

    if (depth < 0 || depth >= (int)(sizeof(names) / sizeof(names[0])))
	return 1;
    execsave();
    ok = !depth || !strcmp(exstack->list_pipe_text, names[depth - 1]);
    if (depth == 5) {
	memset(names[depth], 'x', JOBTEXTSIZE - 1);
	names[depth][JOBTEXTSIZE - 1] = '\0';
    }
    /* Keep the command dispatcher from replacing the name at level one. */
    exstack->pline_level = 2;
    strcpy(exstack->list_pipe_text, names[depth]);
    execrestore();

    if (depth + 1 < (int)(sizeof(names) / sizeof(names[0]))) {
	sprintf(command, "pipeline-probe %d", depth + 1);
	execstring(command, 1, 0, "probe");
	ok &= !lastval;
	execsave();
	ok &= !strcmp(exstack->list_pipe_text, names[depth]);
	execrestore();
    }
    return !ok;
}

static struct builtin builtins[] = {
    BUILTIN("pipeline-probe", 0, descend, 1, 1, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
