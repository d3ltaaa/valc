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

CONFIG_PATH="config"
USE_CONFIG_FILE=0
VALUE_KB_SETUP=0
VALUE_PARTITIONING=0

determine_config () {
    notification "Config File"

    while true; do
        read -p "Which config file do you want to use? [D/T/L/V/N]: " ans
        case $ans in
            [Dd] )
                curl https://raw.githubusercontent.com/d3ltaaa/.valc/main/setup/ssh_files/config_files/DESKTOP_config > config
                USE_CONFIG_FILE=1
                break
                ;;
            [Tt] )
                curl https://raw.githubusercontent.com/d3ltaaa/.valc/main/setup/ssh_files/config_files/THINKPAD_config > config
                USE_CONFIG_FILE=1
                break
                ;;
            [Ll] )
                curl https://raw.githubusercontent.com/d3ltaaa/.valc/main/setup/ssh_files/config_files/LAPTOP_config > config
                USE_CONFIG_FILE=1
                break
                ;;
            [Vv] )
                curl https://raw.githubusercontent.com/d3ltaaa/.valc/main/setup/ssh_files/config_files/VIRTUAL_config > config
                USE_CONFIG_FILE=1
                break
                ;;
            [Nn] )
                break
                ;;
        esac
    done


    if [[ $USE_CONFIG_FILE -eq 1 ]]; then

        while true; do

            invalid_value=0

            printf "update_system \nkb_setup: K \ntime_setup \nupd_cache \nena_parallel \npartitioning: P \ninst_part\n"

            read -p "What do you want to use the config file for? [K/P]: " choice

            choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

            if [ -z "$choice" ]; then
                USE_CONFIG_FILE=0
            fi


            for char in $(echo "$choice" | grep -o .); do
                case "$char" in
                    k)
                        VALUE_KB_SETUP=1
                         ;;
                    p) 
                        VALUE_PARTITIONING=1
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
                

kb_setup () {
    # kb-setup (in case sth goes wrong)
    notification "Loading keys"
    if [ "$VALUE_KB_SETUP" -eq 1 ]; then

        kb_lan=$(grep -i -w KEYBOARD $CONFIG_PATH | awk '{print $2}')

        loadkeys $kb_lan
        [ $? -ne 0 ] && return 10 || :

    else

        loadkeys de-latin1
        [ $? -ne 0 ] && return 10 || :

    fi
    
}

time_setup () {
    # time setup 1.0
    notification "Time setup"
    timedatectl set-ntp true
    [ $? -ne 0 ] && return 11 || : 
}

upd_cache () {
    # update cache
    notification "Updating keys"
    pacman -Sy
    [ $? -ne 0 ] && return 12 || : 
}

ena_parallel () {
    # update parallel downloads
    notification "Enabling parallel downloads"
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
    [ $? -ne 0 ] && return 13 || : 
}

set_file_system () {

    
    while true; do
        notification "Set file system"       

        lsblk -f -p
        read -p "What partition would you like set a file system for? [N]: " partition_to_set
        case $partition_to_set in
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

    # Mount partitions


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

    notification "Installing kernels"
    pacstrap -K /mnt base linux linux-firmware linux-headers
    [ $? -ne 0 ] && return 19 || : 

}

generate_fstab () {
    notification "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
    [ $? -ne 0 ] && return 20 || :
}

fdisk_partitioning () {

    notification "fdisk partitioning"


    lsblk -f -p
    read -p "What disk do you want to partition? [N]: " disk
    case $par in
        [Nn] ) ;;
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

}

cfdisk_partitioning () {

    notification "Cfdisk partitioning"
    
    lsblk -f -p
    read -p "What disk do you want to partition? [N]: " disk
    case $par in
        [Nn] ) ;;
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

}

check_for_efi () {

    if [ -e /mnt/boot/EFI ]; then
        echo "EFI exists"
    else 
        echo "EFI got lost"
        read -p "What do you do now?"
    fi
}


