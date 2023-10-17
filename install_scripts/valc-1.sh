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

    
question_purpose () {

    notification "Question purpose"

    VALUE_PURPOSE=""

    until [[ $VALUE_PURPOSE =~ (install|update) ]]; do

        if [[ ! -z $VALUE_PURPOSE ]]; then

            echo "Either: install or update!"

        fi

        read -p "What is your purpose [install/update]?: " VALUE_PURPOSE

    done

    touch /install
        
    if [[ $VALUE_PURPOSE == "install" ]]; then

        echo "1" > /install

    else

        echo "0" > install

    fi

}

determine_config () {

    while true; do

        invalid_value=0

        # echo "download_config           "
        # echo "determine_config          "
        echo "kb_setup_live:           a"
        # echo "time_setup_live           "
        # echo "upd_cache                 "
        echo "ena_parallel_live:       b"
        echo "config_partitioning:     1"
        echo "cfdisk_partitioning:     2"
        echo "fdisk_partitioning:      3"
        # echo "inst_part_2               "
        # echo "update_system             "
        echo "ena_parallel             c"
        echo "time_setup:              d"
        echo "language_setup:          e"
        echo "kb_setup:                f"
        echo "host_name:               g"
        # echo "host_setup                "
        # echo "host_pw                   "
        echo "user_name:               h"
        # echo "user_add                  "
        # echo "user_pw                   "
        echo "user_mod:                i"
        echo "inst_important_packages: j"
        echo "grub_setup:              k"
        echo "systemd_setup:           l"
        # echo "inst_part_3               "
        echo "inst_packages:           m"
        echo "enable_services:         n"
        # echo "yay_setup                 "
        echo "yay_installations:       o"
        # echo "download_setup            "
        echo "inst_var_packages:       p"
        echo "building_software:       q"
        echo "inst_wallpaper:          r"
        echo "inst_fonts:              s"
        echo "links_setup:             t"
        echo "create_folder:           u"
        echo "dwm_auto:                v"
        # echo "create_remove             "

        read -p "What do you want to use the config file for?: " -e -i "ab1cdefghijklmnopqrstuv" VALUE_ans

        VALUE_ans=$(echo "$VALUE_ans" | tr '[:upper:]' '[:lower:]')

        for char in $(echo "$VALUE_ans" | grep -o .); do

            case "$char" in

                a) echo "kb_setup_live" >> /install;;
                b) echo "ena_parallel_live" >> /install;;
                1) echo "config_partitioning" >> /install;;
                2) echo "cfdisk_partitioning" >> /install;;
                3) echo "fdisk_partitioning" >> /install;;
                c) echo "ena_parallel" >> /install;;
                d) echo "time_setup" >> /install;;
                e) echo "language_setup" >> /install;;
                f) echo "kb_setup" >> /install;;
                g) echo "host_name" >> /install;;
                h) echo "user_name" >> /install;;
                i) echo "user_mod" >> /install;;
                j) echo "important packages" >> /install;;
                k) echo "grub_setup" >> /install;;
                l) echo "systemd_setup" >> /install;;
                m) echo "inst_packages" >> /install;;
                n) echo "enable_services" >> /install;;
                o) echo "yay_installations" >> /install;;
                p) echo "inst_var_packages" >> /install;;
                q) echo "building_software" >> /install;;
                r) echo "inst_wallpaper" >> /install;;
                s) echo "inst_fonts" >> /install;;
                t) echo "links_setup" >> /install;;
                u) echo "create_folder" >> /install;;
                v) echo "dwm_auto" >> /install;;
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

}

