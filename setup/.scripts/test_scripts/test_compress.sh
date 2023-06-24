#!/bin/bash

cd ~/Pictures/Unzipping

# while [ "$percent" -ge 1 ]
# do
#     percent="$(cat /sys/class/power_supply/BAT0/capacity)"
#     zip compressed_pictures.zip * && unzip compressed_pictures.zip
# done


while true; do

  percent=$(cat /sys/class/power_supply/BAT0/capacity)

  if [ "$percent" -lt 1 ]; then
    break  # Exit the loop if battery percentage drops below 1
  fi

  zip compressed_pictures.zip *  # Compress the files

  find -type f ! -name 'compressed_pictures.zip' -delete

  # Add a delay before unzipping to simulate some activity

  unzip -o compressed_pictures.zip  # Unzip the files
  rm compressed_pictures.zip

  # Add a longer delay before starting the next iteration
  sleep 5

done

