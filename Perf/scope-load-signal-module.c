/* Unload the just-loaded module from a signal delivered at loader unqueue. */
#include "zsh.mdh"
static struct features features = {NULL,0,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) {
#ifdef PSH_SCOPE_INDEX_VERSION
    psh_scope_module_ack(m);
#endif
    return 0;
}
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { kill(getpid(), SIGUSR1); return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
