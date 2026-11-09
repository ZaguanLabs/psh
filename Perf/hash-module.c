/*
 * hashtable.c - hash tables
 *
 * This file is part of zsh, the Z shell.
 *
 * Copyright (c) 1992-1997 Paul Falstad
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and to distribute modified versions of this software for any
 * purpose, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 *
 * In no event shall Paul Falstad or the Zsh Development Group be liable
 * to any party for direct, indirect, special, incidental, or consequential
 * damages arising out of the use of this software and its documentation,
 * even if Paul Falstad and the Zsh Development Group have been advised of
 * the possibility of such damage.
 *
 * Paul Falstad and the Zsh Development Group specifically disclaim any
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose.  The software
 * provided hereunder is on an "as is" basis, and Paul Falstad and the
 * Zsh Development Group have no obligation to provide maintenance,
 * support, updates, enhancements, or modifications.
 *
 */

/* Test-only hash-value oracle and byte-boundary fixture. */
#include "zsh.mdh"
#include <errno.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>
#include <limits.h>

static unsigned checks, digest;
static int bad;

/* Original release recurrence, kept independent of grouped arithmetic. */
static unsigned
reference_hasher(const char *str)
{
    unsigned hashval = 0, c;

    while ((c = *((unsigned char *) str++)))
	hashval += (hashval << 5) + c;

    return hashval;
}

static void
one(const unsigned char *p)
{
    unsigned expected, actual;
    int saved = errno, requested = checks & 31;
    errno = requested;
    expected = reference_hasher((const char *)p);
    actual = hasher((const char *)p);
    if (expected != actual || errno != requested) {
        fprintf(stderr, "hash mismatch: case=%u expected=%u actual=%u errno=%d/%d\n",
                checks, expected, actual, errno, requested);
        bad = 1;
    }
    errno = saved;
    digest = digest * 33U + actual;
    checks++;
}

static unsigned random_state;
static unsigned
next_random(void)
{
    random_state = random_state * 1664525U + 1013904223U;
    return random_state;
}

