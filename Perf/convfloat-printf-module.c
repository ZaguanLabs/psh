/* An old-SDK, scope-aware module registering a standard printf conversion. */
#include "zsh.mdh"
#include <dlfcn.h>
#include <locale.h>
#include <printf.h>

static char constructor_result[512];

static int
printf_arguments(const struct printf_info *info, size_t count, int *types, int *sizes)
{
    if (count) { types[0]=PA_DOUBLE; sizes[0]=sizeof(double); }
    return 1;
}

static int
printf_float(FILE *stream, const struct printf_info *info, const void *const *args)
{
    const char *mode=uselocale((locale_t)0)==LC_GLOBAL_LOCALE ? "global:" : "private:";
    const char *name=setlocale(LC_NUMERIC,NULL);
    size_t length=strlen(mode)+strlen(name);
    if (fwrite(mode,1,strlen(mode),stream)!=strlen(mode) ||
        fwrite(name,1,strlen(name),stream)!=strlen(name)) return -1;
    return length;
}

__attribute__((constructor)) static void
constructor(void)
{
    register_printf_specifier('f',printf_float,printf_arguments);
    queue_signals(); pushheap();
    strcpy(constructor_result,convfloat(1.25,4,PM_FFLOAT,NULL));
    popheap(); unqueue_signals();
}

static int
bin_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    char *value;
    int (*tracking)(void)=(int (*)(void))dlsym(RTLD_DEFAULT,"psh_float_locale_tracking");
    queue_signals(); pushheap();
    value=convfloat(1.25,4,PM_FFLOAT,NULL);
    printf("constructor=%s\nvalue=%s\ntracking=%d\n",constructor_result,value,tracking ? tracking() : -1);
    popheap(); unqueue_signals();
    return 0;
}

static struct builtin bintab[]={BUILTIN("psh-printf-extension-check",0,bin_check,0,0,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(Module m) {
#ifdef PSH_SCOPE_INDEX_VERSION
    psh_scope_module_ack(m);
#endif
    return 0;
}
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { register_printf_specifier('f',NULL,NULL); return 0; }
