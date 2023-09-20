#!/bin/bash

# check if on thinkpad
device_name=$(grep NAME: .config.cfg | awk '{print $2}')
if [[ ! "$device_name" == "THINKPAD-FH" ]]; then
    echo "Executing the script on the wrong device!"
    exit 1
fi

# Audio device
# useful commands
# pacmd list-sources | grep -A1 index:
audio_dev=""
steel="alsa_input.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.mono-fallback"
# linkbuds="bluez_sink.F8_4E_17_76_68_73.a2dp_sink.monitor"

# determine mic
until [[ $mic_to_use =~ (1|2) ]]; do
    read -rp "Use built-in-mic (1) or steelseries (2)? [1/2/3]: " -e -i 1 mic_to_use
done

if [[ $mic_to_use == "1" ]]; then
    audio_dev="default"
elif [[ $mic_to_use == "2" ]]; then
    audio_dev="$steel"
else
    echo "Selected mic not available"
    audio_dev="default"
fi



# name
name=""
date_string=$(date +"%d.%m_%H-%M")
folder_name=$(date +"node_%d.%m_%H-%M")
rec_name=$(date +"rec_%d.%m_%H-%M")
sum_name=$(date +"sum_%d.%m_%H-%M")

# Path
read -rp "Path: " -e -i "/mnt/CRUCIAL-SSD/Videos/Recordings/$folder_name" path
mkdir -p $path

# actual command
ffmpeg -f pulse -ac 2 -i $audio_dev -f v4l2 -i /dev/video0 -vcodec libx264 $path/$name.mp4

# After recording
touch $path/$sum_name.txt

echo "Tag:" >> $path/$sum_name.txt

echo "" >> $path/$sum_name.txt

echo "Gedanken:" >> $path/$sum_name.txt

nvim $path/$sum_name.txt &

mpv $path/$name.mp4

