#!/bin/bash

# Get battery information from upower
battery_info=$(upower -i $(upower -e | grep 'BAT'))

# Extract time to empty (discharge) and time to full (charge)
time_to_empty=$(echo "$battery_info" | grep "time to empty" | awk -F':' '{print $2}' | xargs)
time_to_full=$(echo "$battery_info" | grep "time to full" | awk -F':' '{print $2}' | xargs)

# Get battery percentage and status
percentage=$(echo "$battery_info" | grep "percentage" | awk '{print $2}')
status=$(echo "$battery_info" | grep "state" | awk '{print $2}')

time_string=""
# Determine what to display
if [[ "$status" == "charging" && -n "$time_to_full" ]]; then
  time_string="$time_to_full until full"
elif [[ "$status" == "discharging" && -n "$time_to_empty" ]]; then
  time_string="$time_to_empty"
else
  time_string="Status: $status"
fi

# Get battery percentage and charging status
percentage=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

# Define icons
charging_icons=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
default_icons=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

# Determine icon index (0-9)
index=$((percentage / 10))
[ "$index" -gt 9 ] && index=9 # Ensure index stays within bounds

# Select icon based on charging status
if [[ "$status" == "Charging" ]]; then
  icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
  echo "Charged "
  exit 0
else
  icon=${default_icons[$index]}
fi

# Output percentage and icon
echo "$percentage% $icon"

# Read raw values
voltage_uV=$(cat /sys/class/power_supply/BAT0/voltage_now)
current_uA=$(cat /sys/class/power_supply/BAT0/current_now)

# Convert to volts and amps
voltage_V=$(awk "BEGIN {print $voltage_uV / 1000000}")
current_A=$(awk "BEGIN {print $current_uA / 1000000}")

# Calculate power draw in watts
power_W=$(awk "BEGIN {printf \"%.lf\",  $voltage_V * $current_A}")

# Output result
echo "{\"text\":\"${percentage}% $icon\", \"tooltip\":\"${time_string} | ${power_W}W\"}"
