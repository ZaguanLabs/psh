/* Test-only public hash-table fixture, compiled with pristine headers. */
#include "zsh.mdh"

#define FLAG_A 0x400
#define FLAG_B 0x800
struct fixture_node { struct hashnode node; int id, generation; };
static HashTable table;
static int collision, action, delegated, nested, bad, visit_trace[1024], ntrace;
static int expected_scanflags;
static int expected_queue;
static unsigned digest;

static unsigned
fixture_hash(const char *name)
{
    return collision ? 0 : (unsigned)atoi(name + 1);
}

static int
initial_flags(int id)
{
    return ((id & 1) ? FLAG_A : 0) | ((id & 2) ? FLAG_B : 0) |
	((id % 5 == 0) ? DISABLED : 0);
}

static void
fixture_free(HashNode hn)
{
    zsfree(hn->nam);
    zfree(hn, sizeof(struct fixture_node));
}

static void
fixture_empty(HashTable ht)
{
    int i;
    for (i = 0; i < ht->hsize; i++) {
	HashNode hn = ht->nodes[i];
	while (hn) {
	    HashNode next = hn->next;
	    fixture_free(hn);
	    hn = next;
	}
	ht->nodes[i] = NULL;
    }
    ht->ct = 0;
}

static void
key(int id, char *out)
{
    sprintf(out, "k%03d", id);
}

static void
insert(int id, int generation)
{
    char name[32];
    struct fixture_node *node = zshcalloc(sizeof(*node));
    key(id, name);
    node->id = id;
    node->generation = generation;
    node->node.flags = initial_flags(id);
    addhashnode(table, ztrdup(name), node);
}

static HashNode
lookup(int id)
{
    char name[32];
    key(id, name);
    return gethashnode2(table, name);
}

static void
erase_node(int id)
{
    char name[32];
    HashNode hn;
    key(id, name);
    hn = removehashnode(table, name);
    if (!hn) bad = 1;
    else fixture_free(hn);
}

static int nested_count;
static void
nested_visit(UNUSED(HashNode hn), int flags)
{
    if (flags != expected_scanflags || queueing_enabled != expected_queue) bad = 1;
    nested_count++;
}

static void
visit(HashNode hn, int flags)
{
    struct fixture_node *node = (struct fixture_node *)hn;
    int id = node->id, i;
    if (flags != expected_scanflags || queueing_enabled != expected_queue || ntrace >= 1024) {
	bad = 1;
	return;
    }
    visit_trace[ntrace++] = id * 10 + node->generation;
    if (action == 10) {
	erase_node(id);              /* Sorted and unsorted: delete every current node. */
	return;
    }
    if (ntrace != 1) return;
    switch (action) {
    case 1: erase_node(id); break;
    case 2: erase_node(0); break; /* Successor in the same bucket. */
    case 3: erase_node(2); break; /* A future bucket. */
    case 4: insert(id, 1); break;
    case 5: insert(0, 1); break;
    case 6: insert(8, 0); break; /* New head in the current bucket. */
    case 7: insert(6, 0); break; /* New head in a future bucket. */
    case 8:
	for (i = 8; i <= 12; i++) insert(i, 0);
	if (table->hsize != 4) bad = 1; /* Resizing stays disabled during scans. */
	break;
    case 9:
	nested_count = 0;
	nested = scanhashtable(table, 0, 0, 0, nested_visit, flags);
	if (nested != 5 || nested_count != 5) bad = 1;
	break;
    case 11: insert(2, 1); break; /* Sorted scan: replace a future entry. */
    case 12: lookup(2)->flags ^= FLAG_B; break;
    case 13: lookup(3)->flags ^= FLAG_A; break;
    case 14: lookup(2)->flags |= FLAG_A; break;
    }
}

static void
generated_scan(HashTable ht, ScanFunc fn, int flags)
{
    delegated++;
    fn(gethashnode2(ht, "k002"), flags);
}

static void
reset(int size, int all_collide)
{
    collision = all_collide;
    table = newhashtable(size, "psh hash scan fixture", NULL);
    table->hash = fixture_hash;
    table->cmpnodes = strcmp;
    table->addnode = addhashnode;
    table->getnode = gethashnode;
    table->getnode2 = gethashnode2;
    table->removenode = removehashnode;
    table->freenode = fixture_free;
    table->emptytable = fixture_empty;
    action = delegated = nested = bad = ntrace = 0;
}

