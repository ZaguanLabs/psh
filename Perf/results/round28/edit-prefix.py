from pathlib import Path
p=Path('Src/params.c');s=p.read_text();anchor='/* Called before matching, with signals queued and arr owned by pm. Reuse\n';i=s.index(anchor);s=s[:i]+'''/* Complete a length walk from an already confirmed prefix. The caller has
 * established ownership before the read; retain the original scan otherwise. */
/**/
static int
array_length_full(Param pm, char **arr)
{
    unsigned slot = ((size_t)pm >> 4) & 63;
    unsigned prefix = 0;

    if (queue_signal_level() && arr == pm->u.arr &&
	array_lengths[slot].pm == pm && array_lengths[slot].array == arr &&
	array_lengths[slot].bound <= INT_MAX)
	prefix = array_lengths[slot].bound;
    return prefix + arrlen(arr + prefix);
}

'''+s[i:]
s=s.replace('''	char **const old = getarrayreadonly(v->pm);
	char **new;
''','''	int cache_length = queue_signal_level() && array_length_owned(v->pm) &&
	    !(v->pm->node.flags & PM_UNIQUE);
	char **const old = getarrayreadonly(v->pm);
	char **new;
''',1)
anchor='''        /* Ownership of all strings has been
         * given away, can plainly free */
''';assert s.count(anchor)==1
s=s.replace(anchor,'''        /* The ordinary setter has no callbacks or length-changing effects
         * under these ownership/uniqueness restrictions. Its invalidation is
         * complete, so publish only the prefix constructed by this write. */
	if (cache_length && post_assignment_length >= 64) {
	    unsigned slot = ((size_t)v->pm >> 4) & 63;
	    array_lengths[slot].pm = v->pm;
	    array_lengths[slot].array = v->pm->u.arr;
	    array_lengths[slot].bound = post_assignment_length;
	}

'''+anchor)
anchor='\t\tv->start = arrlen(getarrayreadonly(v->pm));';assert s.count(anchor)==1
s=s.replace(anchor,'''		int cache_length = array_length_owned(v->pm);
		char **arr = getarrayreadonly(v->pm);
		v->start = cache_length ? array_length_full(v->pm, arr) : arrlen(arr);''')
p.write_text(s)
