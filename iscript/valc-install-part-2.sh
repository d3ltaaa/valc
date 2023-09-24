#!/bin/bash


exe () {
    # exe hepls "contain a block of code in a repeatable format in case something goes wrong
    return_code=1
    while [ $return_code -ne 0 ]; do

        "$@"
        
        return_code=$?
        # check if everything worked
        if [ $return_code -eq 0 ]; then
            echo "================>>      Checks out"; sleep 1
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
    clear; echo "================>>      $1"
    sleep 1
}

CONFIG_PATH="/config"
USE_CONFIG_FILE=0
VALUE_TIME_SETUP=0
VALUE_LANG_SETUP=0
VALUE_KB_SETUP=0
VALUE_HOSTNAME_SETUP=0
VALUE_USERNAME_SETUP=0
VALUE_GRUB_SETUP=0


determine_config () {

    if [ -e $CONFIG_PATH ]; then
        echo "config found"
        USE_CONFIG_FILE=1
    fi


    if [[ $USE_CONFIG_FILE -eq 1 ]]; then

        while true; do

            invalid_value=0
            echo "exe update_system"
            echo "exe ena_parallel "
            echo "exe time_setup: T"
            echo "exe language_setup: L "
            echo "exe kb_setup: K "
            echo "exe host_name: H "
            echo "exe host_setup "
            echo "exe host_pw "
            echo "exe user_name: U"
            echo "exe user_add "
            echo "exe user_pw "
            echo "exe user_mod "
            echo "exe inst_sudo "
            echo "exe inst_important "
            echo "exe grub_setup: G "
            echo "exe network_manager "
            echo "exe inst_part"

            read -p "What do you want to use the config file for? [T/L/K/H/U/G]: " choice

            choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

            if [ -z "$choice" ]; then
                USE_CONFIG_FILE=0
            fi


            for char in $(echo "$choice" | grep -o .); do
                case "$char" in
                    t)
                        VALUE_TIME_SETUP=1
                        ;;
                    l)
                        VALUE_LANG_SETUP=1
                        ;;
                    k)
                        VALUE_KB_SETUP=1
                        ;;
                    h)
                        VALUE_HOSTNAME_SETUP=1
                        ;;
                    u)
                        VALUE_USERNAME_SETUP=1
                        ;;

                    g)
                        VALUE_GRUB_SETUP=1
                        ;;
                    *)
                        invalid_value=1
                        break
                        ;;
                esac
            done

            if [ $invalid_value -eq 0 ]; then
                break;
            fi

        done
    fi

}

update_system () {

    notification "Update System"
    pacman -Syu --noconfirm 
    [ $? -ne 0 ] && return 22 || : 
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
    
    notification "Time setup"

    # time
    if [ $VALUE_TIME_SETUP -eq 1 ]; then
        time_zone=$(grep -i -w TIME $CONFIG_PATH | awk '{print $2}') &&
        ln -sf /usr/share/zoneinfo${time_zone} /etc/localtime &&
        hwclock --systohc
        [ $? -ne 0 ] && return 23 || :

    else
        ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime &&
        hwclock --systohc
        [ $? -ne 0 ] && return 23 || :
    fi
}

language_setup () {
    # language
    notification "Language setup"

    
    if [ $VALUE_LANG_SETUP -eq 1 ]; then

        lang1=$(grep -i -w -A2 LANGUAGE $CONFIG_PATH | awk 'NR==2')
        lang2=$(grep -i -w -A2 LANGUAGE $CONFIG_PATH | awk 'NR==3')

        echo "$lang1" >> /etc/locale.gen &&
        locale-gen &&
        echo "$lang2" > /etc/locale.conf
        [ $? -ne 0 ] && return 24 || :

    else
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&
        locale-gen &&
        echo "LANG=en_US.UTF-8" > /etc/locale.conf
        [ $? -ne 0 ] && return 24 || :
    fi
}

kb_setup () {
    
    # keyboard layout
    notification "Keyboard layout"
    if [ $VALUE_KB_SETUP -eq 1 ]; then

        kb=$(grep -i -w KEYBOARD $CONFIG_PATH | awk '{print $2}')
        echo "KEYMAP=$kb" > /etc/vconsole.conf
        [ $? -ne 0 ] && return 25 || :
    else
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
    fi
}

