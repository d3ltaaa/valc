#!/bin/bash


exe () {
    # exe hepls "contain a block of code in a repeatable format in case something goes wrong
    return_code=1
    while [ $return_code -ne 0 ]; do

        "$@"
        
        return_code=$?
        # check if everything worked
        if [ $return_code -eq 0 ]; then
            echo "Checks out"; sleep 1
            break
        fi

        while [ $return_code -ne 0 ]; do
            echo "Error code: $return_code !"
            read -p "Something went wrong here :( Do you want to redo the command? [y/n]: " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) return_code=0; break;;
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
    notification "Installing sed and enabling parallel downloads"
    pacman -S --noconfirm sed &&
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf 
    [ $? -ne 0 ] && return 22 || : 
}


time_setup () {
    
    # time
    notification "Time setup"
    ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime &&
    hwclock --systohc
    [ $? -ne 0 ] && return 23 || :
}

language_setup () {
    # language
    notification "Language setup"
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&
    locale-gen &&
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    [ $? -ne 0 ] && return 24 || :
}

kb_setup () {
    
    # keyboard layout
    notification "Keyboard layout"
    ans_layout=""
    while true; do

        read -p "Do you want to use the German keyboard layout? [y/n]: " yn

        case $yn in

            [yY]* ) 
                echo "KEYMAP=de-latin1" > /etc/vconsole.conf
                [ $? -ne 0 ] && return 25 || :

                break;;
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

    while true; do

        read -p "Is it spelled correctly? [y/n]: " yn

        case $yn in

            [yY]* ) break;; 

            [nN]* ) return 26;;

            * ) echo "Enter 'y' or 'n'!";;
        esac
    done

    echo $hostname > /etc/hostname &&

    echo "127.0.0.1       localhost" >> /etc/hosts &&
    echo "::1             localhost" >> /etc/hosts &&
    echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

    [ $? -ne 0 ] && return 27 || :

}

user_setup () {

    # User
    notification "User"
    passwd
    [ $? -ne 0 ] && return 28 || :

    echo "USER: "
    read user


    while true; do

        read -p "Is it spelled correctly? [y/n]: " yn

        case $yn in

            [yY]* ) break;; 

            [nN]* ) return 29;;

            * ) echo "Enter 'y' or 'n'!";;
        esac
    done

    useradd -m $user 
    [ $? -ne 0 ] && return 30 || :

    echo "Password for $user: " &&
    passwd $user
    [ $? -ne 0 ] && return 31 || :
 
    usermod -aG wheel,audio,video $user
    [ $? -ne 0 ] && return 32 || :

    pacman --noconfirm -S sudo &&
    sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers | sudo EDITOR='tee -a' visudo
    [ $? -ne 0 ] && return 33 || :

}

inst_important () {

    notification "Installing important packages"
    pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
    [ $? -ne 0 ] && return 34 || :

}

grub_setup () {

    # grub
    notification "Setting up grub"
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader=GRUB --removable 
    [ $? -ne 0 ] && return 35 || :


    # sed -i 's/quiet/pci=noaer/g' /etc/default/grub
    # sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    [ $? -ne 0 ] && return 36 || :

}

network_manager () {

    # network manager 
    notification "Installing and setting up Networkmanager"
    pacman --noconfirm -S networkmanager 
    [ $? -ne 0 ] && return 37 || :

    systemctl enable NetworkManager
    [ $? -ne 0 ] && return 38 || :

}

inst_part () {
   
    notification "Installing next valc-installation-part"
    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/iscript/valc-install-part-3.sh > /home/$user/valc-install-part-3.sh &&
    chmod +x /home/$user/valc-install-part-3.sh
    [ $? -ne 0 ] && return 39 || :
    
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


