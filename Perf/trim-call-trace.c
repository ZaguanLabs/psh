/* Linux/glibc diagnostic interposer. Never installed or used for timing. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <unistd.h>

int getrusage(__rusage_who_t who, struct rusage *usage)
{
    static int (*next_usage)(__rusage_who_t, struct rusage *);
    if (who == RUSAGE_SELF && getenv("PSH_RUSAGE_FAIL")) {
        errno = ENOSYS;
        return -1;
    }
    if (!next_usage) {
        *(void **)(&next_usage) = dlsym(RTLD_NEXT, "getrusage");
        if (!next_usage)
            _exit(95);
    }
    return next_usage(who, usage);
}

int malloc_trim(size_t pad)
{
    static int (*next_trim)(size_t);
    int result, saved_errno, fd;
    const char *path;
    if (!next_trim) {
        *(void **)(&next_trim) = dlsym(RTLD_NEXT, "malloc_trim");
        if (!next_trim)
            _exit(98);
    }
    result = next_trim(pad);
    saved_errno = errno;
    path = getenv("PSH_TRIM_TRACE");
    if (!path || (fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0600)) < 0)
        _exit(97);
    if (write(fd, "trim\n", 5) != 5 || close(fd))
        _exit(96);
    errno = saved_errno;
    return result;
}
