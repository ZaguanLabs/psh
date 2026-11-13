#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <errno.h>
#include <locale.h>

static int mode;
static unsigned long failures;
void psh_printf_set_fault(int value) { mode=value; }
unsigned long psh_printf_faults(void) { return failures; }

#ifdef PSH_LINKED_FAULTS
extern locale_t __real_newlocale(int, const char *, locale_t);
extern locale_t __real_uselocale(locale_t);
#define newlocale __wrap_newlocale
#define uselocale __wrap_uselocale
#endif

locale_t newlocale(int mask, const char *name, locale_t base)
{
#ifdef PSH_LINKED_FAULTS
    locale_t (*real_newlocale)(int,const char *,locale_t)=__real_newlocale;
#else
    static locale_t (*real_newlocale)(int,const char *,locale_t);
    if (!real_newlocale) real_newlocale=dlsym(RTLD_NEXT,"newlocale");
#endif
    if (mode==1) { failures++; errno=ENOMEM; return (locale_t)0; }
    return real_newlocale(mask,name,base);
}

locale_t uselocale(locale_t object)
{
#ifdef PSH_LINKED_FAULTS
    locale_t (*real_uselocale)(locale_t)=__real_uselocale;
#else
    static locale_t (*real_uselocale)(locale_t);
    if (!real_uselocale) real_uselocale=dlsym(RTLD_NEXT,"uselocale");
#endif
    if (mode==2 && object && object!=LC_GLOBAL_LOCALE) {
        failures++; errno=EINVAL; return (locale_t)0;
    }
    return real_uselocale(object);
}
