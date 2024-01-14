/* See LICENSE file for copyright and license details. */
#include "/usr/local/src/suckless/themes/arch-dark.h"

/* appearance */
static const unsigned int borderpx  = 7;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 18;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 18;       /* vert inner gap between windows */
static const unsigned int gappoh    = 18;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 18;       /* vert outer gap between windows and screen edge */
/* window swallowing */
static const int swaldecay = 3;
static const int swalretroactive = 1;
static const char swalsymbol[] = "👅";
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int showtitle          = 0;        /* 0 means no title */
static const int showtags           = 1;        /* 0 means no tags */
static const int showlayout         = 1;        /* 0 means no layout indicator */
static const int showstatus         = 1;        /* 0 means no status bar */
static const int showfloating       = 1;        /* 0 means no floating indicator */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int user_bh            = 8;        /* 2 is the default spacing around the bar's font */
static const char *fonts[]          = { "cantarell:size=10" };
static const char dmenufont[]       = "cantarell:size=11";
// background color
static const char col_gray1[]       = DWM_BACKGROUND_COLOR;
// inactive window border color
static const char col_gray2[]       = DWM_INACTIVE_BORDER_COLOR;
// font color
static const char col_gray3[]       = DWM_FONT_COLOR;
// current tag and current window font color
static const char col_gray4[]       = DWM_CURRENT_TAG_FONT_COLOR;
// Top bar second color (blue) and active window border color
static const char col_cyan[]        = DWM_ACTIVE_BORDER_COLOR;
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

static const unsigned int baralpha = OPAQUE;
static const unsigned int borderalpha = OPAQUE;

static const unsigned int alphas[][3]      = {
    /*               fg      bg        border*/
    [SchemeNorm] = { OPAQUE, baralpha, borderalpha },
	[SchemeSel]  = { OPAQUE, baralpha, borderalpha },
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;

const char *spcmd1[] = {"st", "-n", "spterm", "-g", "144x41",  NULL };
const char *spcmd2[] = {"st", "-n", "spspot", "-g", "144x41", "-e", "ncspot", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
	{"spspot",      spcmd2},
};

/* tagging */
static const char *tags[] = { "", "", "", "", "", "" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
	{ NULL,		  "spterm",		NULL,		SPTAG(0),		1,			 -1 },
	{ NULL,		  "spspot",		NULL,		SPTAG(1),		1,			 -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]",      tile },    /* first entry is default */
	{ "~",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[]  = { "st", NULL };


static const Key keys[] = {
	/* modifier                     key        function        argument */

    // dwm
	{ MODKEY|ShiftMask,             XK_q,       quit,          {0} },
	{ MODKEY|ControlMask|ShiftMask, XK_q,       quit,          {1} }, 

    // Tag manipulation
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)

    // Layout manipulation
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY|ShiftMask,             XK_f,      togglefloating, {0} },
	{ MODKEY,                       XK_Return, togglefullscr,  {0} },
 	// { MODKEY,                       XK_o,      setlayout,      {0} }, 

    // Window manipulation
	{ MODKEY,                       XK_h,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_l,      focusstack,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_h,      rotatestack,    {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_l,      rotatestack,    {.i = +1 } },
	{ MODKEY|ControlMask,           XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY|ControlMask,           XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_p,      zoom,           {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY,                       XK_x,      killclient,     {0} },

    // Monitor manipulation
	{ MODKEY,                       XK_i,      focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_o,      focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_i,      tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_o,      tagmon,         {.i = +1 } },

    // Gap manipulation
	{ MODKEY|ControlMask,           XK_g,      togglegaps,     {0} },
	{ MODKEY|ControlMask|Mod1Mask,  XK_g,      defaultgaps,    {0} },
	// { MODKEY|ControlMask,           XK_,      incrgaps,       {.i = +1 } },
	// { MODKEY|ControlMask,           XK_,      incrgaps,       {.i = -1 } },
	// { MODKEY|ControlMask|ShiftMask, XK_,      incrogaps,      {.i = +1 } },
	// { MODKEY|ControlMask|ShiftMask, XK_,      incrogaps,      {.i = -1 } },
	// { MODKEY|ControlMask|Mod1Mask,  XK_,      incrigaps,      {.i = +1 } },
	// { MODKEY|ControlMask|Mod1Mask,  XK_,      incrigaps,      {.i = -1 } },
	// { MODKEY|ControlMask,           XK_,      incrihgaps,     {.i = +1 } },
	// { MODKEY|ControlMask,           XK_,      incrihgaps,     {.i = -1 } },
	// { MODKEY|ControlMask,           XK_,      incrivgaps,     {.i = +1 } },
	// { MODKEY|ControlMask,           XK_,      incrivgaps,     {.i = -1 } },
	// { MODKEY|ControlMask,           XK_,      incrohgaps,     {.i = +1 } },
	// { MODKEY|ControlMask,           XK_,      incrohgaps,     {.i = -1 } },
	// { MODKEY|ControlMask,           XK_,      incrovgaps,     {.i = +1 } },
	// { MODKEY|ControlMask,           XK_,      incrovgaps,     {.i = -1 } },

    // Special Windows
	{ MODKEY,                       XK_space,   spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return,  spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,       togglebar,      {0} },
	{ MODKEY,            			XK_e,  	    togglescratch,  {.ui = 0 } },
	{ MODKEY,            			XK_n,  	    togglescratch,  {.ui = 1 } },

    // custom
    { 0,                            0x1008ff13, spawn,         SHCMD("scr_volume inc") },
    { 0,                            0x1008ff11, spawn,         SHCMD("scr_volume dec") },
    { 0,                            0x1008ff12, spawn,         SHCMD("scr_volume mute") }, 
    { 0,                            0x1008ff03, spawn,         SHCMD("scr_light down") }, 
    { 0,                            0x1008ff02, spawn,         SHCMD("scr_light up") }, 
    { 0,                            0xffbf,     spawn,         SHCMD("scr_light down") }, 
    { 0,                            0xffbe,     spawn,         SHCMD("scr_light up") }, 
    { MODKEY,                       XK_s,       spawn,         SHCMD("menu_options") },
    { MODKEY|ShiftMask,	        	  XK_s,	      spawn,	       SHCMD("menu_system") },
    { MODKEY|ControlMask,           XK_s,       spawn,         SHCMD("flatpak run com.symless.synergy") },
    { MODKEY|ShiftMask,             XK_n,       spawn,         SHCMD("~/.config/nerd-dictation/./process.sh")},
    { MODKEY|ShiftMask,             XK_m,       spawn,         SHCMD("~/.config/nerd-dictation/./process.sh 0")},

    // Miscellaneous
	// { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	// { MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	// { MODKEY,                       XK_u,      swalstopsel,    {0} },

}; 

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
    { ClkStatusText,        0,              Button4,        sigstatusbar,   {.i = 4} },
	{ ClkStatusText,        0,              Button5,        sigstatusbar,   {.i = 5} },
	{ ClkStatusText,        ShiftMask,      Button1,        sigstatusbar,   {.i = 6} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkClientWin,         MODKEY|ShiftMask, Button1,      swalmouse,      {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

