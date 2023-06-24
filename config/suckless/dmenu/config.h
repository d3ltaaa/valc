/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */
#include "/home/falk/.config/suckless/themes/arch-dark.h"

static int instant = 1;
static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
static int centered = 1;                    /* -c option; centers dmenu on screen */
static int min_width = 500;                    /* minimum width when centered */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"cantarell:size=11"
};
static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
static const char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { DMENU_NORMAL_FG_COLOR,          DMENU_NORMAL_BG_COLOR},
	[SchemeSel]  = { DMENU_SELECTED_FG_COLOR,        DMENU_SELECTED_BG_COLOR},
	[SchemeOut]  = { DMENU_POINTER_OUTSIDE_FG_COLOR, DMENU_POINTER_OUTSIDE_FG_COLOR},
	[SchemeHp]   = { DMENU_POINTER_HOVER_FG_COLOR,   DMENU_POINTER_HOVER_BG_COLOR}
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 15;
/* -h option; minimum height of a menu line */
static unsigned int lineheight = 30;
static unsigned int min_lineheight = 8;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";

/* Size of the window border */
static unsigned int border_width = 7;
