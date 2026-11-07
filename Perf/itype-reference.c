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

/* Original release bodies. The scanner is renamed; its private wide arrays
 * are rebuilt from the host's public IFS/WORDCHARS values by the fixture. */
#ifdef MULTIBYTE_SUPPORT
struct widechar_array {
    wchar_t *chars;
    size_t len;
};
typedef struct widechar_array *Widechar_array;

/*
 * The wordchars variable turned into a wide character array.
 * This is much more convenient for testing.
 */
static struct widechar_array wordchars_wide;

/*
 * The same for the separators (IFS) array.
 */
static struct widechar_array ifs_wide;

/* Function to set one of the above from the multibyte array */

static void
reference_set_widearray(char *mb_array, Widechar_array wca)
{
    if (wca->chars) {
	free(wca->chars);
	wca->chars = NULL;
    }
    wca->len = 0;

    if (mb_array) {
	VARARR(wchar_t, tmpwcs, strlen(mb_array));
	wchar_t *wcptr = tmpwcs;
	wint_t wci;

	mb_charinit();
	while (*mb_array) {
	    int mblen;

	    if ((unsigned char) *mb_array <= 0x7f) {
		*wcptr++ = (wchar_t)*mb_array++;
		continue;
	    }

	    mblen = mb_metacharlenconv(mb_array, &wci);

	    if (!mblen)
		break;
	    /* No good unless all characters are convertible */
	    if (wci == WEOF)
		return;
	    *wcptr++ = (wchar_t)wci;
#ifdef DEBUG
	    /*
	     * This generates a warning from the compiler (and is
	     * indeed useless) if chars are unsigned.  It's
	     * extreme paranoia anyway.
	     */
	    if (wcptr[-1] < 0)
		fprintf(stderr, "BUG: Bad cast to wchar_t\n");
#endif
	    mb_array += mblen;
	}

	wca->len = wcptr - tmpwcs;
	wca->chars = (wchar_t *)zalloc(wca->len * sizeof(wchar_t));
	wmemcpy(wca->chars, tmpwcs, wca->len);
    }
}
#endif


static char *
reference_itype_end(const char *ptr, int itype, int once)
{
#ifdef MULTIBYTE_SUPPORT
    if (isset(MULTIBYTE) &&
	(itype != IIDENT || !isset(POSIXIDENTIFIERS))) {
	mb_charinit();
	while (*ptr) {
	    int len;
	    if (itok(*ptr)) {
		/* Not untokenised yet --- can happen in raw command line */
		len = 1;
		if (!zistype(*ptr,itype))
		    break;
	    } else {
		wint_t wc;
		len = mb_metacharlenconv(ptr, &wc);

		if (!len)
		    break;

		if (wc == WEOF) {
		    /* invalid, treat as single character */
		    int chr = (unsigned char) (*ptr == Meta ? ptr[1] ^ 32 : *ptr);
		    /* in this case non-ASCII characters can't match */
		    if (chr > 127 || !zistype(chr,itype))
			break;
		} else if (len == 1 && isascii(*ptr)) {
		    /* ASCII: can't be metafied, use standard test */
		    if (!zistype(*ptr,itype))
			break;
		} else {
		    /*
		     * Valid non-ASCII character.
		     */
		    switch (itype) {
		    case IWORD:
			if (!iswalnum(wc) &&
			    !wmemchr(wordchars_wide.chars, wc,
				     wordchars_wide.len))
			    return (char *)ptr;
			break;

		    case ISEP:
			if (!wmemchr(ifs_wide.chars, wc, ifs_wide.len))
			    return (char *)ptr;
			break;

		    default:
			if (!iswalnum(wc))
			    return (char *)ptr;
		    }
		}
	    }
	    ptr += len;

	    if (once)
		break;
	}
    } else
#endif
	for (;;) {
	    int chr = (unsigned char) (*ptr == Meta ? ptr[1] ^ 32 : *ptr);
	    if (!zistype(chr,itype))
		break;
	    ptr += (*ptr == Meta) ? 2 : 1;

	    if (once)
		break;
	}

    /*
     * Nasty.  The first argument is const char * because we
     * don't modify it here.  However, we really want to pass
     * back the same type as was passed down, to allow idioms like
     *   p = itype_end(p, IIDENT, 0);
     * So returning a const char * isn't really the right thing to do.
     * Without having two different functions the following seems
     * to be the best we can do.
     */
    return (char *)ptr;
}
