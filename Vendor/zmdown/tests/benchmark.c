#define _POSIX_C_SOURCE 200809L
#include "render.h"
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* Time complete calls, including result destruction, without shell/FFI overhead.
 * Input and process startup are deliberately outside the timed region. */
static double now(void) {
    struct timespec t;
    if (clock_gettime(CLOCK_MONOTONIC, &t)) exit(1);
    return t.tv_sec + t.tv_nsec * 1e-9;
}
int main(int argc, char **argv) {
    if (argc != 8 || !setlocale(LC_ALL, "")) return 2;
    FILE *f = fopen(argv[1], "rb");
    if (!f) return 2;
    char *input = malloc(ZMDOWN_INPUT_LIMIT + 1);
    if (!input) return 2;
    size_t length = fread(input, 1, ZMDOWN_INPUT_LIMIT + 1, f);
    if (ferror(f) || length > ZMDOWN_INPUT_LIMIT) return 2;
    fclose(f);
    int mode = atoi(argv[2]), iterations = atoi(argv[6]), samples = atoi(argv[7]);
    struct zmd_options options = {(unsigned)atoi(argv[3]), mode == 1, 1, 1,
        (enum zmd_width_policy)atoi(argv[4]), (enum zmd_cluster_styles)atoi(argv[5]), 0};
    if (iterations < 1 || samples < 1) return 2;
    for (int sample = -1; sample < samples; ++sample) {
        double start = now();
        for (int i = 0; i < iterations; ++i) {
            const char *error = NULL;
            int rc;
            if (mode == 2) {
                struct zmd_document *document = NULL;
                rc = zmd_render_document(input, length, &options, &document, &error);
                zmd_document_free(document);
            } else {
                char *output = NULL; size_t size = 0;
                rc = zmd_render(input, length, &options, &output, &size, &error);
                free(output);
            }
            if (rc) { fprintf(stderr, "%s\n", error); return 1; }
        }
        if (sample >= 0) printf("%.9f\n", (now() - start) * 1000 / iterations);
    }
    free(input);
    return 0;
}
