#!/bin/bash

exe () {
    exit_code=1
    while [ $exit_code -ne 0 ]; do

        $1

        # check if everything worked
        if [ $? -eq 0 ]; then
            exit_code=0
            echo "Checks out"; sleep 1
            break
        fi

        while true; do
            read -p "Something went wrong here :( Do you want to redo the command? [y/n]: " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit_code=0; break;;
                * ) echo "Enter 'y' or 'n'!";;
            esac
        done
    done
}

notification () {
    clear; echo "$1"; sleep 1
}

ena_parallel () {

    # set a new index for parallel downloads
    # first install sed
    notification "Installing sed"
    pacman -S --noconfirm sed

    notification "Enable parallel downloads"
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf 
}


time_setup () {
    
    # time
    notification "Time setup"
    ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

    hwclock --systohc
}

language_setup () {
    # language
    notification "Language setup"
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

kb_setup () {
    
    # keyboard layout
    notification "Keyboard layout"
    ans_layout=""
    while true; do

        read -p "Do you want to use the German keyboard layout? [y/n]: " yn

        case $yn in

            [yY]* ) echo "KEYMAP=de-latin1" > /etc/vconsole.conf; break;;
            [nN]* ) echo "Not accessible yet"; sleep 2;;
            * ) echo "Enter 'y' or 'n'!";;
        esac
    done
}

host_setup () {

    # Hostname
    notification "Hostname"
    echo "HOSTNAME: "
    read hostname
    echo $hostname > /etc/hostname

    echo "127.0.0.1       localhost" >> /etc/hosts
    echo "::1             localhost" >> /etc/hosts
    echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

}

user_setup () {

    # User
    notification "User"
    passwd
    echo "USER: "
    read user
    useradd -m $user
    echo "Password for $user: "
    passwd $user
    usermod -aG wheel,audio,video $user
    pacman --noconfirm -S sudo
    sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers | sudo EDITOR='tee -a' visudo

}

inst_important () {

    notification "Installing important packages"
    pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

}

grub_setup () {

    # grub
    notification "Setting up grub"
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader=GRUB --removable
    # sed -i 's/quiet/pci=noaer/g' /etc/default/grub
    # sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

}

network_manager () {

    # network manager 
    notification "Installing and setting up Networkmanager"
    pacman --noconfirm -S networkmanager
    systemctl enable NetworkManager

}

inst_part () {
   
    notification "Installing next valc-installation-part"
    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/iscript/valc-install-part-3.sh > /home/$user/valc-install-part-3.sh
    chmod +x /home/$user/valc-install-part-3.sh

}

exe ena_parallel

exe time_setup

exe language_setup

exe kb_setup

exe host_setup 

exe user_setup

exe inst_important

exe grub_setup

exe network_manager

exe inst_part

clear
echo "The next commands are: "
echo "exit; umount -R /mnt; reboot"
echo "When it loads, the device has to be shut off again, and the usb-stick is to be taken out!"