download_config () {

    notification "Download config"

    until [[ $VALUE_config =~ (d|t|l|v|s) ]]; do

        if [[ ! -z $VALUE_config ]]; then

            echo "Either: d, t, l, v or s!"

        fi

        read -p "Which config file do you want to use? [d/t/l/v/s]: " VALUE_config

    done

    USE_CONFIG_FILE=1

    case $VALUE_config in

        "d" )
            curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/DESKTOP_config > /config
            break
            ;;
        "t" )
            curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/THINKPAD_config > /config
            break
            ;;
        "l" )
            curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/LAPTOP_config > /config
            break
            ;;
        "v" )
            curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/VIRTUAL_config > /config
            break
            ;;
        "s" )
            curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/STANDARD_config > /config
            break
            ;;
    esac

}


kb_setup_live () {

    fname="kb_setup"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        kb_lan=$(grep -i -w KEYBOARD: $CONFIG_PATH | awk '{print $2}') &&
        loadkeys $kb_lan
        [ $? -ne 0 ] && return 10 || :

    else

        read -p "What keyboard?: " kb_lan &&
        loadkeys $kb_lan
        [ $? -ne 0 ] && return 10 || :

    fi
}


time_setup_live () {

    fname="time_setup"

    notification "$fname"

    timedatectl set-ntp true
    [ $? -ne 0 ] && return 11 || : 
}


upd_cache () {

    fname="upd_cache"

    notification "$fname"

    pacman -Sy
    [ $? -ne 0 ] && return 12 || : 
}


