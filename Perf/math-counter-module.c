/* Complete counter evaluations through the legacy native interface. */
#include "zsh.mdh"
#include <signal.h>
static int gets, sets, hashes, comparisons;
static zlong
custom_get(Param pm)
{
    char expression[] = "2+3";
    gets++;
    return pm->u.val + mathevali(expression);
}
static void custom_set(Param pm, zlong value) { sets++; pm->u.val=value; }
static unsigned custom_hash(const char *name) { hashes++; return hasher(name); }
static int custom_compare(const char *a, const char *b) {
    comparisons++; return strcmp(a,b);
}
static const struct gsu_integer custom_gsu={custom_get,custom_set,stdunsetfn};
static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    int mode, failed=0, original_noerrs=noerrs;
    for (mode=0; mode<8; mode++) {
        char expression[]="i++";
        short original_plus=typtab[(unsigned char)'+'];
        Param pm;
        mnumber result;
        int before_queue, after_queue, error;
        unsetparam("i");
        pm=createparam("i",PM_INTEGER);
        if (!pm) { failed=1; break; }
        pm->node.flags &= ~PM_UNSET;
        pm->u.val=mode==6 ? ZLONG_MAX : 41;
        gets=sets=hashes=comparisons=0;
        if (mode==1) pm->gsu.i=&custom_gsu;
        if (mode==2) paramtab->hash=custom_hash;
        if (mode==3) paramtab->cmpnodes=custom_compare;
        if (mode==4) typtab[(unsigned char)'+'] |= IBLANK;
        if (mode==5) typtab[(unsigned char)'+'] |= IIDENT;
        if (mode==7) { queue_signals(); kill(getpid(),SIGUSR1); }
        before_queue=queue_signal_level();
        noerrs=1; errflag=0;
        result=matheval(expression);
        after_queue=queue_signal_level();
        error=errflag; errflag=0; noerrs=original_noerrs;
        paramtab->hash=hasher; paramtab->cmpnodes=strcmp;
        typtab[(unsigned char)'+']=original_plus;
        pm->gsu.i=&stdinteger_gsu;
        if (before_queue!=after_queue) failed=1;
        if (mode==1 && (gets!=1 || sets!=1 || pm->u.val!=47)) failed=1;
        if (mode==2 && hashes<2) failed=1;
        if (mode==3 && comparisons<2) failed=1;
        printf("mode=%d type=%d result=%lld value=%lld error=%d queue=%d gets=%d sets=%d callbacks=%d failed=%d\n",
            mode,result.type,(long long)result.u.l,(long long)pm->u.val,error,
            before_queue,gets,sets,(mode==2 ? hashes>=2 : (mode==3 ? comparisons>=2 : 0)),failed);
        fflush(stdout);
        if (mode==7) unqueue_signals();
        if (failed) break;
    }
    noerrs=original_noerrs;
    unsetparam("i");
    return failed;
}
static struct builtin bintab[]={BUILTIN("psh-math-counter-check",0,bin_check,0,0,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
