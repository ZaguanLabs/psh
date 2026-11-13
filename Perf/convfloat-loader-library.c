/* Test-only libc plugin: a transparent Latin-1 codec and a printf observer. */
#define _GNU_SOURCE 1
#include <fcntl.h>
#include <gconv.h>
#include <locale.h>
#include <printf.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int
arguments(const struct printf_info *info, size_t count, int *types, int *sizes)
{
    if (count) { types[0] = PA_DOUBLE; sizes[0] = sizeof(double); }
    return 1;
}

static int
format(FILE *stream, const struct printf_info *info, const void *const *args)
{
    const char *mode = uselocale((locale_t)0) == LC_GLOBAL_LOCALE ? "global:" : "private:";
    const char *name = setlocale(LC_NUMERIC, NULL);
    if (fwrite(mode, 1, strlen(mode), stream) != strlen(mode) ||
        fwrite(name, 1, strlen(name), stream) != strlen(name))
        return -1;
    return strlen(mode) + strlen(name);
}

__attribute__((constructor)) static void
loaded(void)
{
    const char *path = getenv("PSH_LOADER_MARKER");
    register_printf_specifier('f', format, arguments);
    if (path) {
        int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0600);
        if (fd >= 0) { (void)write(fd, "loaded\n", 7); close(fd); }
    }
}

int
gconv_init(struct __gconv_step *step)
{
    int from_internal = !strcmp(step->__from_name, "INTERNAL");
    step->__min_needed_from = step->__max_needed_from = from_internal ? 4 : 1;
    step->__min_needed_to = step->__max_needed_to = from_internal ? 1 : 4;
    step->__stateful = 0;
    return __GCONV_OK;
}

void gconv_end(struct __gconv_step *step) { }

int
gconv(struct __gconv_step *step, struct __gconv_step_data *data,
      const unsigned char **input, const unsigned char *end,
      unsigned char **output, size_t *irreversible, int flush, int consume)
{
    unsigned char *out = output ? *output : data->__outbuf;
    int from_internal = !strcmp(step->__from_name, "INTERNAL");
    size_t take = from_internal ? 4 : 1, give = from_internal ? 1 : 4;
    if (!input || !*input) return __GCONV_OK;
    while ((size_t)(end - *input) >= take) {
        uint32_t value;
        if ((size_t)(data->__outbufend - out) < give) break;
        if (from_internal) {
            memcpy(&value, *input, sizeof(value));
            if (value > 255) return __GCONV_ILLEGAL_INPUT;
            *out = value;
        } else {
            value = **input;
            memcpy(out, &value, sizeof(value));
        }
        *input += take; out += give;
    }
    if (output) *output = out; else data->__outbuf = out;
    if (*input == end) return __GCONV_EMPTY_INPUT;
    return (size_t)(end - *input) < take ? __GCONV_INCOMPLETE_INPUT : __GCONV_FULL_OUTPUT;
}
