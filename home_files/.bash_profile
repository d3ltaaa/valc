#
# ~/.bash_profile
#

export PATH="$PATH:$HOME/.scripts/"
export PATH="$PATH:$HOME/.scripts/app_names/"
export PATH="$PATH:$HOME/.scripts/system_scripts/"
export PATH="$PATH:$HOME/.scripts/theme_scripts/"
export PATH="$PATH:$HOME/.scripts/dwmblocks_scripts/"
export PATH="$PATH:$HOME/.scripts/test_scripts/"

if [[ "$(tty)" = "/dev/tty1" ]]; then
	startx
elif command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
	tmux
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
