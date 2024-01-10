#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias lss='ls -lA --color=auto'
alias ls='ls -1 --color=auto'
alias grep='grep --color=auto'
alias sv='sudo -E -s nvim'
alias v='nvim'
alias gv='cd /usr/local/share/valc/'
alias fgc='~/.scripts/system_scripts/./fast_git_commit.sh'
alias lf='lf_with_preview'

export EDITOR=nvim

set_ps1_color() {
	if [ $? -ne 0 ]; then
		PS1="\[\e[1;91m\][ \u@\h \w ]\n\$ \[\e[0m\]"
	else
		PS1="\[\e[1;97m\][ \u@\h \w ]\n\$ \[\e[0m\]"
	fi
}

PROMPT_COMMAND=set_ps1_color

if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
	tmux
fi
