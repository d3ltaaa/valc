#!/bin/bash

# eval $(dbus-launch --sh-syntax)
export DISPLAY=:0

if [[ $(cat /home/falk/test) == "1" ]]; then
  while [ 1 ]; do
    echo "1"
    dunstify "1"
    sleep 10
  done
else
  echo "0"
  dunstify "0"
fi
