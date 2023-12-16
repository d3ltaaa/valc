CONFIG_PATH="/config"
INSTALL_OPTION_PATH="/install"

exe () {
    # exe hepls contain a block of code in a repeatable format in case something goes wrong
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


update_system () {

    fname="update_system"

    notification "$fname"

    pacman -Syu --noconfirm 
    [ $? -ne 0 ] && return 22 || : 
}


ena_parallel () {

    fname="ena_parallel"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        parallel=$(grep -i -w PARALLEL: $CONFIG_PATH | awk '{print $2}') &&
        sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = $parallel/" /etc/pacman.conf
        [ $? -ne 0 ] && return 13 || : 

    else

        read -p "How many downloads do you want to do simultaneously?: " parallel
        sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = $parallel/" /etc/pacman.conf
        [ $? -ne 0 ] && return 13 || : 

    fi
}


time_setup () {

    fname="time_setup"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        time_zone=$(grep -i -w TIME: $CONFIG_PATH | awk '{print $2}') &&
        ln -sf /usr/share/zoneinfo${time_zone} /etc/localtime &&
        hwclock --systohc
        [ $? -ne 0 ] && return 23 || :

    else

        read -p "What is your timezone?: " time_zone
        ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime &&
        hwclock --systohc
        [ $? -ne 0 ] && return 23 || :
    fi
}


language_setup () {

    fname="language_setup"

    notification "$fname"
    
    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        lang1=$(grep -i -w -A2 LANGUAGE: $CONFIG_PATH | awk 'NR==2')
        lang2=$(grep -i -w -A2 LANGUAGE: $CONFIG_PATH | awk 'NR==3')

        echo "$lang1" >> /etc/locale.gen &&
        locale-gen &&
        echo "$lang2" > /etc/locale.conf
        [ $? -ne 0 ] && return 24 || :

    fi
}


kb_setup () {

    fname="kb_setup"

    notification "$fname"
   
    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        kb=$(grep -i -w KEYBOARD: $CONFIG_PATH | awk '{print $2}')
        echo "KEYMAP=$kb" > /etc/vconsole.conf
        [ $? -ne 0 ] && return 25 || :

    else
        read -p "What keyboard layout do you want to use?: " kb
        echo "KEYMAP=$kb" > /etc/vconsole.conf
        [ $? -ne 0 ] && return 25 || :
    fi

}


host_name () {

    fname="host_name"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        hostname=$(grep -i -w NAME: $CONFIG_PATH | awk '{print $2}') 

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

    fname="host_setup"

    notification "$fname"

    echo $hostname > /etc/hostname &&

    echo "127.0.0.1       localhost" >> /etc/hosts &&
    echo "::1             localhost" >> /etc/hosts &&
    echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

    [ $? -ne 0 ] && return 27 || :
}


host_pw () {

    fname="host_pw"

    notification "$fname"

    passwd
    [ $? -ne 0 ] && return 28 || :
}


user_name () {

    fname="user_name"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        user=$(grep -i -w USER: $CONFIG_PATH | awk '{print $2}')

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

    fname="user_add"

    notification "$fname"

    useradd -m $user 
    [ $? -ne 0 ] && return 30 || :
}


user_pw () {

    fname="user_pw"

    notification "$fname"

    passwd $user
    [ $? -ne 0 ] && return 31 || :
}


user_mod () {

    fname="user_mod"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        group_string=""

        groups=($(grep -i -w USER_GROUPS: $CONFIG_PATH | cut -d' ' -f2-))
        custom_groups=($(grep -i -w CUSTOM_GROUPS: $CONFIG_PATH | cut -d' ' -f2-))

        for group in ${groups[@]}; do
            group_string+="$group,"
        done

        for group in ${custom_groups[@]}; do
            groupadd $group
            group_string+="$group,"
        done

        # remove last string (,)
        group_string="${group_string%?}"

        usermod -aG $group_string $user
        [ $? -ne 0 ] && return 32 || :


    fi

}


inst_important_packages () {

    fname="inst_important_packages"

    notification "$fname"

    pacman --noconfirm -S sudo &&
    sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers | sudo EDITOR='tee -a' visudo
    [ $? -ne 0 ] && return 33 || :

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then
        
        beg=$(grep -n -i -w IMPORTANT_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :IMPORTANT_PACKAGES $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        imp_packages=$(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH)

        pacman --noconfirm -S $imp_packages
        [ $? -ne 0 ] && return 34 || :

    else

        read -p "What important packages do you want to install?: " imp_packages

        pacman  --noconfirm -S $imp_packages
        [ $? -ne 0 ] && return 34 || :

    fi

}


grub_setup () {

    fname="grub_setup"

    notification "$fname"

    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader=GRUB --removable 

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then


        disk_to_par=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==2'))
        par_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==3'))
        par_type_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==7'))
        dual_boot=$(grep -i -w PARTITION: $CONFIG_PATH | awk '{print $2}')

        for (( i=0; i<${#par_type_arr[@]}; i++ )); do
            if [[ "${par_type_arr[$i]}" == "swap" ]]; then
                sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=\/dev\/'"${par_arr[$i]}"'"/' /etc/default/grub
            fi
        done

        if [[ "$dual_boot" == "dual" ]]; then
            sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=-1/' /etc/default/grub
            sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=0/' /etc/default/grub
            sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
            echo "ok"
        fi

    else

        GRUB_PAR="temp"

        until [[ -e /dev/$GRUB_PAR ]]; do

            if [[ ! -z /dev/$GRUB_PAR ]]; then

                echo "Give valid partition name (or 'no')!"

            fi

            lsblk
            read -p "What is the swap partition (GRUB-SETUP): /dev/" GRUB_PAR

            if [[ $GRUB_PAR == "no" ]]; then
                break
            fi

        done
        
        if [[ ! "$GRUB_PAR" == "no" ]]; then
            sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=\/dev\/'"$GRUB_PAR"'"/' /etc/default/grub
        fi



        GRUB_DUAL=""

        until [[ $GRUB_DUAL =~ (dual|no) ]]; do

            if [[ ! -z $GRUB_DUAL ]]; then

                echo "Either: dual or no!"

            fi

            read -p "Do you want to dual boot?: " -e -i "no" GRUB_DUAL

        done
        
        if [[ "$GRUB_DUAL" == "dual" ]]; then
            sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=-1/' /etc/default/grub
            sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            # sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=0/' /etc/default/grub
            echo ok
        fi
    fi

    # sed -i 's/quiet/pci=noaer/g' /etc/default/grub
    # sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    [ $? -ne 0 ] && return 36 || :
}


systemd_setup () {

    fname="systemd_setup"

    notification "$fname"

    sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=poweroff/' /etc/systemd/logind.conf
    sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=hibernate/' /etc/systemd/logind.conf
    sed -i 's/^HOOKS=(base udev/HOOKS=(base udev resume/' /etc/mkinitcpio.conf

    mkinitcpio -P &&
    grub-mkconfig -o /boot/grub/grub.cfg
    [ $? -ne 0 ] && return 37 || :

}


enable_services_root () {

    fname="enable_services_root"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        services=($(grep -i -w SERVICES: $CONFIG_PATH | cut -d' ' -f2-))

        for service in ${services[@]}; do
            systemctl enable $service
            [ $? -ne 0 ] && return 44 || :

        done

    fi

}

inst_part_3 () {

    fname="inst_part"

    notification "$fname"

    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_scripts/valc-3.sh > /home/$user/valc-3.sh
    chmod +x /home/$user/valc-3.sh
    [ $? -ne 0 ] && return 39 || :

}


exe update_system
exe ena_parallel
exe time_setup
exe language_setup
exe kb_setup
exe host_name
exe host_setup
exe host_pw
exe user_name
exe user_add
exe user_pw
exe user_mod
exe inst_important_packages
exe grub_setup
exe systemd_setup
exe enable_services_root
exe inst_part_3
mv $CONFIG_PATH /home/$user
mv $INSTALL_OPTION_PATH /home/$user
clear
echo "The next commands are: "
echo "exit; umount -R /mnt; reboot"
echo "When it loads, the device has to be shut off again, and the usb-stick is to be taken out!"
