#!/bin/bash

CONFIG_PATH="~/.config.cfg"

read -p "Manual ip management? [0/1]: " VALUE_IP_SETUP

if [ $VALUE_IP_SETUP -eq 1 ]; then

        wlan=$(grep -i -w -A1 WLAN $CONFIG_PATH | awk 'NR==2')

        ip_gate=$(grep -i -w GATE $CONFIG_PATH | awk '{print $2}')

        ip_lan=$(grep -i -w LAN $CONFIG_PATH | awk '{print $2}')

        ip_wifi=$(grep -i -w WIFI $CONFIG_PATH | awk '{print $2}')



        for (( i=1; i<=3; i++)); do

            nmcli connection modify "Wired connection $i" ipv4.method manual ipv4.address $ip_lan/24 ipv4.gateway $ip_gate

        done

        nmcli connection modify "$wlan" ipv4.method manual ipv4.address $ip_wifi/24 ipv4.gateway $ip_gate

    else

        read -p "What is the name of your Wlan?: " wlan
        read -p "What is your ipv4.gateway?: " ip_gate
        read -p "What ip for lan?: " ip_lan
        read -p "What ip for wifi?: " ip_wifi

        while true; do

            read -p "Is it spelled correctly? [y/n]: " yn

            case $yn in

                [yY]* ) break;; 

                [nN]* ) return 31;;

                * ) echo "Enter 'y' or 'n'!";;
            esac
        done


        for (( i=1; i<=3; i++)); do

            nmcli connection modify "Wired connection $i" ipv4.method manual ipv4.address $ip_lan/24 ipv4.gateway $ip_gate

        done

        nmcli connection modify "$wlan" ipv4.method manual ipv4.address $ip_wifi/24 ipv4.gateway $ip_gate

    fi

