/* Test-only public scalar API checks, using exact-ending getter allocations. */
#include "zsh.mdh"

static char fixture_name[] = "psh_index_fixture_value";
static char *fixture_data;
static long getter_calls;

static char *
fixture_get(UNUSED(Param pm))
{
    getter_calls++;
    return fixture_data ? fixture_data : "";
}

static const struct gsu_scalar fixture_gsu =
    { fixture_get, strsetfn, stdunsetfn };

static int
check_input(const char *raw, int rawlen, int alignment, long *checks)
{
    char *encoded = metafy((char *)raw, rawlen, META_DUP);
    size_t len = strlen(encoded), size = alignment + len + 1;
    char *allocation = malloc(size), *p;
    int *offsets = malloc((len + 1) * sizeof(int));
    int characters = 0, width, k, sign, failed = 0;
    int indices[13] = { 1, 7, 8, 9, 15, 16, 17, 31, 32, 33, 0, 0, 0 };
    if (!allocation || !offsets) {
        free(allocation);
        free(offsets);
        zsfree(encoded);
        return 1;
    }
    memset(allocation, 'Z', size);
    fixture_data = allocation + alignment;
    memcpy(fixture_data, encoded, len + 1);
    /* The unchanged public converter supplies the reference boundaries.
     * No grouped probes or optimized indexing routine is used here. */
    MB_METACHARINIT();
    for (p = fixture_data; *p; p += width) {
        offsets[characters++] = p - fixture_data;
        width = MB_METACHARLEN(p);
        if (width <= 0 || p + width > fixture_data + len) {
            failed = 1;
            goto done;
        }
    }
    offsets[characters] = len;
    if (MB_METASTRLEN(fixture_data) != characters) {
        fprintf(stderr, "fixture character counters disagree\n");
        failed = 1;
        goto done;
    }
    indices[10] = characters ? characters : 1;
    indices[11] = characters + 1;
    indices[12] = characters + 8;
    pushheap();
    for (k = 0; k < 13 && !failed; k++) {
        for (sign = -1; sign <= 1; sign += 2) {
            char reference[96], *cursor, *result;
            struct value value;
            Value v;
            int index = sign * indices[k];
            int position = index > 0 ? index - 1 : characters + index;
            int bytes = position >= 0 && position < characters ?
                offsets[position + 1] - offsets[position] : 0;
            sprintf(reference, "%s[%d]", fixture_name, index);
            cursor = reference;
            v = getvalue(&value, &cursor, 1);
            result = v ? getstrvalue(v) : NULL;
            if (!v || *cursor || !result || strlen(result) != (size_t)bytes ||
                (bytes && memcmp(result, fixture_data + offsets[position], bytes))) {
                fprintf(stderr, "scalar index alignment=%d rawlen=%d index=%d\n",
                        alignment, rawlen, index);
                failed = 1;
                break;
            }
            (*checks)++;
        }
    }
    popheap();
    if (memcmp(fixture_data, encoded, len + 1))
        failed = 1;
    for (k = 0; k < alignment; k++)
        if (allocation[k] != 'Z')
            failed = 1;
done:
    fixture_data = NULL;
    free(allocation);
    free(offsets);
    zsfree(encoded);
    return failed;
}

static int
bin_fixture(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const int large[] = { 127, 128, 129, 255, 256, 257, 1023, 1024, 1025 };
    static const int prefixes[] = { 7, 8, 15, 16, 31, 32 };
    char raw[1025];
    Param pm;
    int n, a, k, byte;
    long checks = 0;
    unsetparam(fixture_name);
    pm = createparam(fixture_name, PM_SCALAR);
    if (!pm) return 1;
    pm->gsu.s = &fixture_gsu;
    pm->node.flags &= ~PM_UNSET;
    getter_calls = 0;
    for (n = 0; n < (int)sizeof(raw); n++)
        raw[n] = 'a' + n % 26;
    for (a = 0; a < 8; a++) {
        for (n = 0; n <= 65; n++)
            if (check_input(raw, n, a, &checks)) goto fail;
        for (k = 0; k < 9; k++)
            if (check_input(raw, large[k], a, &checks)) goto fail;
    }
    /* Every raw byte immediately after an ASCII block boundary, with
     * proper metafication and a suffix preventing incomplete final input. */
    for (a = 0; a <= 7; a += 7) {
        for (k = 0; k < 6; k++) {
            n = prefixes[k];
            for (byte = 0; byte < 256; byte++) {
                memset(raw, 'x', sizeof(raw));
                raw[n] = (char)byte;
                if (check_input(raw, n + 18, a, &checks)) goto fail;
            }
            memset(raw, 'x', sizeof(raw));
            memcpy(raw + n, "\303\251\347\225\214\360\237\230\200", 9);
            if (check_input(raw, n + 26, a, &checks)) goto fail;
        }
    }
    unsetparam(fixture_name);
    printf("checks=%ld getters=%ld\n", checks, getter_calls);
    fflush(stdout);
    return 0;
fail:
    unsetparam(fixture_name);
    return 1;
}

static struct builtin bintab[] = {
    BUILTIN("psh-index-check", 0, bin_fixture, 0, 0, 0, NULL, NULL)
};
static struct features module_features = {
    bintab, 1, NULL, 0, NULL, 0, NULL, 0, 0
};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) {
    *features = featuresarray(m, &module_features); return 0;
}
int enables_(Module m, int **enables) {
    return handlefeatures(m, &module_features, enables);
}
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) {
    unsetparam(fixture_name);
    return setfeatureenables(m, &module_features, NULL);
}
int finish_(UNUSED(Module m)) { return 0; }
