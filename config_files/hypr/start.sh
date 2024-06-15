#!/usr/bin/env bash

swww-daemon &
swww img ~/.config/wall/selected*

waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
