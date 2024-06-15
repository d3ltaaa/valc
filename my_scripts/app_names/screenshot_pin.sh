#!/bin/bash
DATE="$(date +"%d_%m-%H_%M_%S")"
PICTURE="/home/falk/Pictures/Screenshots/$DATE.png"
grim -g "$(slurp)" - |
	feh --scale-down --auto-zoom -
