#!/bin/bash
if [[ ! -f "ip_address" ]]; then
	touch ip_address
fi


client_ip_address=$(ip a | grep -w swlan0: -A2 | awk 'NR==3 {print substr($2, 1, length($2) - 3)}')
echo "$client_ip_address" > ip_address

scp ip_address falk@192.168.2.31:/home/falk/.ssh/

ssh falk@192.168.2.31 << 'EOF'
line_number_phone=$(grep -n "PHONESPOT" /home/falk/.ssh/config | cut -d ':' -f 1)
line_number_hostname=$(grep -A3 "PHONESPOT" /home/falk/.ssh/config | grep -n "HostName" | cut -d ':' -f 1)
line_number=$(($line_number_phone + $line_number_hostname -1))
phone_ip=$(cat /home/falk/.ssh/ip_address)
sed -i "${line_number}s/.*/    HostName $phone_ip/" /home/falk/.ssh/config
EOF
