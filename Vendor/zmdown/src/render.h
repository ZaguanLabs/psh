#ifndef ZMDOWN_RENDER_H
#define ZMDOWN_RENDER_H

#include <stddef.h>

#define ZMDOWN_VERSION "0.1.0-dev"
#define ZMDOWN_INPUT_LIMIT (4u * 1024u * 1024u)
#define ZMDOWN_OUTPUT_LIMIT (32u * 1024u * 1024u)

enum zmd_width_policy { ZMD_WIDTH_UNICODE, ZMD_WIDTH_WCWIDTH_SUM };
enum zmd_cluster_styles { ZMD_STYLES_PRESERVE, ZMD_STYLES_FIRST_BASE };
#define ZMDOWN_SUM_WIDTH_POLICY "unicode-17.0.0-egc-wcwidth-sum"

/* Zero-initialize before setting options; new policy fields default to zero.
 * This development C API requires callers to rebuild against this header. */
struct zmd_options {
    unsigned width; /* 1..4096 terminal cells */
    int color;      /* emit SGR styling */
    int gfm;        /* tables, task lists, strikethrough, permissive autolinks */
    int links;      /* include link destinations */
    enum zmd_width_policy width_policy;
    enum zmd_cluster_styles cluster_styles;
    int hard_soft_breaks; /* 0: spaces (default), 1: preserve soft line breaks */
};

/* On failure, output is NULL. On success the caller owns malloc'd output.
 * Text is UTF-8; invalid bytes and terminal control characters are made visible.
 * No terminal state, shell state, subprocesses, or global renderer state. */
int zmd_render(const char *input, size_t length, const struct zmd_options *options,
               char **output, size_t *output_length, const char **error);

/* Version 1 structured result: alternating UTF-8 key/value strings, with no
 * terminal escapes. See docs/structured-output.md for the public schema.
 * The complete result is published only on success; free with this API. */
#define ZMDOWN_SCHEMA_VERSION "1"
#define ZMDOWN_PAIR_LIMIT 500000u
struct zmd_document { char **pairs; size_t count; };
int zmd_render_document(const char *input, size_t length,
                        const struct zmd_options *options,
                        struct zmd_document **result, const char **error);
void zmd_document_free(struct zmd_document *document);

#endif
