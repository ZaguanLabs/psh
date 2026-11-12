/* Legacy native table edits must not make token metadata authoritative. */
#include "zsh.mdh"
static short original;
static int changed;
static int
bin_mode(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), int mode)
{
    if (!mode) {
        if (!changed)
            original = typtab[(unsigned char)Tilde];
        typtab[(unsigned char)Tilde] &= ~ITOK;
        changed = 1;
    } else if (changed) {
        typtab[(unsigned char)Tilde] = original;
        changed = 0;
    }
    return 0;
}
static struct builtin bintab[] = {
    BUILTIN("psh-clear-tilde-token",0,bin_mode,0,0,0,NULL,NULL),
    BUILTIN("psh-restore-tilde-token",0,bin_mode,0,0,1,NULL,NULL)
};
static struct features features={bintab,2,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) {
    if (changed) { typtab[(unsigned char)Tilde]=original; changed=0; }
    return setfeatureenables(m,&features,NULL);
}
int finish_(UNUSED(Module m)) { return 0; }
