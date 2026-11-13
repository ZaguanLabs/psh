/* Exercise a scalar getter re-entering associative-array expansion. */
#include "zsh.mdh"
static int calls, pattern_mode, inner_count = 2, leaf_calls, provider_calls;
static char *leaf_get(Param pm)
{
    char **values = gethparam("psh_reentry_leaf");
    leaf_calls++;
    if (!values || arrlen(values) != 3)
        zerr("third-level associative expansion failed");
    return strgetfn(pm);
}
static const struct gsu_scalar leaf_gsu = {leaf_get, strsetfn, stdunsetfn};
static char *nested_get(Param pm)
{
    char **values = gethparam("psh_reentry_inner");
    calls++;
    if (!values || arrlen(values) != inner_count)
        zerr("nested associative expansion failed");
    if (pattern_mode)
        execstring(": \"${psh_reentry_inner[(R)*]}\"", 1, 0, "nested-search");
    return strgetfn(pm);
}
static const struct gsu_scalar nested_gsu = {nested_get, strsetfn, stdunsetfn};
static int pair_ok(char **values)
{
    return values && arrlen(values) == 2 &&
        ((!strcmp(values[0], "A") && !strcmp(values[1], "B")) ||
         (!strcmp(values[0], "B") && !strcmp(values[1], "A")));
}

static int matrix(void)
{
    static const int sizes[] = {0, 1, 3, 65, 4096, 4097};
    unsigned i;
    int mode, checks = 0;
    for (i = 0; i < sizeof(sizes) / sizeof(*sizes); i++) {
        Param inner, member = NULL;
        char setup[512];
        inner_count = sizes[i];
        sprintf(setup, "psh_reentry_inner=(); "
                "() { local -i i; for ((i=0; i<%d; i++)); do "
                "psh_reentry_inner[k$i]=V$i; done; }; "
                "typeset -A psh_reentry_leaf=(p P q Q r R)", inner_count);
        execstring(setup, 1, 0, "matrix-setup");
        inner = (Param)paramtab->getnode(paramtab, "psh_reentry_inner");
        if (inner_count) {
            member = (Param)inner->u.hash->getnode(inner->u.hash, "k0");
            member->gsu.s = &leaf_gsu;
        }
        for (mode = 0; mode < 2; mode++) {
            int ok;
            calls = leaf_calls = 0;
            pattern_mode = mode;
            ok = pair_ok(gethparam("psh_reentry_outer"));
            if (!ok || calls != 1 || (inner_count && !leaf_calls))
                return 0;
            /* These shell expansions exercise getvaluearr's explicit count
             * result, as well as key/value flags and empty match results. */
            execstring(
                "psh_reentry_check=bad; () { "
                "local -a v=(\"${(@v)psh_reentry_outer}\"); "
                "[[ ${(j:,:)${(o)v}} == A,B ]] || return 1; "
                "v=(\"${(@kv)psh_reentry_outer}\"); "
                "[[ $#v == 4 && ${(j:,:)${(o)v}} == A,B,a,b ]] || return 1; "
                "v=(\"${(@)psh_reentry_outer[(R)*]}\"); "
                "[[ $#v == 2 && ${(j:,:)${(o)v}} == A,B ]] || return 1; "
                "v=(\"${(@)psh_reentry_outer[(R)missing]}\"); "
                "[[ $#v == 0 ]] || return 1; "
                "[[ ${psh_reentry_outer[(R)A]} == A && "
                "${(k)psh_reentry_outer[(R)A]} == a && "
                "${psh_reentry_outer[(K)a]} == A ]] || return 1; "
                "} && psh_reentry_check=ok", 1, 0, "matrix-expansions");
            if (errflag || strcmp(getsparam("psh_reentry_check"), "ok"))
                return 0;
            checks++;
        }
        if (member)
            member->gsu.s = &stdscalar_gsu;
    }
    printf("matrix-checks=%d ok=1\n", checks);
    return 1;
}

static void generated_scan(HashTable ht, ScanFunc fn, int flags)
{
    provider_calls++;
    fn(ht->getnode(ht, "a"), flags);
}

static int boundaries(void)
{
    Param outer = (Param)paramtab->getnode(paramtab, "psh_reentry_outer");
    Param member = (Param)outer->u.hash->getnode(outer->u.hash, "b");
    int queued, checks = 0;
    for (queued = 0; queued < 2; queued++) {
        int good, entry_queue = queue_signal_level();
        char **values;
        if (queued) queue_signals();
        member->node.flags |= PM_UNSET;
        values = gethparam("psh_reentry_outer");
        good = values && arrlen(values) == 1 && !strcmp(values[0], "A");
        member->node.flags &= ~PM_UNSET;
        if (good) {
            provider_calls = 0;
            outer->u.hash->scantab = generated_scan;
            values = gethparam("psh_reentry_outer");
            good = provider_calls == 2 && values && arrlen(values) == 1 &&
                !strcmp(values[0], "A");
            outer->u.hash->scantab = NULL;
        }
        if (queued) unqueue_signals();
        if (!good || queue_signal_level() != entry_queue)
            return 0;
        checks++;
    }
    printf("boundary-checks=%d ok=1\n", checks);
    return 1;
}
static int check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    Param outer, member;
    char **values;
    int count, ok, direct_ok;
    inner_count=2;
    execstring("typeset -A psh_reentry_outer=(a A b B) psh_reentry_inner=(x X y Y)", 1, 0, "fixture");
    outer=(Param)paramtab->getnode(paramtab,"psh_reentry_outer");
    member=(Param)outer->u.hash->getnode(outer->u.hash,"a");
    member->gsu.s=&nested_gsu;
    calls=0;
    pattern_mode=0;
    values=gethparam("psh_reentry_outer");
    count=arrlen(values);
    ok=count==2 && calls==1 && pair_ok(values);
    printf("count=%d calls=%d ok=%d\n",count,calls,ok);
    if (!ok) {
        int i;
        for (i = 0; i < count; i++)
            printf("unexpected[%d]=%s\n", i, values[i]);
    }
    fflush(stdout);
    direct_ok=ok;
    /* Run this only after the basic test passes: the unfixed implementation
     * also loses the outer compiled pattern and may dereference NULL. */
    if (ok) {
        pattern_mode=1;
        execstring("psh_reentry_result=\"${psh_reentry_outer[(R)A]}\"", 1, 0, "outer-search");
        ok=!errflag && !strcmp(getsparam("psh_reentry_result"),"A");
        printf("pattern-ok=%d\n",ok); fflush(stdout);
    }
    if (ok)
        ok=matrix();
    if (ok)
        ok=boundaries();
    member->gsu.s=&stdscalar_gsu;
    unsetparam("psh_reentry_outer"); unsetparam("psh_reentry_inner");
    unsetparam("psh_reentry_result");
    unsetparam("psh_reentry_leaf"); unsetparam("psh_reentry_check");
    return !(ok && direct_ok);
}
static struct builtin bintab[]={BUILTIN("psh-hash-reentry-check",0,check,0,0,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
