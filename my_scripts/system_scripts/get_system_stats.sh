#!/bin/bash

# Get CPU usage
# CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF"%"}')

# Get RAM usage
RAM_USED=$(free -h | awk '/Mem:/ {print $3}' | sed 's/i//')
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}' | sed 's/i//')

# Get CPU temperature (modify sensor name based on `sensors` output)
TEMP=$(sensors | grep temp1 | awk '{print $2}' | sed 's/+//')

# Get power draw (may need adjustment for your system)
# find file that contains power_now

# Output JSON for Waybar
# echo "{\"text\": \"󰘚 CPU: $CPU_USAGE |  RAM: $RAM_USED/$RAM_TOTAL | 🌡️ Temp: $TEMP | 🔋 Power: $POWER\"}"
echo "{\"text\": \"$RAM_USED/$RAM_TOTAL     $TEMP   $POWER\"}"
