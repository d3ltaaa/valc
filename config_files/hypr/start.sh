#!/usr/bin/env bash

# swallow
# exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY

swww init &
swww img ~/.config/wall/selected*

waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
