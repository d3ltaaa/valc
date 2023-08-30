#!/bin/bash
# This script is used to get the images from the phone into the remnote folder
# it also moves the transferred images from the downloads folder to the scans folder remotely


connection_=$(nmcli -t -f NAME connection show --active | head -n 1)

case $connection_ in 
    "Wired connection"* ) 
        remote_connection_type=wifi
        ;;
    "Wlan 12" )
        remote_connection_type=wifi
        ;;
    "Wlan FH" )
        remote_connection_type=spot
        ;;
    * )
        echo "Error: Client connection not supported!"
        exit 1
        ;;
esac

if [[ ! -d $1 ]]; then
    while true; do
        read -p "Do you want to create $1? [y/n]: " yn
        case $yn in
            [Yy]* ) 
                mkdir -p $1
                break
                ;;
            [Nn]* )
                exit 1
                ;;
            * )
                echo "Please enter 'y' or 'n'!"
                ;;
        esac
    done
fi

if [[ ! -d ~/Transfer ]]; then
    mkdir -p ~/Transfer
fi

scp -r ph$remote_connection_type:downloads/* ~/Transfer
scp -r ~/Transfer/* server:$1
mv ~/Transfer/* $1

ssh ph$remote_connection_type << 'EOF'
if [[ ! -d scans ]]; then
    mkdir scans
fi

mv downloads/* scans

if [[ $? -ne 0 ]]; then
    echo "No file in the 'downloads' folder!"
fi
EOF
