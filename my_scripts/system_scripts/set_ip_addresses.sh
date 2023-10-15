#!/bin/bash

CONFIG_PATH=~/.config.cfg

adding_ip () {
    # ip_gate ip_lan wlan ip_wifi
 
        for (( i=1; i<=3; i++)); do

            if nmcli connection show | grep -q "Wired connection $i"; then

                nmcli connection modify "Wired connection $i" ipv4.method manual ipv4.address "$2"/24 ipv4.gateway "$1" && \
                    echo "Added: 'Wired connection $i' - $2"
            else 
                echo "Connection 'Wired connection $i' not known!"
            fi

        done

        nmcli connection modify "$3" ipv4.method manual ipv4.address "$4"/24 ipv4.gateway "$1" && \
            echo "Added: '$3' - $4" 

}

VALUE_IP_SETUP=""
until [[ $VALUE_IP_SETUP =~ (Y|y|N|n) ]]; do

    if [ ! -z $VALUE_IP_SETUP ]; then
        echo "Enter 'y' or 'n'!"
    fi

    read -p "Manual ip management? [Y/N]: " -e -i y VALUE_IP_SETUP

done


if [[ $VALUE_IP_SETUP == "Y" ]] || [[ $VALUE_IP_SETUP == "y" ]]; then

        wlan=$(grep -i -w -A1 WLAN $CONFIG_PATH | awk 'NR==2')

        ip_gate=$(grep -i -w GATE $CONFIG_PATH | awk '{print $2}')

        ip_lan=$(grep -i -w LAN $CONFIG_PATH | awk '{print $2}')

        ip_wifi=$(grep -i -w WIFI $CONFIG_PATH | awk '{print $2}')

        adding_ip "$ip_gate" "$ip_lan" "${wlan}" "$ip_wifi"

    else

        read -p "What is the name of your Wlan?: " -e -i "Wlan 12"     wlan
        read -p "What is your ipv4.gateway?: "     -e -i "192.168.2.1" ip_gate
        read -p "What ip for lan?: "               -e -i "192.168.2."  ip_lan
        read -p "What ip for wifi?: "              -e -i "192.168.2."  ip_wifi

        while true; do

            read -p "Is it spelled correctly? [y/n]: " yn

            case $yn in

                [yY]* ) break;; 

                [nN]* ) return 31;;

                * ) echo "Enter 'y' or 'n'!";;
            esac
        done

        adding_ip "$ip_gate" "$ip_lan" "$wlan" "$ip_wifi"


fi

sudo systemctl restart NetworkManager


