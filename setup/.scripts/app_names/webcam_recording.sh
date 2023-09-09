#!/bin/bash

# useful commands
# pacmd list-sources | grep -A1 index:

# variables
name=""
audio_dev=""
steel="alsa_input.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.mono-fallback"
path="/home/$USER/Videos/Recordings"
# linkbuds="bluez_sink.F8_4E_17_76_68_73.a2dp_sink.monitor"


# determine mic
until [[ $mic_to_use =~ (1|2) ]]; do
    read -rp "Use built-in-mic (1) or steelseries (2)? [1/2/3]: " -e -i 1 mic_to_use
done

if [[ $mic_to_use == "1" ]]; then
    audio_dev="default"
elif [[ $mic_to_use == "2" ]]; then
    audio_dev="$steel"
# elif [[ $mic_to_use == "3" ]]; then
#     audio_dev="$linkbuds"
else
    echo "Selected mic not available"
    audio_dev="default"
fi

# name
name=$(date +"Rec_%d.%m_%H-%M")

read -p "Name: " -e -i $name name

# actual command
ffmpeg -f pulse -ac 2 -i $audio_dev -f v4l2 -i /dev/video0 -vcodec libx264 $path/$name.mp4
