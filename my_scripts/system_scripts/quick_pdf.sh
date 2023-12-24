#!/bin/bash

if [[ "$1" == "0" ]]; then
	if pgrep -x "zathura" >/dev/null; then
		pkill zathura
	fi
elif [[ "$1" == *.md ]]; then
	pandoc $1 -o ${1%.*}.pdf

	if pgrep -x "zathura" >/dev/null; then
		pkill zathura
	fi

	zathura ${1%.*}.pdf
elif [[ "$1" == *.tex ]]; then
	pdflatex "$1"

	if pgrep -x "zathura" >/dev/null; then
		pkill zathura
	fi

	zathura ${1%.*}.pdf

fi
