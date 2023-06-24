//Modify this file to change what commands output to your statusbar, and recompile using the make command.

static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
    {"",        "sb_volume",    0,                  1               },
    {"",        "sb_net",       0,                  5               },
    {"",        "sb_blue",      0,                  2               },
    {"",        "sb_mail",      0,                  6,              },
    {"",        "sb_clock",     60,                 3               },
    {"",        "sb_battery",   60,                7,              },
    {"",        "sb_system",    0,                  4               },
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = "\0";
static unsigned int delimLen = 5;
