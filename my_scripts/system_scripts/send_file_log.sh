#!/bin/bash

DIR_TO_SEARCH="/home/$USER/Samsung_Notes"
FILE_LOG_PATH="/home/$USER/.file_log.txt"
>$FILE_LOG_PATH

cd $DIR_TO_SEARCH

input_string=$(find . -type f)
IFS=$'\n'
mapfile -t file_arr <<<"$input_string"

for file in ${file_arr[@]}; do
	file="${file:1}"
	echo "$file"
	file="$(echo "$file" | sed 's|\(.*\)\/|\1\/[|; s/_/]_/')"

	echo "$file" >>"$FILE_LOG_PATH"
	echo Done
done
