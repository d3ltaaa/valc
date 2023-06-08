#!/bin/bash

# set a new index for parallel downloads
# first install sed

pacman -S --noconfirm sed

sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf 

# time

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

hwclock --systohc

# language

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# keyboard layout

ans_layout=""
while true; do

    read -p "Do you want to use the German keyboard layout? [y/n]: " yn

    case $yn in

        [yY]* ) echo "KEYMAP=de-latin1" > /etc/vconsole.conf; break;;
        [nN]* ) echo "Not accessible yet"; sleep 2;;
        * ) echo "Enter 'y' or 'n'!";;
    esac
done


    


# Hostname

echo "HOSTNAME: "
read hostname
echo $hostname > /etc/hostname

echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts




# User

passwd
echo "USER: "
read user
useradd -m $user
echo "Password for $user: "
passwd $user
usermod -aG wheel,audio,video $user
pacman --noconfirm -S sudo
sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers | sudo EDITOR='tee -a' visudo



pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

# EFI
mkdir /boot/EFI
echo "Enter EFI partition (1) (e.g.: /dev/nvme0n1p1): "
read efi_part
mount $efi_part /boot/EFI

# grub

grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader=GRUB --removable
# sed -i 's/quiet/pci=noaer/g' /etc/default/grub
# sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


# network manager 
pacman --noconfirm -S networkmanager
systemctl enable NetworkManager



curl https://raw.githubusercontent.com/d3ltaaa/valc/main/iscript/valc-install-part-3.sh > valc-install-part-3.sh
chmod +x valc-install-part-3.sh

echo "The next commands are: "
echo "exit; umount -R /mnt; reboot"
echo "When it loads, the device has to be shut off again, and the usb-stick is to be taken out!"