ena_parallel_live () {

    fname="ena_parallel_live"

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


config_partitioning () {
    
    fname="config_partitioning"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        # getting the right values from config
        disk_to_par=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==2'))
        par_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==3'))
        par_start_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==4'))
        par_end_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==5'))
        par_mount_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==6'))
        par_type_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==7'))
        par_func_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==8'))
    
    
        # calculating the amount of partitions
        amount_partition="${#disk_to_par[@]}"
    
        current_disk="first" #variable to make sure, that disks are recognized correctly
    
        for (( i=0; i<$amount_partition; i++ )); do
    
            echo "$current_disk -> ${disk_to_par[i]}"
            
            # if clause to make sure disks are being passed to $current_disk
            if [ "$current_disk" == "first" ]; then
    
                # creating gpt label 
                echo "$current_disk: First label created! ${disk_to_par[i]}" &&
                parted -s /dev/${disk_to_par[i]} mklabel gpt &&
                current_disk=${disk_to_par[i]}
                [ $? -ne 0 ] && return 20 || : 
    
            elif [ ! "$current_disk" == "${disk_to_par[i]}" ]; then
    
                # creating gpt label on second disk
                echo "$current_disk: New label created! ${disk_to_par[i]}" &&
                parted -s /dev/${disk_to_par[i]} mklabel gpt && 
                current_disk=${disk_to_par[i]}
                [ $? -ne 0 ] && return 21 || : 
    
            fi
            
    
            VALUE_SKIP="n"
            echo "if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") -eq 0 ]] && ( [[ "${par_func_arr[$i]}" == "extern" ]] || [[ "${par_func_arr[$i]}" == "home" ]] ); then"
            if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") -eq 0 ]] && ( [[ "${par_func_arr[$i]}" == "extern" ]] || [[ "${par_func_arr[$i]}" == "home" ]] ); then
                VALUE_SKIP="y"
                echo "${par_func_arr[@]} -> skip"
            fi
    
            if [ "${par_type_arr[$i]}" == "fat-32" ]; then
                echo "parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]}"
                parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]} 
                [ $? -ne 0 ] && return 22 || : 
    
            elif [ "${par_type_arr[$i]}" == "swap" ]; then
                echo "parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]}"
                parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]} 
                [ $? -ne 0 ] && return 23 || : 
    
            elif [ "${par_type_arr[$i]}" == "ext4" ]; then
                echo "parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]}" 
                parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]} 
                [ $? -ne 0 ] && return 24 || : 
    
            elif [ "${par_type_arr[$i]}" == "exfat" ]; then
                echo "parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]}"
                parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]}
                [ $? -ne 0 ] && return 25 || : 
            fi
    
            if [[ ! "$VALUE_SKIP" =~ (Y|y) ]]; then
    
                # going through partitions and creating the partitions and changing the file system type
                if [ "${par_type_arr[$i]}" == "fat-32" ]; then
                    echo "mkfs.fat -F32 /dev/${par_arr[i]} "
                    mkfs.fat -F32 /dev/${par_arr[i]} 
                    [ $? -ne 0 ] && return 22 || : 
    
                elif [ "${par_type_arr[$i]}" == "swap" ]; then
                    echo "mkswap /dev/${par_arr[i]}"
                    mkswap /dev/${par_arr[i]} 
                    [ $? -ne 0 ] && return 23 || : 
    
                elif [ "${par_type_arr[$i]}" == "ext4" ]; then
                    echo "mkfs.ext4 /dev/${par_arr[i]} "
                    mkfs.ext4 /dev/${par_arr[i]} 
                    [ $? -ne 0 ] && return 24 || : 
    
                elif [ "${par_type_arr[$i]}" == "exfat" ]; then
                    echo "mkfs.exfat /dev/${par_arr[i]} "
                    mkfs.exfat /dev/${par_arr[i]} 
                    [ $? -ne 0 ] && return 25 || : 
                fi
            fi
    
    
        done
    
        # go through the partitions and find home-partition than mount it and install kernel
        for (( i=0; i<$amount_partition; i++ )); do
    
            if [ "${[i]}" == "root" ]; then
    
                echo "mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]} &&"
                mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]} &&
                [ $? -ne 0 ] && return 27 || : 
    
                # get the uuid
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
    
                # write line to fstab (root specific)
                echo "mkdir -p /mnt/etc"
                echo "touch /mnt/etc/fstab"
                echo "echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 1"  >> /mnt/etc/fstab"
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 1"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 28 || : 
    
                echo "pacstrap /mnt base linux linux-firmware linux-headers"
                pacstrap /mnt base linux linux-firmware linux-headers
                [ $? -ne 0 ] && return 29 || : 
            fi
    
        done
        
        # go through partitions again and mount the rest
        # write to fstab
        for (( i=0; i<$amount_partition; i++ )); do
    
            if [ "${par_type_arr[i]}" == "swap" ]; then
    
                swapon /dev/${par_arr[i]} 
                [ $? -ne 0 ] && return 28 || : 
    
                # get the UUID
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
                # write line to fstab (swap specific)
                echo "mkdir -p /mnt/etc"
                echo "touch /mnt/etc/fstab"
                echo "echo "UUID=$part_UUID none $part_fs defaults 0 0"  >> /mnt/etc/fstab"
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID none $part_fs defaults 0 0"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 30 || : 
    
            elif [ "${[i]}" != "root" ]; then               
    
                if [ ! -e "/mnt${par_mount_arr[i]}" ]; then
    
                    echo "Creating /mnt${par_mount_arr[i]}"
                    mkdir -p /mnt${par_mount_arr[i]}
                    [ $? -ne 0 ] && return 26 || : 
    
    
                fi
    
                echo "mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]}"
                mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]}
                [ $? -ne 0 ] && return 27 || : 
    
                # get the uuid
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
                # write line to fstab 
                echo "mkdir -p /mnt/etc"
                echo "touch /mnt/etc/fstab"
                echo "echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 2"  >> /mnt/etc/fstab"
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 2"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 28 || : 
    
            else
    
                echo "home partition already managed!"
    
            fi
    
        done

    fi
    
}


