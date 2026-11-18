/* Exercise live prefixes and full-capacity pushes through the matching SDK. */
#include "zsh.mdh"

static struct {
    unsigned char *address;
    unsigned char prefix[CMDSTACKSZ];
    int depth;
} frames[12];
static unsigned int active;

static int
probe(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int i, depth = cmdsp;
    unsigned int n;

    if (!cmdstack || depth < 0 || depth > CMDSTACKSZ)
	return 1;
    if (!strcmp(*args, "enter")) {
	if (active == sizeof(frames) / sizeof(frames[0]))
	    return 1;
	for (n = 0; n < active; ++n)
	    if (frames[n].address == cmdstack)
		return 1;
	frames[active].address = cmdstack;
	frames[active].depth = depth;
	memcpy(frames[active++].prefix, cmdstack, depth);
	for (i = depth; i < CMDSTACKSZ; ++i)
	    cmdpush(CS_QUOTE);
	cmdpush(CS_DQUOTE);
	if (cmdsp != CMDSTACKSZ || (depth < CMDSTACKSZ && cmdstack[CMDSTACKSZ-1] != CS_QUOTE))
	    return 1;
	while (cmdsp > depth)
	    cmdpop();
	return 0;
    }
    if (!strcmp(*args, "leave") && active) {
	n = --active;
	return cmdstack != frames[n].address || depth != frames[n].depth ||
	    memcmp(cmdstack, frames[n].prefix, depth) != 0;
    }
    if (!strcmp(*args, "replace")) {
	unsigned char *copy = (unsigned char *)zalloc(CMDSTACKSZ);
	memcpy(copy, cmdstack, depth);
	free(cmdstack);
	cmdstack = copy;
	return 0;
    }
    return 1;
}

static struct builtin builtins[] = {
    BUILTIN("stack-probe", 0, probe, 1, 1, 0, NULL, NULL)
};
static struct features features = { .bn_list = builtins, .bn_size = 1 };
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***out) { *out = featuresarray(m, &features); return 0; }
int enables_(Module m, int **out) { return handlefeatures(m, &features, out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