static int
bin_hash_check(UNUSED(char *name), UNUSED(char **args), UNUSED(Options ops), UNUSED(int func))
{
    static const unsigned alphabet[] = {1,32,65,97,127,131,255};
    static const unsigned long_lengths[] = {511,512,513,1023,1024,1025,
        4095,4096,4097,16383,16384,16385,65535};
    unsigned char scratch[512], *p;
    unsigned offset, a, b, c, i, len, pattern, exhaustive, triples, heap, guards, randoms;
    long page = sysconf(_SC_PAGESIZE);
    size_t usable, mapped;
    unsigned char *mapping, *data;
    checks = digest = bad = 0;
    memset(scratch, 0xa5, sizeof(scratch));
    for (offset = 0; offset < 8 && !bad; offset++) {
        p = scratch + offset;
        p[0] = 0; one(p);
        for (a = 1; a <= 255 && !bad; a++) {
            p[0] = a; p[1] = 0; one(p);
            for (b = 1; b <= 255 && !bad; b++) {
                p[1] = b; p[2] = 0; one(p);
            }
        }
    }
    exhaustive = checks;
    for (offset = 0; offset < 8 && !bad; offset++)
    for (a = 0; a < 7 && !bad; a++)
    for (b = 0; b < 7 && !bad; b++)
    for (c = 0; c < 7 && !bad; c++) {
        p = scratch + offset;
        p[0] = alphabet[a]; p[1] = alphabet[b]; p[2] = alphabet[c]; p[3] = 0;
        one(p);
    }
    triples = checks - exhaustive;
    for (len = 0; len <= 257 && !bad; len++)
    for (offset = 0; offset < 8 && !bad; offset++)
    for (pattern = 0; pattern < 4 && !bad; pattern++) {
        unsigned char *block = zalloc(offset + len + 1);
        memset(block, 0xa5, offset + len + 1);
        p = block + offset;
        for (i = 0; i < len; i++) p[i] = (i * 37 + pattern * 19) % 255 + 1;
        p[len] = 0; one(p);
        zfree(block, offset + len + 1);
    }
    heap = checks - exhaustive - triples;
    if (page <= 0 || page > 1048576) return 2;
    usable = ((65536 + page - 1) / page) * page;
    mapped = usable + 2 * page;
    mapping = mmap(NULL, mapped, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mapping == MAP_FAILED) return 2;
    data = mapping + page;
    if (mprotect(data, usable, PROT_READ | PROT_WRITE)) { munmap(mapping, mapped); return 2; }
    for (a = 0; a < 258 + sizeof(long_lengths)/sizeof(long_lengths[0]) && !bad; a++) {
        len = a < 258 ? a : long_lengths[a - 258];
        p = data + usable - len - 1;
        for (pattern = 0; pattern < 4 && !bad; pattern++) {
            for (i = 0; i < len; i++)
                p[i] = pattern == 0 ? 'a' : pattern == 1 ? 255 :
                    pattern == 2 ? (i & 1 ? 131 : 1) : (i * 37 + 17) % 255 + 1;
            p[len] = 0;
            if (mprotect(data, usable, PROT_READ)) { bad = 1; break; }
            one(p);
            if (mprotect(data, usable, PROT_READ | PROT_WRITE)) { bad = 1; break; }
        }
    }
    munmap(mapping, mapped);
    guards = checks - exhaustive - triples - heap;
    random_state = 12345U;
    for (a = 0; a < 4096 && !bad; a++) {
        offset = next_random() & 7;
        len = next_random() % 258;
        memset(scratch, 0xa5, sizeof(scratch));
        p = scratch + offset;
        for (i = 0; i < len; i++) p[i] = next_random() >> 16;
        p[len] = 0; one(p);
    }
    randoms = checks - exhaustive - triples - heap - guards;
    if (bad || exhaustive != 522248 || triples != 2744 || heap != 8256 ||
        guards != 1084 || randoms != 4096) return 1;
    printf("checks=%u digest=%u exhaustive=%u triples=%u heap=%u guards=%u random=%u\nhash-done\n",
           checks,digest,exhaustive,triples,heap,guards,randoms);
    fflush(stdout);
    return 0;
}
/* Hot, repeated native calls isolate hashing from interpreter dispatch. */
static int
bin_hash_bench(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    int len = atoi(args[0]), n = atoi(args[1]), i;
    unsigned char *p;
    unsigned sum = 0;
    struct timespec start, end;
    double elapsed;
    if (len < 0 || len > 1048576 || n < 1 || n > 10000000) return 2;
    p = zalloc(len + 1);
    for (i = 0; i < len; i++) p[i] = (i * 37 + 17) % 255 + 1;
    p[len] = 0;
    (void)hasher((const char *)p);
    if (clock_gettime(CLOCK_MONOTONIC, &start)) { zfree(p, len + 1); return 2; }
    for (i = 0; i < n; i++) sum += hasher((const char *)p);
    if (clock_gettime(CLOCK_MONOTONIC, &end)) { zfree(p, len + 1); return 2; }
    elapsed = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    zfree(p, len + 1);
    printf("%.9f %u %u\n", elapsed, sum, (unsigned)(sizeof(unsigned) * CHAR_BIT));
    fflush(stdout);
    return 0;
}
static struct builtin bintab[] = {
    BUILTIN("psh-hash-check", 0, bin_hash_check, 0, 0, 0, NULL, NULL),
    BUILTIN("psh-hash-bench", 0, bin_hash_bench, 2, 2, 0, NULL, NULL)
};
static struct features module_features = {bintab,2,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features = featuresarray(m, &module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m, &module_features, enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m, &module_features, NULL); }
int finish_(UNUSED(Module m)) { return 0; }
