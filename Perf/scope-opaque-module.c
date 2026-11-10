/* An old-style native module: constructors may change levels without notice. */
#include "zsh.mdh"

static void __attribute__((constructor))
opaque_constructor(void)
{
    Param pm = (Param)gethashnode2(realparamtab, "psh_opaque_ctor_target");
    if (pm) {
        startparamscope();
        pm->level = locallevel;
        endparamscope();
    }
}

static struct features features = {NULL,0,NULL,0,NULL,0,NULL,0,0};
int setup_(Module m) { m->node.flags |= 128; return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
