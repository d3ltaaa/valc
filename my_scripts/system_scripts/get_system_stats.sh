#!/bin/bash

# Initialize variables
total_power_draw=0
total_remaining_capacity=0
battery_count=0

# Loop through possible battery files (BAT0, BAT1, etc.)
for battery in /sys/class/power_supply/BAT*/power_now; do
  # Check if the battery exists and is readable
  if [ -f "$battery" ]; then
    # Get the battery name (BAT0, BAT1, etc.)
    battery_name=$(basename $(dirname "$battery"))

    # Read current power draw (in microwatts)
    power_now=$(cat "$battery")
    total_power_draw=$((total_power_draw + power_now))

    # Get battery capacity and remaining capacity (in microamp-hours or microvolts, depending on the system)
    capacity_file="/sys/class/power_supply/$battery_name/energy_full"
    remaining_capacity_file="/sys/class/power_supply/$battery_name/energy_now"

    if [ -f "$capacity_file" ] && [ -f "$remaining_capacity_file" ]; then
      full_capacity=$(cat "$capacity_file")
      remaining_capacity=$(cat "$remaining_capacity_file")

      # Accumulate the remaining capacity
      total_remaining_capacity=$((total_remaining_capacity + remaining_capacity))

      # Update battery count
      battery_count=$((battery_count + 1))
    fi
  fi
done

# If we found at least one battery, calculate and print the results
if [ "$battery_count" -gt 0 ]; then
  power_stat_factor="1.4"

  # Calculate total power draw in watts (from microwatts to watts)
  power_draw_watts=$(echo "scale=1; $total_power_draw * $power_stat_factor/1000000" | bc)

  # Calculate combined time remaining in seconds (total remaining capacity divided by total power draw)
  if [ "$total_power_draw" -gt 0 ]; then
    # Remaining time in seconds
    remaining_time_seconds=$(echo "scale=1; $total_remaining_capacity/($total_power_draw * $power_stat_factor)" | bc)
  else
    remaining_time_seconds=0
  fi

  # Print the output
  power_string="${power_draw_watts}W / ${remaining_time_seconds}H"
fi

# Get CPU usage
# CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF"%"}')

# Get RAM usage
RAM_USED=$(free -h | awk '/Mem:/ {print $3}' | sed 's/i//')
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}' | sed 's/i//')
ram_string="$RAM_USED/$RAM_TOTAL  "

# Cpu temp

# Check if the temperature file exists
temp_file="/sys/class/thermal/thermal_zone0/temp"

if [ -f "$temp_file" ]; then
  # Read the temperature (it is in millidegrees Celsius)
  cpu_temp_millidegrees=$(cat "$temp_file")

  # Convert to degrees Celsius
  cpu_temp=$((cpu_temp_millidegrees / 1000))

  # Print the temperature
  cpu_string="$cpu_temp°C  "
fi

# Output JSON for Waybar
# echo "{\"text\": \"󰘚 CPU: $CPU_USAGE |  RAM: $RAM_USED/$RAM_TOTAL | 🌡️ Temp: $TEMP | 🔋 Power: $POWER\"}"
# echo "{\"text\": \" \", \"tooltip\": \"$ram_string\n$cpu_string\n$power_string\"}"
echo "{\"text\": \"$ram_string | $cpu_string | $power_string\" }"
