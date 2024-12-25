#!/usr/bin/env bash

swww-daemon &
swww img ~/.config/wall/selected*

hyprpm reload -n --notify-fail
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
