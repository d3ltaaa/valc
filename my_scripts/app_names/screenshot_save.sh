#!/bin/bash
# menu="dmenu -i"
menu="rofi -dmenu -i"
DIR="/home/falk/Pictures/Screenshots"
# take screenshot and open
grim -g "$(slurp)" "$DIR/temp.png" &&
  feh --scale-down --auto-zoom "$DIR/temp.png" &&
  selected=$(printf 'yes\nno' | $menu -p "Save?:")
case $selected in
"yes")
  # give name
  NAME="$($menu -p "Name:")"
  FILE_NAME="$DIR/$NAME.png"
  mv "$DIR/temp.png" "$FILE_NAME"
  exit 0
  ;;

"*") ;;
esac
# delete if not yes (also if menu is cancelled)
rm "$DIR/temp.png"