static int
expect(const int *values, int count, int matches, int returned)
{
    int i;
    if (bad || ntrace != count || returned != matches ||
	memcmp(values, visit_trace, count * sizeof(*values))) {
	fprintf(stderr, "hash scan mismatch: action=%d traces=%d/%d matches=%d/%d bad=%d\n",
		action, ntrace, count, returned, matches, bad);
	return 1;
    }
    for (i = 0; i < count; i++) digest = digest * 33U + (unsigned)visit_trace[i];
    digest = digest * 33U + (unsigned)returned;
    return 0;
}

static int
pattern_accepts(int pattern, int id)
{
    switch (pattern) {
    case 0: case 1: return 1;
    case 2: return id < 100;
    case 3: return id < 10 && !(id & 1);
    default: return 0;
    }
}

static int
bin_check(UNUSED(char *name), char **args, UNUSED(Options ops), UNUSED(int func))
{
    static const int sizes[] = {1,2,3,4,5,7,8,9,15,16,17,31,32,33,63,64,65,127,128,129,255,256,257};
    static const int masks[][2] = {{0,0},{FLAG_A,0},{0,FLAG_B},{FLAG_A,FLAG_B},
	{-1,0},{0,-1},{0x40000000,0},{0,0x40000000},{FLAG_A|FLAG_B,FLAG_A}};
    static const char *patterns[] = {NULL,"*","k0*","k00[02468]","absent*"};
    static const int scanflags[] = {0,-17,0x7fffffff};
    unsigned si, density, sorted, mask, pattern, api, sf, checks = 0;
    int failed = 0, expected[1024], order[1024];
    int own_queue = !strcmp(args[0], "queued");
    int entry_queue = queueing_enabled;
    Patprog progs[5];

    if (own_queue) queue_signals();
    expected_queue = queueing_enabled;
    digest = 0;
    progs[0] = NULL;
    for (pattern = 1; pattern < 5; pattern++) {
	char *text = ztrdup(patterns[pattern]);
	tokenize(text);
	progs[pattern] = patcompile(text, PAT_ZDUP, NULL);
	zsfree(text);
	if (!progs[pattern]) { failed = 1; break; }
    }
    if (failed) {
    	if (own_queue) unqueue_signals();
	return 1;
    }
    for (si = 0; si < sizeof(sizes)/sizeof(sizes[0]) && !failed; si++)
    for (density = 0; density < 4 && !failed; density++)
    for (sorted = 0; sorted < 2 && !failed; sorted++)
    for (mask = 0; mask < sizeof(masks)/sizeof(masks[0]) && !failed; mask++)
    for (pattern = 0; pattern < 5 && !failed; pattern++)
    for (api = 0; api < (pattern ? 1U : 2U) && !failed; api++)
    for (sf = 0; sf < 3 && !failed; sf++) {
	int size = sizes[si], ct, i, n = 0, result, f1 = masks[mask][0], f2 = masks[mask][1];
	reset(size, density == 3);
	ct = density == 0 ? 0 : density == 1 ? 1 : size + (size > 1);
	for (i = 0; i < ct; i++) insert(density == 1 ? size - 1 : i, 0);
	if (table->hsize != size) bad = 1;
	/* Known orders: sorted numeric names; one last-bucket node;
	 * all-collision reverse insertion; or a two-node first bucket. */
	for (i = 0; i < ct; i++) {
	    if (density == 1) order[i] = size - 1;
	    else if (sorted) order[i] = i;
	    else if (density == 3) order[i] = ct - 1 - i;
	    else order[i] = size == 1 ? 0 : i == 0 ? size : i - 1;
	}
	for (i = 0; i < ct; i++) {
	    int id = order[i], flags = initial_flags(id);
	    if ((!f1 || (flags & f1)) && !(flags & f2) && pattern_accepts(pattern, id))
		expected[n++] = id * 10;
	}
	expected_scanflags = scanflags[sf];
	result = api ? scanhashtable(table, sorted, f1, f2, visit, expected_scanflags) :
	    scanmatchtable(table, progs[pattern], sorted, f1, f2, visit, expected_scanflags);
	failed = expect(expected, n, n, result);
	if (table->ct != ct || table->hsize != size) failed = 1;
	deletehashtable(table);
	checks++;
    }
    /* Explicit callback contracts, independent of the traversal code. */
    for (api = 0; api < 2 && !failed; api++)
    for (sf = 0; sf < 3 && !failed; sf++) {
	static const int base[] = {40,0,10,20,30};
	unsigned mode;
	for (mode = 0; mode <= 12 && !failed; mode++) {
	    int i, n = 5, result, ids[] = {0,1,2,3,4};
	    int final_count = 5;
	    reset(4, 0);
	    for (i = 0; i < 5; i++) insert(ids[i], 0);
	    memcpy(expected, base, sizeof(base));
	    action = mode;
	    switch (mode) {
	    case 1: final_count = 4; break;
	    case 2: expected[1]=10; expected[2]=20; expected[3]=30; n=4; final_count=4; break;
	    case 3: expected[3]=30; n=4; final_count=4; break;
	    case 5: expected[1]=1; break;
	    case 6: final_count=6; break;
	    case 7: expected[3]=60; expected[4]=20; expected[5]=30; n=6; final_count=6; break;
	    case 8: {
		static const int expanded[] = {40,0,90,10,100,20,110,30};
		memcpy(expected, expanded, sizeof(expanded)); n=8; final_count=10; break;
	    }
	    case 10: final_count=0; break;
	    case 11: expected[3]=21; break;
	    }
	    expected_scanflags = scanflags[sf];
	    result = api ? scanhashtable(table, 0, 0, 0, visit, expected_scanflags) :
		scanmatchtable(table, NULL, 0, 0, 0, visit, expected_scanflags);
	    failed = expect(expected, n, n, result);
	    if (table->ct != final_count || table->hsize != 4) failed = 1;
	    for (i = 0; i <= 12; i++) {
		HashNode hn = lookup(i);
		int present = i < 5;
		if (mode == 1 && i == 4) present = 0;
		if (mode == 2 && i == 0) present = 0;
		if (mode == 3 && i == 2) present = 0;
		if (mode == 6 && i == 8) present = 1;
		if (mode == 7 && i == 6) present = 1;
		if (mode == 8 && i >= 8) present = 1;
		if (mode == 10) present = 0;
		if (!!hn != present) failed = 1;
		if (hn) {
		    int generation = (mode==4 && i==4) || (mode==5 && i==0) || (mode==11 && i==2);
		    if (((struct fixture_node *)hn)->generation != generation) failed=1;
		    if (hn->flags != (initial_flags(i) ^ ((mode==12 && i==2) ? FLAG_B : 0))) failed=1;
		}
	    }
	    /* A subsequent insertion must be allowed to resize the table. */
	    if (mode == 8) { insert(13, 0); if (table->hsize != 16) failed = 1; }
	    deletehashtable(table);
	    checks++;
	}
    }
    /* Sorted controls use a snapshot of node pointers. Exercise supported
     * replacements/current removals without removing a future snapshot slot. */
    for (api = 0; api < 2 && !failed; api++)
    for (sf = 0; sf < 3 && !failed; sf++) {
	static const int modes[] = {0,1,4,6,9,10,11,12};
	unsigned mode;
	for (mode = 0; mode < sizeof(modes)/sizeof(modes[0]) && !failed; mode++) {
	    int i, result, ct = 5;
	    reset(4, 0);
	    for (i = 0; i < 5; i++) { insert(i, 0); expected[i] = i * 10; }
	    action = modes[mode];
	    if (action == 1) ct=4;
	    if (action == 6) ct=6;
	    if (action == 10) ct=0;
	    if (action == 11) expected[2]=21;
	    expected_scanflags = scanflags[sf];
	    result = api ? scanhashtable(table, 1, 0, 0, visit, expected_scanflags) :
		scanmatchtable(table, NULL, 1, 0, 0, visit, expected_scanflags);
	    failed = expect(expected, 5, 5, result);
	    if (table->ct != ct || table->hsize != 4) failed=1;
	    for (i = 0; i <= 8; i++) {
		HashNode hn = lookup(i);
		int present = i < 5;
		if (action==1 && i==0) present=0;
		if (action==6 && i==8) present=1;
		if (action==10) present=0;
		if (!!hn != present) failed=1;
		if (hn) {
		    int gen = (action==4 && i==0) || (action==11 && i==2);
		    if (((struct fixture_node *)hn)->generation != gen) failed=1;
		    if (hn->flags != (initial_flags(i) ^ ((action==12 && i==2) ? FLAG_B : 0))) failed=1;
		}
	    }
	    deletehashtable(table);
	    checks++;
	}
    }
    for (sorted = 0; sorted < 2 && !failed; sorted++)
    for (api = 0; api < 3 && !failed; api++)
    for (sf = 0; sf < 3 && !failed; sf++) {
	int mode;
	for (mode = 13; mode <= 14 && !failed; mode++) {
	    int i, result, n = mode == 13 ? 1 : 3;
	    reset(4, 0);
	    for (i = 0; i < 5; i++) insert(i, 0);
	    action=mode;
	    expected[0]=10; expected[1]=20; expected[2]=30;
	    expected_scanflags=scanflags[sf];
	    result = api == 1 ? scanhashtable(table, sorted, FLAG_A, 0, visit, expected_scanflags) :
		scanmatchtable(table, api == 2 ? progs[1] : NULL, sorted, FLAG_A, 0, visit, expected_scanflags);
	    failed=expect(expected,n,n,result);
	    if (table->ct != 5 || table->hsize != 4) failed=1;
	    if (lookup(mode==13 ? 3 : 2)->flags !=
		(mode==13 ? (initial_flags(3)^FLAG_A) : (initial_flags(2)|FLAG_A))) failed=1;
	    deletehashtable(table);
	    checks++;
	}
    }
    for (sorted = 0; sorted < 2 && !failed; sorted++)
    for (mask = 0; mask < sizeof(masks)/sizeof(masks[0]) && !failed; mask++)
    for (pattern = 0; pattern < 5 && !failed; pattern++)
    for (api = 0; api < (pattern ? 1U : 2U) && !failed; api++) {
	int result, i, n=0, matches;
	reset(4, 0);
	for (i = 0; i < 5; i++) insert(i, 0);
	table->scantab = generated_scan;
	expected_scanflags = -17;
	if (!pattern) { expected[n++]=20; matches=5; }
	else {
	    static const int base[] = {4,0,1,2,3};
	    for (i = 0; i < 5; i++) {
		int id=sorted ? i : base[i], f=initial_flags(id);
		if ((!masks[mask][0] || (f & masks[mask][0])) && !(f & masks[mask][1]) && pattern_accepts(pattern,id))
		    expected[n++]=id*10;
	    }
	    matches=n;
	}
	result = api ? scanhashtable(table, sorted, masks[mask][0], masks[mask][1], visit, expected_scanflags) :
	    scanmatchtable(table, progs[pattern], sorted, masks[mask][0], masks[mask][1], visit, expected_scanflags);
	failed = expect(expected, n, matches, result);
	if (delegated != !pattern) failed = 1;
	deletehashtable(table);
	checks++;
    }
    for (pattern = 1; pattern < 5; pattern++) freepatprog(progs[pattern]);
    if (queueing_enabled != expected_queue) failed=1;
    if (own_queue) unqueue_signals();
    if (queueing_enabled != entry_queue) failed=1;
    if (failed) return 1;
    printf("checks=%u digest=%u\n", checks, digest);
    fflush(stdout);
    return 0;
}

static struct builtin bintab[] = {
    BUILTIN("psh-hash-scan-check", 0, bin_check, 1, 1, 0, NULL, NULL)
};
static struct features module_features = {bintab,1,NULL,0,NULL,0,NULL,0,0};
int setup_(UNUSED(Module m)) { return 0; }
int features_(Module m, char ***features) { *features=featuresarray(m,&module_features); return 0; }
int enables_(Module m, int **enables) { return handlefeatures(m,&module_features,enables); }
int boot_(UNUSED(Module m)) { return 0; }
int cleanup_(Module m) { return setfeatureenables(m,&module_features,NULL); }
int finish_(UNUSED(Module m)) { return 0; }
