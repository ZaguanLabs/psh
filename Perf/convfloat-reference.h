/*
 * params.c - parameters
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

/* Exact pristine-release converter, renamed as an independent oracle. */
static char *
reference_convfloat(double dval, int digits, int flags, FILE *fout)
{
    char fmt[] = "%.*e";
    char *prev_locale, *ret;

    /*
     * The difficulty with the buffer size is that a %f conversion
     * prints all digits before the decimal point: with 64 bit doubles,
     * that's around 310.  We can't check without doing some quite
     * serious floating point operations we'd like to avoid.
     * Then we are liable to get all the digits
     * we asked for after the decimal point, or we should at least
     * bargain for it.  So we just allocate 512 + digits.  This
     * should work until somebody decides on 128-bit doubles.
     */
    if (!(flags & (PM_EFLOAT|PM_FFLOAT))) {
	/*
	 * Conversion from a floating point expression without using
	 * a variable.  The best bet in this case just seems to be
	 * to use the general %g format with something like the maximum
	 * double precision.
	 */
	fmt[3] = 'g';
	if (!digits)
	    digits = 17;
    } else {
	if (flags & PM_FFLOAT)
	    fmt[3] = 'f';
	if (digits <= 0)
	    digits = 10;
	if (flags & PM_EFLOAT) {
	    /*
	     * Here, we are given the number of significant figures, but
	     * %e wants the number of decimal places (unlike %g)
	     */
	    digits--;
	}
    }
#ifdef USE_LOCALE
    prev_locale = dupstring(setlocale(LC_NUMERIC, NULL));
    setlocale(LC_NUMERIC, "POSIX");
#endif
    if (fout) {
	fprintf(fout, fmt, digits, dval);
	ret = NULL;
    } else {
	VARARR(char, buf, 512 + digits);
	if (isinf(dval))
	    ret = dupstring((dval < 0.0) ? "-Inf" : "Inf");
	else if (isnan(dval))
	    ret = dupstring("NaN");
	else {
	    sprintf(buf, fmt, digits, dval);
	    if (!strchr(buf, 'e') && !strchr(buf, '.'))
		strcat(buf, ".");
	    ret = dupstring(buf);
	}
    }
#ifdef USE_LOCALE
    if (prev_locale) setlocale(LC_NUMERIC, prev_locale);
#endif
    return ret;
}
