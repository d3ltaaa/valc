#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -la --color=auto'
alias grep='grep --color=auto'

export EDITOR=nvim

PS1='[\u@\h \W]\$ '

if [[ ! "$(tty)" = "/dev/tty1" ]]; then
    neofetch
fi
