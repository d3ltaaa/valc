#!/bin/bash

# install ntp
pacman -S ntp

# force synchronisation
ntpd -qg

# enable and start service
systemctl enable ntpd
systemctl start ntpd

# update system clock
hwclock --systohc
