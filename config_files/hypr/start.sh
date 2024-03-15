#!/usr/bin/env bash

swww init &
swww img ~/.config/wall/selected*

waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