set_file_system () {

    while true; do
        notification "Set file system"       

        lsblk -f -p
        read -p "What partition would you like set a file system for? [N]: " partition_to_set
        case "$partition_to_set" in
            [Nn] ) break;;
            * )
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$partition_to_set")

                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$partition_to_set" && [[ $partition_count -eq 1 ]]; then
                    while true; do

                        read -p "What file system for $partition_to_set? [NTFS/FAT32/exFAT/ext4/EFI/SWAP]: " file_system
                        if [[ "$file_system" == "NTFS" ]]; then
                            mkfs.ntfs $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        elif [[ "$file_system" == "FAT32" ]]; then
                            mkfs.fat -F32 $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        elif [[ "$file_system" == "exFAT" ]]; then
                            mkfs.exfat $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        elif [[ "$file_system" == "ext4" ]]; then
                            mkfs.ext4 $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        elif [[ "$file_system" == "EFI" ]]; then
                            mkfs.fat -F32 $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        elif [[ "$file_system" == "SWAP" ]]; then
                            mkswap $partition_to_set
                            [ $? -ne 0 ] && return 14 || : 
                            break

                        else 
                            echo "You typed the file system wrong!"
                            sleep 1
                        fi
                    done
                else
                    echo "No partition with that name!"
                    sleep 1
                fi
                ;;
        esac
    done
}

mount_partitions () {

    while true; do
        
        notification "Mount Home"
        lsblk -f -n
        read -p "What is your home partition? [N]: " home_par
        case $home_par in
            [Nn] ) break;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$home_par")

                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$home_par"; then
                    mount $home_par /mnt
                    [ $? -ne 0 ] && return 18 || : 


                    # get the uuid
                    part_UUID=$(sudo blkid $home_par | grep -woP 'UUID="\K[^"]+') &&
                    # get file system
                    part_fs=$(lsblk -fp | grep -w $home_par | awk '{print $2}')
                    # write line to fstab (home specific)
                    echo "echo UUID=$part_UUID / $part_fs defaults 0 1  >> /mnt/etc/fstab" &&
                    mkdir -p /mnt/etc
                    touch /mnt/etc/fstab
                    echo "UUID=$part_UUID / $part_fs defaults 0 1"  >> /mnt/etc/fstab
                    [ $? -ne 0 ] && return 28 || : 

                    break
                else
                    echo "No partition with that name!"
                fi
                ;;
        esac
    done

    

    while true; do
        
        notification "Mount efi"
        lsblk -f -n
        read -p "What is your EFI partition? [N]: " efi_par 
        case $efi_par in
            [Nn] ) break;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$efi_par")

                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$efi_par"; then
                    mkdir -p /mnt/boot/EFI && 
                    mount $efi_par /mnt/boot/EFI
                    [ $? -ne 0 ] && return 18 || : 

                    # get the uuid
                    part_UUID=$(sudo blkid $efi_par | grep -woP 'UUID="\K[^"]+') &&
                    # get file system
                    part_fs=$(lsblk -fp | grep -w $efi_par | awk '{print $2}')
                    # write line to fstab (efi specific)
                    echo "echo UUID=$part_UUID /boot/EFI $part_fs defaults 0 2  >> /mnt/etc/fstab" &&
                    mkdir -p /mnt/etc
                    touch /mnt/etc/fstab
                    echo "UUID=$part_UUID /boot/EFI $part_fs defaults 0 2"  >> /mnt/etc/fstab
                    [ $? -ne 0 ] && return 28 || : 

                    break
                else
                    echo "No partition with that name!"
                fi
                ;;
        esac
    done

    

    while true; do
        
        notification "Mount swap"
        lsblk -f -n

        read -p "What is your swap partition? [N]: " swap_par
        case $swap_par in
            [Nn] ) break;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$swap_par")

                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$swap_par"; then
                    swapon $swap_partition 
                    [ $? -ne 0 ] && return 18 || : 

                    # get the uuid
                    part_UUID=$(sudo blkid $swap_par | grep -woP 'UUID="\K[^"]+') &&
                    # get file system
                    part_fs=$(lsblk -fp | grep -w $swap_par | awk '{print $2}')
                    # write line to fstab (swap specific)
                    echo "echo UUID=$part_UUID none $part_fs defaults 0 0  >> /mnt/etc/fstab" &&
                    mkdir -p /mnt/etc
                    touch /mnt/etc/fstab
                    echo "UUID=$part_UUID none $part_fs defaults 0 0"  >> /mnt/etc/fstab
                    [ $? -ne 0 ] && return 28 || : 

                    break
                else
                    echo "No partition with that name!"
                fi
                ;;
        esac
    done


    while true; do
        
        notification "Mounting other Partitions"

        lsblk -f -n
        read -p "What partition do you want to mount? [N]: " par
        case $par in
            [Nn] ) break;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$par")

                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$par"; then
                    read -p "Where do you want to mount the partition?: " mount_path

                    mkdir -p /mnt$mount_path
                    mount $par /mnt$mount_path
                    [ $? -ne 0 ] && return 18 || : 

                    # get the uuid
                    part_UUID=$(sudo blkid $par | grep -woP 'UUID="\K[^"]+') &&
                    # get file system
                    part_fs=$(lsblk -fp | grep -w $par | awk '{print $2}')
                    # write line to fstab (efi specific)
                    echo "echo UUID=$part_UUID $mount_path $part_fs defaults 0 2  >> /mnt/etc/fstab" &&
                    mkdir -p /mnt/etc
                    touch /mnt/etc/fstab
                    echo "UUID=$part_UUID $mount_path $part_fs defaults 0 2"  >> /mnt/etc/fstab
                    [ $? -ne 0 ] && return 28 || : 

                else
                    echo "No partition with that name!"
                fi
                ;;
        esac
    done
}