partitioning () {
   
    
    notification "Partitioning"
    
    # if user wants to partition with config
    if [ "$VALUE_PARTITIONING" -eq 1 ]; then

        # getting the right values from config
        disk_to_par=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==2'))
        par_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==3'))
        par_start_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==4'))
        par_end_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==5'))
        par_mount_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==6'))
        par_type_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==7'))
        par_home_arr=($(grep -i -w -A7 PARTITION $CONFIG_PATH | awk 'NR==8'))


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
                echo "$current_disk: Second label created! ${disk_to_par[i]}" &&
                parted -s /dev/${disk_to_par[i]} mklabel gpt && 
                current_disk=${disk_to_par[i]}
                [ $? -ne 0 ] && return 21 || : 

            fi
            

            VALUE_EXTERN=""
            if [ "${par_home_arr[$i]}" == "extern" ]; then
                until [[ $VALUE_EXTERN =~ (Y|y|N|n) ]]; do
                    if [ ! -z $VALUE_EXTERN ]; then
                        echo "Enter 'y' or 'n'!"
                    fi
                    read -p "Do you want to change the external disk? [Y/N]: " -e -i n VALUE_EXTERN
                done
            fi

            if [[ ! "$VALUE_EXTERN" =~ (N|n) ]]; then

                # going through partitions and creating the partitions and changing the file system type
                if [ "${par_type_arr[$i]}" == "fat-32" ]; then
                    echo "created /dev/${disk_to_par[i]} fat32" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]} &&
                    echo "mkfs.fat -F32 /dev/${par_arr[i]}" &&
                    mkfs.fat -F32 /dev/${par_arr[i]} 

                    [ $? -ne 0 ] && return 22 || : 


                elif [ "${par_type_arr[$i]}" == "swap" ]; then
                    echo "created /dev/${disk_to_par[i]} linux-swap" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]} &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    echo "mkswap /dev/${par_arr[i]}" && 
                    mkswap /dev/${par_arr[i]} 

                    [ $? -ne 0 ] && return 23 || : 

                elif [ "${par_type_arr[$i]}" == "ext4" ]; then
                    echo "created /dev/${disk_to_par[i]} ext4" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]} &&
                    echo "mkfs.ext4 /dev/${par_arr[i]}" &&
                    mkfs.ext4 /dev/${par_arr[i]} 

                    [ $? -ne 0 ] && return 24 || : 


                elif [ "${par_type_arr[$i]}" == "exfat" ]; then
                    echo "created /dev/${disk_to_par[i]} extfat" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]} &&
                    echo "mkfs.extfat /dev/${par_arr[i]}" && 
                    mkfs.exfat /dev/${par_arr[i]} 

                    [ $? -ne 0 ] && return 25 || : 


                fi

            else

                # going through partitions and creating the partitions and changing the file system type
                if [ "${par_type_arr[$i]}" == "fat-32" ]; then
                    echo "created /dev/${disk_to_par[i]} fat32" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary fat32 ${par_start_arr[$i]} ${par_end_arr[$i]} 

                    [ $? -ne 0 ] && return 22 || : 


                elif [ "${par_type_arr[$i]}" == "swap" ]; then
                    echo "created /dev/${disk_to_par[i]} linux-swap" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary linux-swap ${par_start_arr[$i]} ${par_end_arr[$i]} 

                    [ $? -ne 0 ] && return 23 || : 

                elif [ "${par_type_arr[$i]}" == "ext4" ]; then
                    echo "created /dev/${disk_to_par[i]} ext4" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary ext4 ${par_start_arr[$i]} ${par_end_arr[$i]} 

                    [ $? -ne 0 ] && return 24 || : 


                elif [ "${par_type_arr[$i]}" == "exfat" ]; then
                    echo "created /dev/${disk_to_par[i]} extfat" &&
                    echo "parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]}" &&
                    parted -s /dev/${disk_to_par[i]} mkpart primary ntfs ${par_start_arr[$i]} ${par_end_arr[$i]}

                    [ $? -ne 0 ] && return 25 || : 


                fi
            fi


        done

        # go through the partitions and find home-partition than mount it and install kernel
        for (( i=0; i<$amount_partition; i++ )); do

            if [ "${par_home_arr[i]}" == "home" ]; then

                mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]} &&
                echo "mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]}" 
                [ $? -ne 0 ] && return 27 || : 

                # get the uuid
                echo "sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+'" &&
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
                # write line to fstab (home specific)
                echo "echo UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 1  >> /mnt/etc/fstab" &&
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 1"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 28 || : 


                pacstrap /mnt base linux linux-firmware linux-headers &&
                echo "pacstrap /mnt base linux linux-firmware"

                [ $? -ne 0 ] && return 29 || : 
            fi

        done
        
        # go through partitions again and mount the rest
        # write to fstab
        for (( i=0; i<$amount_partition; i++ )); do

            if [ "${par_type_arr[i]}" == "swap" ]; then

                echo "swapon /dev/${par_arr[i]}" &&
                swapon /dev/${par_arr[i]} 
                [ $? -ne 0 ] && return 28 || : 

                # get the UUID
                echo "sudo blkid /mnt/${par_arr[i]} | grep -woP 'UUID="\K[^"]+'" &&
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
                # write line to fstab (swap specific)
                echo "echo UUID=$part_UUID none $part_fs defaults 0 0  >> /mnt/etc/fstab" &&
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID none $part_fs defaults 0 0"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 30 || : 

            elif [ "${par_home_arr[i]}" != "home" ]; then               

                if [ ! -e "/mnt${par_mount_arr[i]}" ]; then

                    echo "Creating /mnt${par_mount_arr[i]}"
                    mkdir -p /mnt${par_mount_arr[i]}
                    [ $? -ne 0 ] && return 26 || : 


                fi

                mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]} &&
                echo "mount /dev/${par_arr[i]} /mnt${par_mount_arr[i]}" &&

                [ $? -ne 0 ] && return 27 || : 

                # get the uuid
                echo "sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+'" &&
                part_UUID=$(sudo blkid /dev/${par_arr[i]} | grep -woP 'UUID="\K[^"]+') &&
                part_fs=$(lsblk -fp | grep -w /dev/${par_arr[i]} | awk '{print $2}')
                # write line to fstab 
                echo "echo UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 2  >> /mnt/etc/fstab" &&
                mkdir -p /mnt/etc
                touch /mnt/etc/fstab
                echo "UUID=$part_UUID ${par_mount_arr[i]} $part_fs defaults 0 2"  >> /mnt/etc/fstab
                [ $? -ne 0 ] && return 28 || : 

            else

                echo "home partition already managed!"

            fi

        done
        
        echo "cp config /mnt/config" && 
        cp config /mnt/config && 
        sleep 1
        [ $? -ne 0 ] && return 30 || : 


        

    else

        while true; do
            
            notification "Partitioning"
    
            printf "Cfdisk: D \nFdisk: F \nNo: N \n"
            read -p "How do you want to partition?: " ans
            case $ans in
                [Dd]* ) 
                    exe cfdisk_partitioning 
                    [ $? -ne 0 ] && return 14 || : 
                    ;;
                [Ff]* ) 
                    exe fdisk_partitioning
                    [ $? -ne 0 ] && return 14 || : 
                    ;;
                [Nn]* ) break;;
                * ) echo "Enter 'D', 'C' or 'N'!";;
            esac
        done
    
        exe set_file_system && 
        exe mount_partitions && 
        exe install_kernel 
        # exe generate_fstab
    
        [ $? -ne 0 ] && return 14 || : 
    fi

}

inst_part () {
    
    notification "Installing next valc-installation-part"
    curl https://raw.githubusercontent.com/d3ltaaa/valc/main/iscript/valc-install-part-2.sh > /mnt/valc-install-part-2.sh &&
    chmod +x /mnt/valc-install-part-2.sh
    [ $? -ne 0 ] && return 21 || : 
}



##################################################################################

printf "This is an install-script for the valc linux distribution."
read temp


exe determine_config

exe kb_setup

exe time_setup

exe upd_cache

exe ena_parallel

exe partitioning

exe inst_part

notification "Changing root"
arch-chroot /mnt
