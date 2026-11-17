/* glibc diagnostic. Keep every other block live to prevent coalescing. */
#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
    void *blocks[64];
    size_t i, allocated, released;

    for (i = 0; i < 64; i++) {
        blocks[i] = malloc(256);
        if (blocks[i] == NULL)
            return 1;
    }
    allocated = mallinfo2().uordblks;
    for (i = 0; i < 64; i += 2)
        free(blocks[i]);
    released = mallinfo2().uordblks;
    for (i = 1; i < 64; i += 2)
        free(blocks[i]);
    if (released > allocated)
        return 2;
    printf("%zu\n", allocated - released);
    return 0;
}
