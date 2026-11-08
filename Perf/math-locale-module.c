/* Native arithmetic/locale fixture, compiled with pristine configured headers. */
#include "zsh.mdh"
#include <fenv.h>
#include <inttypes.h>
#include <stdint.h>

static unsigned checks;
static uint64_t digest;
static char *global_locale_name;
static locale_t thread_locale;

static void
mix(uint64_t value)
{
    digest = digest * UINT64_C(1099511628211) + value;
}

static int
check_literal(const char *text)
{
    char clean[256], *to=clean, *end, *numeric;
    const char *from=text;
    int negate=0, offset;
    while (*from) { if (*from != '_') *to++=*from; from++; }
    *to=0;
    numeric=clean;
    if (*numeric == '-' || *numeric == '+') { negate=*numeric=='-'; numeric++; }
    for (offset=0; offset<=3; offset+=3) {
	size_t n=strlen(text), bytes=n+1+offset;
	char *allocation=zalloc(bytes), *s=allocation+offset, *before=zalloc(bytes);
#ifdef USE_LOCALE
	char *saved_numeric;
#endif
	double expected;
	mnumber actual;
	uint64_t expected_bits=0, actual_bits=0;
	int expected_error, actual_error, expected_exceptions, actual_exceptions;
	int expected_errno, actual_errno;
	memset(allocation,0xa5,bytes); memcpy(s,text,n+1); memcpy(before,allocation,bytes);
	pushheap();
	/* Oracle: the released conversion sequence, including global-only
	 * LC_NUMERIC switching. The lexer parses unsigned text then negates. */
	errno=E2BIG;
	feclearexcept(FE_ALL_EXCEPT);
#ifdef USE_LOCALE
	saved_numeric=dupstring(setlocale(LC_NUMERIC,NULL));
	setlocale(LC_NUMERIC,"POSIX");
#endif
	expected=strtod(numeric,&end);
#ifdef USE_LOCALE
	if (saved_numeric) setlocale(LC_NUMERIC,saved_numeric);
#endif
	if (negate) expected=-expected;
	expected_errno=errno;
	expected_exceptions=fetestexcept(FE_ALL_EXCEPT);
	expected_error=!*numeric || end==numeric || *end;
	memcpy(&expected_bits,&expected,sizeof(expected));
	errflag=0;
	errno=E2BIG;
	feclearexcept(FE_ALL_EXCEPT);
	actual=matheval(s);
	actual_errno=errno;
	actual_exceptions=fetestexcept(FE_ALL_EXCEPT);
	actual_error=!!errflag;
	if (actual.type==MN_FLOAT) memcpy(&actual_bits,&actual.u.d,sizeof(actual.u.d));
	checks++;
	if (actual_error != expected_error ||
	    (expected_error ? (actual.type!=MN_INTEGER || actual.u.l!=0) :
		(actual.type!=MN_FLOAT || expected_bits!=actual_bits)) ||
	    actual_exceptions!=expected_exceptions || actual_errno!=expected_errno ||
	    strcmp(setlocale(LC_ALL,NULL),global_locale_name) ||
	    uselocale((locale_t)0)!=thread_locale || memcmp(before,allocation,bytes)) {
	    fprintf(stderr,"literal mismatch: %s offset=%d err=%d/%d type=%d bits=%" PRIx64 "/%" PRIx64 " exceptions=%d/%d errno=%d/%d\n",
		text,offset,actual_error,expected_error,actual.type,actual_bits,expected_bits,
		actual_exceptions,expected_exceptions,actual_errno,expected_errno);
	    errflag=0; popheap(); zfree(before,bytes); zfree(allocation,bytes); return 1;
	}
	mix(actual.type); mix(expected_error ? 0 : actual_bits); mix(actual_error);
	mix(actual_exceptions); mix(actual_errno);
	errflag=0;
	popheap(); zfree(before,bytes); zfree(allocation,bytes);
    }
    return 0;
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const char *fixed[]={"0.0","-0.0","+0.0",".0","-.0","1.","-1.","1e0",
	"01e1","0001.25","1.25e+03","1.7976931348623157e308","1.7976931348623159e308",
	"4.9406564584124654e-324","2.2250738585072014e-308","1e-4000","1e4000",
	"-1e4000","-1e-4000","1_2.3_4e+2","-0_0.0","0.1","9007199254740993.0",
	"18446744073709551617e0"};
    static const char *whole[]={"0","1","2","7","9","10","12345",
	"9007199254740991","9007199254740993","18446744073709551615"};
    static const char *fraction[]={"0","1","1234567890123456789"};
    static const int exponents[]={-400,-325,-324,-323,-309,-308,-307,-100,-1,0,1,17,100,307,308,309,400};
    static const int rounds[]={FE_TONEAREST,FE_DOWNWARD,FE_UPWARD,FE_TOWARDZERO};
    unsigned r, option, i, j, k, sign;
    int failed=0, saved_noerrs=noerrs, saved_err=errflag, saved_errno=errno;
    int saved_force=opts[FORCEFLOAT], saved_octal=opts[OCTALZEROES];
    locale_t original=uselocale((locale_t)0), private_locale=(locale_t)0;
    fenv_t original_fenv;
    char buffer[256];

    fegetenv(&original_fenv);
    queue_signals();
    noerrs=1;
    if (strcmp(args[0],"global")) {
	private_locale=newlocale(LC_ALL_MASK,args[0],(locale_t)0);
	if (!private_locale || !uselocale(private_locale)) {
	    fprintf(stderr,"Cannot set fixture thread locale %s\n",args[0]); failed=1;
	}
    }
    thread_locale=uselocale((locale_t)0);
    global_locale_name=ztrdup(setlocale(LC_ALL,NULL));
    digest=0; checks=0;
    for (r=0; r<4 && !failed; r++) {
	if (fesetround(rounds[r])) { failed=1; break; }
	for (option=0; option<2 && !failed; option++) {
	    opts[FORCEFLOAT]=option;
	    opts[OCTALZEROES]=option;
	    for (i=0; i<sizeof(fixed)/sizeof(fixed[0]) && !failed; i++)
		failed=check_literal(fixed[i]);
	    for (i=0; i<10 && !failed; i++)
	    for (j=0; j<3 && !failed; j++)
	    for (k=0; k<sizeof(exponents)/sizeof(exponents[0]) && !failed; k++)
	    for (sign=0; sign<2 && !failed; sign++) {
		snprintf(buffer,sizeof(buffer),"%s%s.%se%+d",sign ? "-" : "",whole[i],fraction[j],exponents[k]);
		failed=check_literal(buffer);
	    }
	    if (!failed) {
		short saved=typtab['\v'];
		typtab['\v'] |= IDIGIT;
		failed=check_literal("\v1.25");
		if (!failed) failed=check_literal("\v1e2");
		typtab['\v']=saved;
	    }
	}
    }
    zsfree(global_locale_name);
    uselocale(original);
    if (private_locale) freelocale(private_locale);
    opts[FORCEFLOAT]=saved_force; opts[OCTALZEROES]=saved_octal;
    noerrs=saved_noerrs; errflag=saved_err;
    unqueue_signals();
    fesetenv(&original_fenv); errno=saved_errno;
    if (failed) return 1;
    printf("checks=%u digest=%" PRIu64 "\n",checks,digest); fflush(stdout);
    return 0;
}

static struct builtin bintab[]={BUILTIN("psh-math-locale-check",0,bin_check,1,1,0,NULL,NULL)};
static struct features features={bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m,char ***out) { *out=featuresarray(m,&features); return 0; }
int enables_(Module m,int **out) { return handlefeatures(m,&features,out); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
