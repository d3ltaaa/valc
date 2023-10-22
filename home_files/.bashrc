#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias lss='ls -lA --color=auto'
alias grep='grep --color=auto'
alias svim='sudo -E -s nvim'

export EDITOR=nvim

PS1='[\u@\h \W]\$ '

# if [[ ! "$(tty)" = "/dev/tty1" ]]; then
#     
# fi
