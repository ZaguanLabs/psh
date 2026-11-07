#include "render.h"
#include <assert.h>
#include <locale.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint32_t state=0x1badd00d;
static unsigned random_u32(void) {
    state ^= state<<13; state ^= state>>17; state ^= state<<5; return state;
}
static void check_policy(const char *input, size_t size, unsigned width, int color,
                         enum zmd_width_policy policy, enum zmd_cluster_styles styles) {
    struct zmd_options options={width,color,1,1,policy,styles,0};
    char *output=NULL; size_t length=0; const char *error=NULL;
    int rc=zmd_render(input,size,&options,&output,&length,&error);
    struct zmd_document *document=NULL;
    const char *document_error=NULL;
    int structured_rc=zmd_render_document(input,size,&options,&document,&document_error);
    assert((rc!=0)==(structured_rc!=0));
    if (!structured_rc) {
        assert(document && !document_error && document->count<=ZMDOWN_PAIR_LIMIT);
        for (size_t i=0;i<document->count*2;++i) {
            const unsigned char *s=(const unsigned char *)document->pairs[i];
            for (;*s;++s) assert(*s>=32 || *s=='\n' || *s=='\t');
        }
    } else assert(!document && document_error);
    zmd_document_free(document);
    if (rc) {
        assert(error && !output);
        if (!strcmp(error,"unbalanced Markdown parser callbacks")) {
            FILE *f=fopen(".build/parser-repro.bin","wb");
            assert(f); fwrite(input,1,size,f); fclose(f);
            fprintf(stderr,"unbalanced callbacks; reproducer in .build/parser-repro.bin\n");
            abort();
        }
        return;
    }
    assert(output && !error && output[length]==0);
    for (size_t i=0;i<length;++i) {
        unsigned char byte=(unsigned char)output[i];
        if (byte==27) {
            assert(color && ++i<length && output[i]=='[');
            do { ++i; } while (i<length && ((output[i]>='0' && output[i]<='9') || output[i]==';'));
            assert(i<length && output[i]=='m');
        } else assert(byte>=32 || byte=='\n');
    }
    free(output);
}
static void check(const char *input, size_t size, unsigned width, int color) {
    for (int policy=0;policy<2;++policy) for (int styles=0;styles<2;++styles)
        check_policy(input,size,width,color,(enum zmd_width_policy)policy,(enum zmd_cluster_styles)styles);
}
int main(void) {
    char buffer[2048];
    const char alphabet[]="abc XYZ0123*_*`~\\[]()!<>|:#&;=+-\n\t\r\033\a";
    assert(setlocale(LC_ALL,"")!=NULL);
    for (unsigned run=0;run<4000;++run) {
        size_t length=random_u32()%sizeof(buffer);
        for (size_t i=0;i<length;++i)
            buffer[i]=(run%3==0) ? (char)random_u32() : alphabet[random_u32()%(sizeof(alphabet)-1)];
        check(buffer,length,1+random_u32()%100,run%2);
    }
    const char *table="| A | B |\n|---|---|\n| **界👩‍💻🇳🇴** | `é\ttext` |\n";
    for (unsigned width=1;width<100;++width) check(table,strlen(table),width,1);
    /* An odd-sized, oversized arena string followed by aligned tree nodes.
     * Also cross the glyph, copied input, and node limits on failure paths. */
    char *large=malloc(ZMDOWN_INPUT_LIMIT+1);
    assert(large);
    memset(large,'a',65537); memcpy(large+65537,"\n\n**tail**",10);
    check(large,65547,80,1);
    memset(large,'x',2u*1024u*1024u+1);
    check_policy(large,2u*1024u*1024u,4096,0,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE);
    check_policy(large,2u*1024u*1024u+1,4096,0,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE);
    for (size_t i=0;i<40000;++i) memcpy(large+i*4,"*x* ",4);
    check_policy(large,160000,80,0,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE);
    memset(large,' ',ZMDOWN_INPUT_LIMIT+1);
    check_policy(large,ZMDOWN_INPUT_LIMIT,80,0,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE);
    check_policy(large,ZMDOWN_INPUT_LIMIT+1,80,0,ZMD_WIDTH_UNICODE,ZMD_STYLES_PRESERVE);
    free(large);
    puts("4,000 deterministic inputs and 99 Unicode table widths passed across four policy combinations in scalar and structured modes");
    puts("Oversized arena allocations and glyph/node/input limit boundaries passed");
    return 0;
}
