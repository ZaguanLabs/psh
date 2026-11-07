/* Zsh integration. The rendering core has no dependency on the shell ABI. */
#include "zmdown.mdh"
#include "zmdown.pro"
#include "render.h"
#include "grapheme.h"
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

static const char help_text[] =
    "Usage: zmdown [options] [FILE|-]\n"
    "       zmdown [options] --text MARKDOWN\n\n"
    "Render Markdown in a Zsh script or terminal. With no input, read stdin.\n\n"
    "  -w, --width N         Wrap at N terminal cells (default: terminal or 80)\n"
    "  -c, --color MODE      auto, always, never (default: auto)\n"
    "      --width-policy P  unicode (default), wcwidth-sum\n"
    "      --cluster-styles M preserve (default), first-base\n"
    "      --soft-breaks M   space (default), newline\n"
    "      --plain           Same as --color never\n"
    "  -v, --variable NAME   Assign output to an ordinary scalar; do not print\n"
    "      --spans NAME      Assign schema 1 lines/spans to a declared association\n"
    "      --features        Show machine-readable feature tokens\n"
    "      --text MARKDOWN   Render a string instead of a file or stdin\n"
    "      --dialect NAME    gfm (default) or commonmark\n"
    "      --links MODE      show (default) or hide link destinations\n"
    "  -h, --help            Show this help\n"
    "      --version         Show version\n"
    "      --                End options; permits filenames starting with -\n";

static int valid_name(const char *s) {
    const unsigned char *p=(const unsigned char *)s;
    if (!((*p>='a' && *p<='z') || (*p>='A' && *p<='Z') || *p=='_')) return 0;
    for (++p;*p;++p)
        if (!((*p>='a' && *p<='z') || (*p>='A' && *p<='Z') ||
              (*p>='0' && *p<='9') || *p=='_')) return 0;
    return 1;
}
static int valid_target(char *name) {
    Param pm;
    if (!valid_name(name)) return 0;
    pm=(Param)paramtab->getnode(paramtab,name);
    if (!pm) return 1;
    return PM_TYPE(pm->node.flags)==PM_SCALAR &&
        !(pm->node.flags & (PM_SPECIAL|PM_READONLY|PM_TIED|PM_LEFT|PM_RIGHT_B|
                           PM_RIGHT_Z|PM_LOWER|PM_UPPER));
}
/* Use getnode2: validation must not autoload special parameter modules. */
static Param association_target(char *name) {
    Param pm; HashNode hn; int i;
    if (!valid_name(name)) return NULL;
    pm=(Param)paramtab->getnode2(paramtab,name);
    if (!pm || PM_TYPE(pm->node.flags)!=PM_HASHED ||
        (pm->node.flags & (PM_SPECIAL|PM_READONLY|PM_TIED|PM_AUTOLOAD|PM_LEFT|
                          PM_RIGHT_B|PM_RIGHT_Z|PM_LOWER|PM_UPPER)) ||
        pm->gsu.h!=&stdhash_gsu) return NULL;
    /* Replacing a value must not bypass protection on existing elements. */
    if (pm->u.hash) for (i=0;i<pm->u.hash->hsize;++i)
        for (hn=pm->u.hash->nodes[i];hn;hn=hn->next) {
            Param entry=(Param)hn;
            if ((hn->flags & (PM_READONLY|PM_SPECIAL|PM_AUTOLOAD)) ||
                PM_TYPE(hn->flags)!=PM_SCALAR || entry->gsu.s!=&stdscalar_gsu) return NULL;
        }
    return pm;
}
static int publish_document(char *name, struct zmd_document *document) {
    size_t i;
    HashTable table=newparamtable((int)(document->count/2+17),name);
    Param destination;
    /* Ordinary scalar hash nodes: no assignment parser, expansion, or GSU
     * callbacks supplied by a caller. Build off to the side before publication. */
    for (i=0;i<document->count;++i) {
        Param entry=(Param)zshcalloc(sizeof(*entry));
        entry->node.flags=PM_SCALAR|PM_HASHELEM;
        entry->gsu.s=&stdscalar_gsu;
        entry->u.str=metafy(document->pairs[i*2+1],(int)strlen(document->pairs[i*2+1]),META_DUP);
        table->addnode(table,ztrdup(document->pairs[i*2]),entry);
    }
    queue_signals();
    destination=association_target(name);
    if (destination) {
        hashsetfn(destination,table);
        destination->node.flags &= ~PM_UNSET;
#ifdef PM_DEFAULTED
        destination->node.flags &= ~PM_DEFAULTED;
#endif
    } else deleteparamtable(table);
    unqueue_signals();
    return destination ? 0 : 1;
}
static int parse_width(const char *s, unsigned *width) {
    unsigned n=0;
    if (!*s) return 1;
    for (;*s;++s) {
        if (*s<'0' || *s>'9' || n>4096) return 1;
        n=n*10+(unsigned)(*s-'0');
    }
    if (!n || n>4096) return 1;
    *width=n; return 0;
}
static int read_input(int fd, char **input, size_t *length) {
    size_t capacity=8192; char *data=malloc(capacity+1);
    if (!data) return 1;
    *length=0;
    for (;;) {
        ssize_t n;
        if (*length==capacity) {
            char *next;
            if (capacity>=ZMDOWN_INPUT_LIMIT+1u) { free(data); return 2; }
            capacity*=2;
            if (capacity>ZMDOWN_INPUT_LIMIT+1u) capacity=ZMDOWN_INPUT_LIMIT+1u;
            next=realloc(data,capacity+1);
            if (!next) { free(data); return 1; }
            data=next;
        }
        n=read(fd,data+*length,capacity-*length);
        if (n<0) {
            if (errno==EINTR && !errflag) continue;
            free(data); return 1;
        }
        if (!n) break;
        *length+=(size_t)n;
        if (*length>ZMDOWN_INPUT_LIMIT) { free(data); return 2; }
    }
    data[*length]=0; *input=data; return 0;
}

