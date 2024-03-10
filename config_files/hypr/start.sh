#!/usr/bin/env bash

swww init &
swww img ~/.config/swww/arch_nord_dark_bg.png &

waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
