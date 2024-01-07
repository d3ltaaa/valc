#!/bin/bash

DIR_TO_SEARCH="/home/$USER/Samsung_Notes"
FILE_LOG_PATH="/home/$USER/.file_log.txt"
>$FILE_LOG_PATH

cd $DIR_TO_SEARCH
file_arr=($(find . -type f))

for file in ${file_arr[@]}; do
	file="${file:1}"
	dir=$(echo $file | rev | cut -d'/' -f2- | rev)
	name=$(echo $file | rev | cut -d'/' -f1 | rev | cut -d'.' -f1 | cut -d'_' -f1)
	time=$(echo $file | rev | cut -d'/' -f1 | rev | cut -d'.' -f1 | cut -d'_' -f2-)
	ext=$(echo $file | cut -d'.' -f2)
	touch ~/.file_log.txt
	echo "$dir/[$name]_${time}.${ext}" >>$FILE_LOG_PATH
done