/**/
static int
bin_zmdown(char *name, char **args, UNUSED(Options ops), UNUSED(int func))
{
    struct zmd_options options={0,0,1,1,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE,0};
    char *target=NULL, *spans=NULL, *literal=NULL, *file=NULL, *input=NULL, *rendered=NULL;
    size_t input_length=0, rendered_length=0;
    const char *error=NULL;
    struct zmd_document *document=NULL;
    int color=-1, end_options=0, rc=0, fd=0, meta_length=0;
    for (;*args;++args) {
        char *arg=*args, *value=NULL;
        if (!end_options && !strcmp(arg,"--")) { end_options=1; continue; }
        if (!end_options && (!strcmp(arg,"--help") || !strcmp(arg,"-h"))) {
            return fputs(help_text,stdout)==EOF || fflush(stdout)==EOF;
        }
        if (!end_options && !strcmp(arg,"--version")) {
            return printf("zmdown %s (MD4C 0.5.3+00788b1)\n",ZMDOWN_VERSION)<0 || fflush(stdout)==EOF;
        }
        if (!end_options && !strcmp(arg,"--features")) {
            return printf("spans=%s code-blocks=1 span-roles=1 graphemes=17.0.0 width-policy=%s width-policies=unicode,wcwidth-sum cluster-styles=preserve,first-base soft-breaks=space,newline\n",
                          ZMDOWN_SCHEMA_VERSION,ZMDOWN_WIDTH_POLICY)<0 || fflush(stdout)==EOF;
        }
        if (!end_options && !strcmp(arg,"--plain")) { color=0; continue; }
        if (!end_options && arg[0]=='-' && arg[1] && strcmp(arg,"-")) {
            if (strcmp(arg,"-w") && strcmp(arg,"--width") && strcmp(arg,"-c") &&
                strcmp(arg,"--color") && strcmp(arg,"-v") && strcmp(arg,"--variable") &&
                strcmp(arg,"--width-policy") && strcmp(arg,"--cluster-styles") && strcmp(arg,"--soft-breaks") &&
                strcmp(arg,"--spans") && strcmp(arg,"--text") && strcmp(arg,"--dialect") && strcmp(arg,"--links")) {
                zwarnnam(name,"unknown option (use --help)"); return 2;
            }
            if (!args[1]) { zwarnnam(name,"option requires a value"); return 2; }
            value=*++args;
            if (!strcmp(arg,"-w") || !strcmp(arg,"--width")) {
                if (parse_width(value,&options.width)) { zwarnnam(name,"width must be an integer from 1 to 4096"); return 2; }
            } else if (!strcmp(arg,"-v") || !strcmp(arg,"--variable")) target=value;
            else if (!strcmp(arg,"--spans")) spans=value;
            else if (!strcmp(arg,"--width-policy")) {
                if (!strcmp(value,"unicode")) options.width_policy=ZMD_WIDTH_UNICODE;
                else if (!strcmp(value,"wcwidth-sum")) options.width_policy=ZMD_WIDTH_WCWIDTH_SUM;
                else { zwarnnam(name,"width policy must be unicode or wcwidth-sum"); return 2; }
            } else if (!strcmp(arg,"--cluster-styles")) {
                if (!strcmp(value,"preserve")) options.cluster_styles=ZMD_STYLES_PRESERVE;
                else if (!strcmp(value,"first-base")) options.cluster_styles=ZMD_STYLES_FIRST_BASE;
                else { zwarnnam(name,"cluster styles must be preserve or first-base"); return 2; }
            } else if (!strcmp(arg,"--soft-breaks")) {
                if (!strcmp(value,"space")) options.hard_soft_breaks=0;
                else if (!strcmp(value,"newline")) options.hard_soft_breaks=1;
                else { zwarnnam(name,"soft breaks must be space or newline"); return 2; }
            } else if (!strcmp(arg,"--text")) {
                if (literal) { zwarnnam(name,"specify --text only once"); return 2; }
                literal=value;
            } else if (!strcmp(arg,"--dialect")) {
                if (!strcmp(value,"gfm")) options.gfm=1;
                else if (!strcmp(value,"commonmark")) options.gfm=0;
                else { zwarnnam(name,"dialect must be gfm or commonmark"); return 2; }
            } else if (!strcmp(arg,"--links")) {
                if (!strcmp(value,"show")) options.links=1;
                else if (!strcmp(value,"hide")) options.links=0;
                else { zwarnnam(name,"links must be show or hide"); return 2; }
            } else {
                if (!strcmp(value,"auto")) color=-1;
                else if (!strcmp(value,"always")) color=1;
                else if (!strcmp(value,"never")) color=0;
                else { zwarnnam(name,"color must be auto, always or never"); return 2; }
            }
        } else {
            if (file) { zwarnnam(name,"expected one input file"); return 2; }
            file=arg;
        }
    }
    if (literal && file) { zwarnnam(name,"choose --text or a file, not both"); return 2; }
    if (spans && (target || !association_target(spans))) {
        zwarnnam(name,"--spans requires a declared ordinary writable association and excludes --variable"); return 2;
    }
    if (target && !valid_target(target)) {
        zwarnnam(name,"output variable must be an ordinary writable scalar without formatting attributes"); return 2;
    }
    if (!options.width) {
        struct winsize size;
        options.width=80;
        if (!ioctl(1,TIOCGWINSZ,&size) && size.ws_col && size.ws_col<=4096) options.width=size.ws_col;
    }
    if (color<0) {
        color=0;
        if (!target && !spans) {
            char *no_color=getenv("NO_COLOR"), *term=getenv("TERM");
            color=isatty(1) && !(no_color && *no_color) && !(term && !strcmp(term,"dumb"));
        }
    }
    options.color=color;
    if (literal) {
        /* Zsh strings are metafied and can contain embedded NULs. */
        input=ztrdup(literal); unmetafy(input,&meta_length); input_length=(size_t)meta_length;
    } else {
        if (file && strcmp(file,"-")) {
            char *filename=ztrdup(file);
            unmetafy(filename,&meta_length);
            if ((size_t)meta_length!=strlen(filename)) {
                zsfree(filename); zwarnnam(name,"filename contains a NUL byte"); return 2;
            }
            fd=open(filename,O_RDONLY); zsfree(filename);
            if (fd<0) { zwarnnam(name,"cannot open input: %e",errno); return 1; }
        }
        rc=read_input(fd,&input,&input_length);
        if (fd!=0) close(fd);
        if (rc) { zwarnnam(name,rc==2?"input exceeds 4 MiB":"cannot read input"); return 1; }
    }
    if (spans) rc=zmd_render_document(input,input_length,&options,&document,&error);
    else rc=zmd_render(input,input_length,&options,&rendered,&rendered_length,&error);
    if (literal) zsfree(input); else free(input);
    if (rc) { zwarnnam(name,"%s",error); return 1; }
    if (spans) {
        rc=publish_document(spans,document); zmd_document_free(document);
        if (rc) zwarnnam(name,"structured output destination changed or became unwritable");
    } else if (target) {
        /* Validate again: a signal handler could have changed the destination. */
        queue_signals();
        if (!valid_target(target)) rc=1;
        else if (!setsparam(target,metafy(rendered,(int)rendered_length,META_DUP))) rc=1;
        unqueue_signals();
    } else {
        if (fwrite(rendered,1,rendered_length,stdout)!=rendered_length || fflush(stdout)==EOF) rc=1;
    }
    free(rendered);
    return rc;
}

static struct builtin bintab[] = {
    BUILTIN("zmdown", BINF_HANDLES_OPTS, bin_zmdown, 0, -1, 0, NULL, NULL),
};
static struct features module_features = {
    bintab, sizeof(bintab)/sizeof(*bintab), NULL, 0, NULL, 0, NULL, 0, 0
};
/**/
int
setup_(UNUSED(Module m)) { return 0; }
/**/
int
features_(Module m, char ***features) {
    *features=featuresarray(m,&module_features); return 0;
}
/**/
int
enables_(Module m, int **enables) { return handlefeatures(m,&module_features,enables); }
/**/
int
boot_(UNUSED(Module m)) { return 0; }
/**/
int
cleanup_(Module m) { return setfeatureenables(m,&module_features,NULL); }
/**/
int
finish_(UNUSED(Module m)) { return 0; }
