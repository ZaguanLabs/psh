/*
 * utils.c - miscellaneous utilities
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

/* Test-only original 5.9.2 conversion oracle. */
static zlong
reference_zstrtol_underscore(const char *s, char **t, int base, int underscore)
{
    const char *inp, *trunc = NULL;
    zulong calc = 0, newcalc = 0;
    int neg;

    while (inblank(*s))
	s++;

    if ((neg = IS_DASH(*s)))
	s++;
    else if (*s == '+')
	s++;

    if (!base) {
	if (*s != '0')
	    base = 10;
	else if (*++s == 'x' || *s == 'X')
	    base = 16, s++;
	else if (*s == 'b' || *s == 'B')
	    base = 2, s++;
	else
	    base = 8;
    }
    inp = s;
    if (base < 2 || base > 36) {
	zerr("invalid base (must be 2 to 36 inclusive): %d", base);
	return (zlong)0;
    } else if (base <= 10) {
	for (; (*s >= '0' && *s < ('0' + base)) ||
		 (underscore && *s == '_'); s++) {
	    if (trunc || *s == '_')
		continue;
	    newcalc = calc * base + *s - '0';
	    if (newcalc < calc)
	    {
		trunc = s;
		continue;
	    }
	    calc = newcalc;
	}
    } else {
	for (; idigit(*s) || (*s >= 'a' && *s < ('a' + base - 10))
	     || (*s >= 'A' && *s < ('A' + base - 10))
	     || (underscore && *s == '_'); s++) {
	    if (trunc || *s == '_')
		continue;
	    newcalc = calc*base + (idigit(*s) ? (*s - '0') : (*s & 0x1f) + 9);
	    if (newcalc < calc)
	    {
		trunc = s;
		continue;
	    }
	    calc = newcalc;
	}
    }

    /*
     * Special case: check for a number that was just too long for
     * signed notation.
     * Extra special case: the lowest negative number would trigger
     * the first test, but is actually representable correctly.
     * This is a 1 in the top bit, all others zero, so test for
     * that explicitly.
     */
    if (!trunc && (zlong)calc < 0 &&
	(!neg || calc & ~((zulong)1 << (8*sizeof(zulong)-1))))
    {
	trunc = s - 1;
	calc /= base;
    }

    if (trunc)
	zwarn("number truncated after %d digits: %s", (int)(trunc - inp), inp);

    if (t)
	*t = (char *)s;
    return neg ? -(zlong)calc : (zlong)calc;
}
