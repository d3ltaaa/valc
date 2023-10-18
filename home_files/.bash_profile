#
# ~/.bash_profile
#

export PATH="$PATH:$HOME/.scripts/"
export PATH="$PATH:$HOME/.scripts/app_names/"
export PATH="$PATH:$HOME/.scripts/system_scripts/"
export PATH="$PATH:$HOME/.scripts/theme_scripts/"
export PATH="$PATH:$HOME/.scripts/dwmblocks_scripts/"
export PATH="$PATH:$HOME/.scripts/test_scripts/"


[[ -f ~/.bashrc ]] && . ~/.bashrc


if [[ "$(tty)" = "/dev/tty1" ]]; then
    startx
fi

