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

kb_setup () {
    # kb-setup (in case sth goes wrong)
    notification "Loading keys"
    loadkeys de-latin1
    [ $? -ne 0 ] && return 10 || :
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

                    mkdir -p $mount_path
                    mount $par $mount_path
                    [ $? -ne 0 ] && return 18 || : 

                else
                    echo "No partition with that name!"
                fi
                ;;
        esac
    done

}

install_kernel () {

    notification "Installing kernels"
    pacstrap /mnt base linux linux-firmware
    [ $? -ne 0 ] && return 19 || : 

}

generate_fstab () {
    notification "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
    [ $? -ne 0 ] && return 20 || :
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

partitioning () {
   
    
    # variable that needs to updated in the different partitioning types
    # so that when setting file system types, it works
    

    while true; do
        
        notification "Partitioning"

        printf "Cfdisk: D \nConfig: C \nNo: N \n"
        read -p "How do you want to partition?: " ans
        case $ans in
            [Dd]* ) 
                exe cfdisk_partitioning 
                [ $? -ne 0 ] && return 14 || : 
                ;;
            [Cc]* ) echo "config_partitioning"; break;;
            [Nn]* ) break;;
            * ) echo "Enter 'D', 'C' or 'N'!";;
        esac
    done

    exe set_file_system && 
    exe mount_partitions && 
    exe install_kernel && 
    exe generate_fstab

    [ $? -ne 0 ] && return 14 || : 

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

exe kb_setup

exe time_setup

exe upd_cache

exe ena_parallel

exe partitioning

exe inst_part

notification "Changing root"
arch-chroot /mnt