host_name () {

    # Hostname
    notification "Hostname"

    if [ $VALUE_HOSTNAME_SETUP -eq 1 ]; then

        hn=$(grep -i -w NAME $CONFIG_PATH | awk '{print $2}') 

        hostname=$hn
    else

        read -p "What is the hostname?: " hostname 

        while true; do

            read -p "Is it spelled correctly? [y/n]: " yn

            case $yn in

                [yY]* ) break;; 

                [nN]* ) return 26;;

                * ) echo "Enter 'y' or 'n'!";;
            esac
        done
    fi
}

host_setup () {

    notification "Host setup"

    echo $hostname > /etc/hostname &&

    echo "127.0.0.1       localhost" >> /etc/hosts &&
    echo "::1             localhost" >> /etc/hosts &&
    echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

    [ $? -ne 0 ] && return 27 || :

}

host_pw () {
    
    notification "Host password"
    passwd
    [ $? -ne 0 ] && return 28 || :
}

user_name () {

    # User
    notification "Username"

    if [ $VALUE_USERNAME_SETUP -eq 1 ]; then
        us=$(grep -i -w USER $CONFIG_PATH | awk '{print $2}')
        user=$us
    else
        read -p "What is the Username?: " user


        while true; do

            read -p "Is it spelled correctly? [y/n]: " yn

            case $yn in

                [yY]* ) break;; 

                [nN]* ) return 29;;

                * ) echo "Enter 'y' or 'n'!";;
            esac
        done
    fi
}

user_add () {
    notification "Adding user"
    useradd -m $user 
    [ $? -ne 0 ] && return 30 || :
}

user_pw () {
    notification "User password for $user"

    passwd $user
    [ $? -ne 0 ] && return 31 || :
}

user_mod () {
    notification "User mod"

    usermod -aG wheel,audio,video $user
    [ $? -ne 0 ] && return 32 || :
}

inst_sudo () {
    notification "Installing and setting up sudo"
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


    if [[ $VALUE_GRUB_SETUP -eq 1 ]]; then

        disk_to_par=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==2'))
        par_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==3'))
        par_type_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==7'))
        dual_boot="$(cat .config.cfg | grep -w PARTITION: | awk '{print $2}')"

        for (( i=0; i<${#par_type_arr[@]}; i++ )); do
            if [[ "${par_type_arr[$i]}" == "swap" ]]; then
                sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=\/dev\/'"${par_arr[$i]}"'"/' /etc/default/grub
            fi
        done

        if [[ "$dual_boot" == "dual" ]]; then
            sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=-1/' /etc/default/grub
            sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
        fi

    else

        GRUB_PAR=""

        until [[ -e $GRUB_PAR ]]; do

            if [[ ! -z $GRUB_PAR ]]; then

                echo "Give valid partition name (or 'no')!"

            fi

            read -p "What is the swap partition (GRUB-SETUP): " -e -i "/dev/" GRUB_PAR

            if [[ $GRUB_PAR == "no" ]]; then
                break
            fi

        done
        
        if [[ ! $GRUB_PAR == "no" ]]; then
            sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=\/dev\/'"$GRUB_PAR"'"/' /etc/default/grub
        fi



        GRUB_DUAL=""

        until [[ $GRUB_DUAL =~ (dual|no) ]]; do

            if [[ ! -z $GRUB_DUAL ]]; then

                echo "Either: dual or no!"

            fi

            read -p "Do you want to dual boot?" -e -i "no" GRUB_DUAL

        done
        
        if [[ "$GRUB_DUAL" == "dual" ]]; then
            sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=-1/' /etc/default/grub
            sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
        fi
    fi

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

systemd_setup () {

    notification "systemd & initcpio"
    sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=poweroff/' /etc/systemd/logind.conf
    sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=hibernate/' /etc/systemd/logind.conf
    sed -i 's/^HOOKS=(base udev/HOOKS=(base udev resume/' /etc/mkinitcpio.conf

    mkinitcpio -P
    grub-mkconfig -o /boot/grub/grub.cfg

}

inst_part () {
   
    notification "Installing next valc-installation-part"
    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/iscript/valc-install-part-3.sh > /home/$user/valc-install-part-3.sh &&
    chmod +x /home/$user/valc-install-part-3.sh
    [ $? -ne 0 ] && return 39 || :
    
}

exe update_system

exe determine_config

exe ena_parallel

exe time_setup #

exe language_setup #

exe kb_setup #

exe host_name #

exe host_setup 

exe host_pw 

exe user_name #

exe user_add

exe user_pw 

exe user_mod

exe inst_sudo

exe inst_important

exe grub_setup

exe network_manager

exe systemd_setup

exe inst_part

clear
echo "The next commands are: "
echo "exit; umount -R /mnt; reboot"
echo "When it loads, the device has to be shut off again, and the usb-stick is to be taken out!"


