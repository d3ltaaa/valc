hyprctl dispatch resizeactive exact $(slurp | awk '{print $2}' | awk -F'x' '{print $1,$2}')
