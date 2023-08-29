#!/bin/bash

# is to be installed on phone to send its own ip address to the computer in the network so that the 
# computer can connect to the phone

HOTSPOT_START=90 # specific to hotspot configuration (dynamic ip address 90 - *)

sshd

if [[ ! -f "ip_address" ]]; then
	touch ip_address
fi


client_ip_address=$(ip a | grep -w swlan0: -A2 | awk 'NR==3 {print substr($2, 1, length($2) - 3)}')
echo "$client_ip_address" > ip_address

pc_ip_address=$(echo $client_ip_address | cut -d '.' -f 1-3)

scp ip_address falk@$pc_ip_address.$HOTSPOT_START:/home/falk/.ssh/

ssh falk@$pc_ip_address.$HOTSPOT_START << 'EOF'
line_number_phone=$(grep -n "phspot" /home/falk/.ssh/config | cut -d ':' -f 1)
line_number_hostname=$(grep -A3 "phspot" /home/falk/.ssh/config | grep -n "HostName" | cut -d ':' -f 1)
line_number=$(($line_number_phone + $line_number_hostname -1))
phone_ip=$(cat /home/falk/.ssh/ip_address)
sed -i "${line_number}s/.*/    HostName $phone_ip/" /home/falk/.ssh/config
EOF