install_kernel () {
    pacstrap -K /mnt base linux linux-firmware linux-headers
    [ $? -ne 0 ] && return 19 || : 
}


cfdisk_partitioning () {

    fname="cfdisk_partitioning"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        lsblk -f -p
        read -p "What disk do you want to partition? [N]: " disk
        case $disk in
            [Nn] ) 
                echo ok
                ;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$disk")
    
                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$disk"; then
    
                    cfdisk $disk
                    [ $? -ne 0 ] && return 18 || : 
    
                else
                    echo "No partition with that name!"
                    sleep 1
                fi
            ;;
        esac
    
        exe set_file_system && 
        exe mount_partitions && 
        exe install_kernel 
        [ $? -ne 0 ] && return 14 || : 
    fi
}

fdisk_partitioning () {

    fname="fdisk_partitioning"

    notification "$fname"

    if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

        lsblk -f -p
        read -p "What disk do you want to partition? [N]: " disk
    
        case $disk in
            [Nn] ) 
                echo ok
                ;;
            *)
                partitions=$(lsblk -p -n -o NAME)
                partition_count=$(echo "$partitions" | grep -c "$disk")
    
                # wont work with more than 10 partitions since sda1 is in sda10
                if echo "$partitions" | grep "$disk"; then
                    
                    fdisk $disk
                    [ $? -ne 0 ] && return 18 || : 
    
                else
                    echo "No partition with that name!"
                    sleep 1
                fi
                ;;
        esac
    
        exe set_file_system && 
        exe mount_partitions && 
        exe install_kernel 
        [ $? -ne 0 ] && return 14 || : 

    fi
}


inst_part_2 () {

    fname="inst_part_2"

    notification "$fname"

    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_scripts/valc-2.sh > /mnt/valc-2.sh &&
    chmod +x /mnt/valc-install-part-2.sh
    [ $? -ne 0 ] && return 21 || : 

    cp $CONFIG_PATH /mnt/config
    cp $INSTALL_OPTION_PATH /mnt/installation_options
}

exe question_purpose
exe determine_config
exe download_config
exe kb_setup_live
exe time_setup_live
exe upd_cache
exe ena_parallel_live
exe config_partitioning
exe cfdisk_partitioning
exe fdisk_partitioning
exe inst_part_2

notification "Changing root"
mv /config /mnt
mv /install /mnt
arch-chroot /mnt
