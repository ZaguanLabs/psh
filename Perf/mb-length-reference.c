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

/* Reference: untouched Zsh 5.9.2 Src/utils.c, SHA256 54ee6616f88da238a2549092e36330553ff58e05cdf127f76f5b38f92374d868.
 * Only linkage, function name and private state name are changed. */
static mbstate_t reference_state;

static int
reference_mb_metastrlenend(char *ptr, int width, char *eptr)
{
    char inchar, *laststart;
    size_t ret;
    wchar_t wc;
    int num, num_in_char, complete;

    if (!isset(MULTIBYTE) || MB_CUR_MAX == 1)
	return eptr ? (int)(eptr - ptr) : ztrlen(ptr);

    laststart = ptr;
    ret = MB_INVALID;
    num = num_in_char = 0;
    complete = 1;

    memset(&reference_state, 0, sizeof(reference_state));
    while (*ptr && !(eptr && ptr >= eptr)) {
	if (*ptr == Meta)
	    inchar = *++ptr ^ 32;
	else
	    inchar = *ptr;
	ptr++;

	if (complete && (unsigned char) inchar <= (unsigned char) 0x7f) {
	    /*
	     * We rely on 7-bit US-ASCII as a subset, so skip
	     * multibyte handling if we have such a character.
	     */
	    num++;
	    laststart = ptr;
	    num_in_char = 0;
	    continue;
	}

	ret = mbrtowc(&wc, &inchar, 1, &reference_state);

	if (ret == MB_INCOMPLETE) {
	    /*
	     * "num_in_char" is only used for incomplete characters.
	     * The assumption is that we will output all trailing octets
	     * that form part of an incomplete character as a single
	     * character (of single width) if we don't get a complete
	     * character.  This is purely pragmatic --- I'm not aware
	     * of a standard way of dealing with incomplete characters.
	     *
	     * If we do get a complete character, num_in_char
	     * becomes irrelevant and is set to zero
	     *
	     * This is in contrast to "num" which counts the characters
	     * or widths in complete characters.  The two are summed,
	     * so we don't count characters twice.
	     */
	    num_in_char++;
	    complete = 0;
	} else {
	    if (ret == MB_INVALID) {
		/* Reset, treat as single character */
		memset(&reference_state, 0, sizeof(reference_state));
		ptr = laststart + (*laststart == Meta) + 1;
		num++;
	    } else if (width) {
		/*
		 * Returns -1 if not a printable character.  We
		 * turn this into 0.
		 */
		int wcw = WCWIDTH(wc);
		if (wcw > 0) {
		    if (width == 1)
			num += wcw;
		    else
			num++;
		}
	    } else
		num++;
	    laststart = ptr;
	    num_in_char = 0;
	    complete = 1;
	}
    }

    /* If incomplete, treat remainder as trailing single character */
    return num + (num_in_char ? 1 : 0);
}
