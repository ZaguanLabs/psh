/* Linux-only diagnostic launcher. Counts user-space hardware events from
 * exec onward, including inherited tasks; never changes system settings.
 * Usage: count-command REPORT.json COMMAND [ARG ...] */
#define _GNU_SOURCE
#include <errno.h>
#include <inttypes.h>
#include <linux/perf_event.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/resource.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static uint64_t
nanoseconds(void)
{
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts)) { perror("clock_gettime"); exit(125); }
    return (uint64_t)ts.tv_sec * UINT64_C(1000000000) + (uint64_t)ts.tv_nsec;
}

int
main(int argc, char **argv)
{
    static const uint64_t configs[] = {PERF_COUNT_HW_CPU_CYCLES,
        PERF_COUNT_HW_INSTRUCTIONS, PERF_COUNT_HW_BRANCH_INSTRUCTIONS,
        PERF_COUNT_HW_BRANCH_MISSES};
    static const char *names[] = {"cycles", "instructions", "branches", "branch_misses"};
    struct reading { uint64_t value, enabled, running; } counts[4];
    struct rusage usage;
    int gate[2], fds[4] = {-1,-1,-1,-1}, status, i, exit_status;
    uint64_t start, elapsed;
    pid_t child, parent = getpid();
    FILE *report;
    if (argc < 3) { fprintf(stderr, "Usage: %s REPORT.json COMMAND [ARG ...]\n", argv[0]); return 2; }
    if (pipe(gate)) { perror("pipe"); return 125; }
    child = fork();
    if (child < 0) { perror("fork"); return 125; }
    if (!child) {
        char ready;
        close(gate[1]);
        if (prctl(PR_SET_PDEATHSIG, SIGTERM) || getppid() != parent) _exit(125);
        if (read(gate[0], &ready, 1) != 1) _exit(125);
        close(gate[0]);
        execvp(argv[2], argv + 2);
        perror("execvp");
        _exit(127);
    }
    close(gate[0]);
    for (i = 0; i < 4; i++) {
        struct perf_event_attr attr;
        memset(&attr, 0, sizeof(attr));
        attr.type = PERF_TYPE_HARDWARE;
        attr.size = sizeof(attr);
        attr.config = configs[i];
        attr.disabled = i == 0;
        attr.enable_on_exec = i == 0;
        attr.inherit = 1;
        attr.exclude_kernel = 1;
        attr.exclude_hv = 1;
        attr.read_format = PERF_FORMAT_TOTAL_TIME_ENABLED | PERF_FORMAT_TOTAL_TIME_RUNNING;
        fds[i] = (int)syscall(SYS_perf_event_open, &attr, child, -1, i ? fds[0] : -1, PERF_FLAG_FD_CLOEXEC);
        if (fds[i] < 0) {
            fprintf(stderr, "perf_event_open(%s): %s\n", names[i], strerror(errno));
            close(gate[1]);
            while (waitpid(child, NULL, 0) < 0 && errno == EINTR) {}
            while (i--) close(fds[i]);
            return 125;
        }
    }
    start = nanoseconds();
    if (write(gate[1], "!", 1) != 1) { perror("write gate"); kill(child, SIGTERM); }
    close(gate[1]);
    while (wait4(child, &status, 0, &usage) < 0) {
        if (errno != EINTR) { perror("wait4"); return 125; }
    }
    elapsed = nanoseconds() - start;
    exit_status = WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
    for (i = 0; i < 4; i++) {
        if (read(fds[i], &counts[i], sizeof(counts[i])) != sizeof(counts[i])) {
            perror("read counter"); return 125;
        }
        close(fds[i]);
        if (!counts[i].enabled || !counts[i].running) {
            fprintf(stderr, "Counter %s was not scheduled\n", names[i]); return 125;
        }
    }
    report = fopen(argv[1], "w");
    if (!report) { perror("open report"); return 125; }
    fprintf(report, "{\n  \"exit_status\": %d, \"elapsed_ns\": %" PRIu64 ",\n"
        "  \"scope\": \"user space, exec through exit, inherited tasks\",\n"
        "  \"user_seconds\": %.6f, \"system_seconds\": %.6f, \"max_rss_kib\": %ld,\n"
        "  \"events\": [\n", exit_status, elapsed,
        usage.ru_utime.tv_sec + usage.ru_utime.tv_usec / 1e6,
        usage.ru_stime.tv_sec + usage.ru_stime.tv_usec / 1e6, usage.ru_maxrss);
    for (i = 0; i < 4; i++)
        fprintf(report, "    {\"name\": \"%s\", \"value\": %" PRIu64
            ", \"enabled_ns\": %" PRIu64 ", \"running_ns\": %" PRIu64 "}%s\n",
            names[i], counts[i].value, counts[i].enabled, counts[i].running, i == 3 ? "" : ",");
    if (fprintf(report, "  ]\n}\n") < 0 || fclose(report)) { perror("write report"); return 125; }
    return exit_status;
}
