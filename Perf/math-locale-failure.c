/* Test-only injection: make creation of the arithmetic C locale fail. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <locale.h>
#include <string.h>

locale_t
newlocale(int mask, const char *name, locale_t base)
{
    static locale_t (*next)(int, const char *, locale_t);
    if (name && !strcmp(name,"C")) { errno=ENOMEM; return (locale_t)0; }
    if (!next) {
        void *symbol=dlsym(RTLD_NEXT,"newlocale");
        memcpy(&next,&symbol,sizeof(next));
    }
    if (!next) { errno=ENOSYS; return (locale_t)0; }
    return next(mask,name,base);
}
