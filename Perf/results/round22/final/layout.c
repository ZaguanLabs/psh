#include "zsh.mdh"
#include <stddef.h>
int main(void) { printf("%zu %zu %zu %zu %zu\n", sizeof(struct param), sizeof(struct value), offsetof(struct param,u), offsetof(struct param,gsu), offsetof(struct param,node)); return 0; }
