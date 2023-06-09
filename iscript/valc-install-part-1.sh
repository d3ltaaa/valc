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

partitioning () {

    # Decision fast installation or slow installation
    notification "Partitioning"
    
    ans_man=""
    while true; do
        read -p "Do you want to partition the disks manually? [y/n]: " yn
        case $yn in
            [Yy]* ) ans_man="manually"; break;;
            [Nn]* ) break;;
            * ) echo "Enter 'y' or 'n'!";;
        esac
    done
    
    if [ "$ans_man" == "manually" ]; then
    
        # manual partition (prompts as long as there is another disk to partition
        while true; do
    
            read -p "Do you want to partition (another) disk? [y/n]: " yn
    
            case $yn in
    
                [Yy]* ) 
    
                    read -p "Which disk would you like to partition?: " disk_to_partition
                    cfdisk $disk_to_partition
                    [ $? -ne 0 ] && return 14 || : 
                    ;;
        
                [Nn]* )
    
                    printf "You do not want to partition another disk!"
                    sleep 1
                    break;;
        
                * ) echo "Enter 'y' or 'n'!";;
            esac
        done
    else
        # the partition types are given!
        ans_size=""
    
        while true; do
       
            read -p "Do you want to set the sizes yourself? [y/n]: " yn
    
            case $yn in
    
                [Yy]* ) ans_size="manually"; break;;
    
                [Nn]* ) break;;
    
                * ) echo "Enter 'y' or 'n'!";;
    
            esac
        done
    
        if [ "$ans_size" == "manually" ]; then
    
            read -p "Which disk would you like to partition?:         " disk_to_partition
            read -p "What is the EFI partition called?:               " efi_partition
            read -p "What is the SWAP partition called?:              " swap_partition
            read -p "What is the LINUX FILE SYSTEM partition called?: " fs_partition
            read -p "What size should the EFI partition be?:          " size_of_efi
            read -p "What size should the swap partition be?:         " size_of_swap
    
            parted -s $disk_to_partition mklabel gpt &&
            parted -s $disk_to_partition mkpart primary fat32 1MiB ${size_of_efi}GiB &&
            parted -s $disk_to_partition set 1 esp on &&
            parted -s $disk_to_partition mkpart primary linux-swap ${size_of_efi}GiB $((size_of_efi + size_of_swap))GiB &&
            parted -s $disk_to_partition mkpart primary ext4 $((size_of_efi + size_of_swap))GiB 100%
            [ $? -ne 0 ] && return 15 || : 
    
    
        else
    
            # get the disk type
            
            while true; do
       
                read -p "Is the type of your disk sata or nvme? [sata/nvme]: " disk_type
    
                case $disk_type in
    
                sata ) break;;

                nvme ) break;;

                * ) echo "Enter 'sata' or 'nvme'!";;

            esac

        done

        # declaring and assinging the variables

        
        if [ "$disk_type" == "sata" ]; then
            disk_to_partition="/dev/sda"
            efi_partition="/dev/sda1"
            swap_partition="/dev/sda2"
            fs_partition="/dev/sda3"

        elif [ "$disk_type" == "nvme" ]; then
            disk_to_partition="/dev/nvme0n1"
            efi_partition="/dev/nvme0n1p1"
            swap_partition="/dev/nvme0n1p2"
            fs_partition="/dev/nvme0n1p3"
        fi

        size_of_efi=2
        size_of_swap=2


        parted -s $disk_to_partition mklabel gpt &&
        parted -s $disk_to_partition mkpart primary fat32 1MiB ${size_of_efi}GiB &&
        parted -s $disk_to_partition set 1 esp on &&
        parted -s $disk_to_partition mkpart primary linux-swap ${size_of_efi}GiB $((size_of_efi + size_of_swap))GiB &&
        parted -s $disk_to_partition mkpart primary ext4 $((size_of_efi + size_of_swap))GiB 100%
        [ $? -ne 0 ] && return 16 || : 

    fi

    
    # Format partitions
    notification "Formating partitions"
    mkfs.fat -F32 $efi_partition &&
    mkswap $swap_partition &&
    mkfs.ext4 $fs_partition 
    [ $? -ne 0 ] && return 17 || :

    # Mount partitions
    notification "Mount partitions"
    swapon $swap_partition &&
    mount $fs_partition /mnt &&
    mkdir -p /mnt/boot/EFI &&
    mount $efi_partition /mnt/boot/EFI
    [ $? -ne 0 ] && return 18 || : 

    # misscellaneous
    notification "Installing kernels"
    pacstrap /mnt base linux linux-firmware
    [ $? -ne 0 ] && return 19 || : 

    notification "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
    [ $? -ne 0 ] && return 20 || :


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

exe kb_setup

exe time_setup

exe upd_cache

exe ena_parallel

exe partitioning

exe inst_part

notification "Changing root"
arch-chroot /mnt
