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

    touch $INSTALL_OPTION_PATH
        
    if [[ $VALUE_PURPOSE == "install" ]]; then

        echo "1" > $INSTALL_OPTION_PATH

    else

        echo "0" > $INSTALL_OPTION_PATH

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
        echo "enable_services_root:    m"
        # echo "inst_part_3               "
        echo "reown_dirs:              n"
        echo "inst_packages:           o"
        # echo "paru_setup                "
        echo "paru_installations:      p"
        # echo "download_setup            "
        echo "inst_var_packages:       q"
        echo "inst_wallpaper:          r"
        echo "inst_fonts:              s"
        echo "links_setup:             t"
        echo "building_software:       u"
        echo "create_folder:           v"
        echo "enable_services:         w"
        echo "dwm_auto:                x"
        # echo "create_remove             "

        read -p "What do you want to use the config file for?: " -e -i "ab1cdefghijklmnopqrstuvwx" VALUE_ans

        VALUE_ans=$(echo "$VALUE_ans" | tr '[:upper:]' '[:lower:]')

        for char in $(echo "$VALUE_ans" | grep -o .); do

            case "$char" in

                a) echo "kb_setup_live" >> $INSTALL_OPTION_PATH;;
                b) echo "ena_parallel_live" >> $INSTALL_OPTION_PATH;;
                1) echo "config_partitioning" >> $INSTALL_OPTION_PATH;;
                2) echo "cfdisk_partitioning" >> $INSTALL_OPTION_PATH;;
                3) echo "fdisk_partitioning" >> $INSTALL_OPTION_PATH;;
                c) echo "ena_parallel" >> $INSTALL_OPTION_PATH;;
                d) echo "time_setup" >> $INSTALL_OPTION_PATH;;
                e) echo "language_setup" >> $INSTALL_OPTION_PATH;;
                f) echo "kb_setup" >> $INSTALL_OPTION_PATH;;
                g) echo "host_name" >> $INSTALL_OPTION_PATH;;
                h) echo "user_name" >> $INSTALL_OPTION_PATH;;
                i) echo "user_mod" >> $INSTALL_OPTION_PATH;;
                j) echo "inst_important_packages" >> $INSTALL_OPTION_PATH;;
                k) echo "grub_setup" >> $INSTALL_OPTION_PATH;;
                l) echo "systemd_setup" >> $INSTALL_OPTION_PATH;;
                m) echo "enable_services_root" >> $INSTALL_OPTION_PATH;;
                n) echo "reown_dirs" >> $INSTALL_OPTION_PATH;;
                o) echo "inst_packages" >> $INSTALL_OPTION_PATH;;
                p) echo "paru_installations" >> $INSTALL_OPTION_PATH;;
                q) echo "inst_var_packages" >> $INSTALL_OPTION_PATH;;
                r) echo "inst_wallpaper" >> $INSTALL_OPTION_PATH;;
                s) echo "inst_fonts" >> $INSTALL_OPTION_PATH;;
                t) echo "links_setup" >> $INSTALL_OPTION_PATH;;
                u) echo "building_software" >> $INSTALL_OPTION_PATH;;
                v) echo "create_folder" >> $INSTALL_OPTION_PATH;;
                w) echo "enable_services" >> $INSTALL_OPTION_PATH;;
                x) echo "dwm_auto" >> $INSTALL_OPTION_PATH;;
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

    # create partitions
    parted_partitioning () {
    
        fname="parted_partitioning"
    
        notification "$fname"
    
        if grep -w -q "$fname" $INSTALL_OPTION_PATH; then
    
            disk_to_par=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==2'))
            par_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==3'))
            par_start_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==4'))
            par_end_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==5'))
            par_type_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==6'))
            file_system_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==7'))
            mount_point_par_arr=($(grep -i -w -A7 PARTITION: $CONFIG_PATH | awk 'NR==8'))
            par_fstab_arr=($(grep -i -w -A8 PARTITION: $CONFIG_PATH | awk 'NR==9'))
            par_update_arr=($(grep -i -w -A9 PARTITION: $CONFIG_PATH | awk 'NR==10'))
    
    
            # clear fstab
            touch /fstab
            echo "" > /fstab
            # make partition tables
            disk=""
            for (( i = 0; i<${#disk_to_par[@]}; i++ )); do
                if [[ $disk != ${disk_to_par[$i]} ]]; then
                    echo "parted -s /dev/${disk_to_par[$i]} mklabel gpt"
                    if vgs &> /dev/null; then
                       vgchange -a n
                    fi
                    parted -s /dev/${disk_to_par[$i]} mklabel gpt
                    echo ""
                fi
                disk="${disk_to_par[$i]}"
            done
    
    
            for (( i = 0; i<${#par_arr[@]}; i++ )); do
                
                # make partitions
                echo "parted -s /dev/${disk_to_par[$i]} mkpart primary ${par_type_arr[$i]} ${par_start_arr[$i]} ${par_end_arr[$i]}"
                parted -s /dev/${disk_to_par[$i]} mkpart primary ${par_type_arr[$i]} ${par_start_arr[$i]} ${par_end_arr[$i]}
                echo ""
    
                if [[ ${par_fstab_arr[$i]} != "//" ]]; then
                    # if normal partition
                    # make fs, add fstab entry
                    make_fs /dev/${par_arr[$i]} ${file_system_arr[$i]} ${par_update_arr[$i]}
                    add_fstab_entry /dev/${par_arr[$i]} ${mount_point_par_arr[$i]} ${par_fstab_arr[$i]} 
                else
                    # if lvm
                    # create physical volume and add to volume group
                    echo "pvcreate /dev/${par_arr[$i]}"
                    pvcreate /dev/${par_arr[$i]}
                    echo ""
    
                    # if volume group already exists, extend it
                    if vgdisplay | grep -w ${file_system_arr[$i]}; then
                        echo "vgextend ${file_system_arr[$i]} ${par_arr[$i]}"
                        vgextend ${file_system_arr[$i]} /dev/${par_arr[$i]}
                        echo ""
                    else
                        echo "vgcreate ${file_system_arr[$i]} ${par_arr[$i]}"
                        vgcreate ${file_system_arr[$i]} /dev/${par_arr[$i]}
                        echo ""
                    fi
                fi
            done
    
    
        fi
    
    }
    
    lvm_partitioning () {
    
        fname="lvm_partitioning"
    
        # notification "$fname"
    
    
        if grep -w -q "$fname" $INSTALL_OPTION_PATH; then
    
            beg=$(grep -n -i -w LVM: $CONFIG_PATH | cut -d':' -f1)
            end=$(grep -n -i -w :LVM $CONFIG_PATH | cut -d':' -f1)
    
            # grab everything between the two lines
            output=$(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH)
    
            vg_names=($(echo "$output" | grep -i -w "LV |" | cut -d '|' -f2))
    
            for (( i = 0; i<${#vg_names[@]}; i++ )); do
    
                lv_names=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A1 | awk 'NR==2'))
                lv_sizes=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A2 | awk 'NR==3'))
                lv_fs=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A3 | awk 'NR==4'))
                lv_mount=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A4 | awk 'NR==5'))
                lv_fstab=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A5 | awk 'NR==6'))
                lv_update=($(echo "$output" | grep -i -w "LV | ${vg_names[$i]}" -A6 | awk 'NR==7'))
    
                for (( j = 0; j<${#lv_names[@]}; j++ )); do
                    # create logical volumes
                    string_free="${lv_sizes[$j]}"
                    if [[ "${string_free: -4}" == "FREE" ]]; then
                        echo "lvcreate -l ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}"
                        lvcreate -l ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}               
                        echo ""
                    else
                        echo "lvcreate -L ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}"
                        lvcreate -L ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}               
                        echo ""
                    fi
    
                    # make filesystem
                    echo "make_fs /dev/mapper/${vg_names[$i]}-${lv_names[$j]} ${lv_fs[$j]}"
                    make_fs /dev/mapper/${vg_names[$i]}-${lv_names[$j]} ${lv_fs[$j]} ${lv_update[$j]}
                    echo ""
    
    
                    add_fstab_entry /dev/mapper/${vg_names[$i]}-${lv_names[$j]} ${lv_mount[$j]} ${lv_fstab[$j]}
                done
    
            done
    
    
        fi
    }
    
    make_fs () {
        # (path to partition/lv) (fs)
        full_path="$1"
        file_system="$2"
        update_var="$3"
    
        if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]] || [[ "$update_var" == "update" ]]; then
    
            if [ "$file_system" == "fat-32" ]; then
                echo "mkfs.fat -F32 $full_path"
                mkfs.fat -F32 $full_path
                echo ""
        
            elif [ "$file_system" == "swap" ]; then
                echo "mkswap $full_path"
                mkswap $full_path
                echo ""
        
            elif [ "$file_system" == "ext4" ]; then
                echo "mkfs.ext4 -F $full_path"
                mkfs.ext4 -F $full_path
                echo ""
        
            elif [ "$file_system" == "exfat" ]; then
                echo "mkfs.exfat $full_path"
                mkfs.exfat $full_path
                echo ""
            fi
    
        fi
    
    }
    
    add_fstab_entry () {
        # (path to partition/lv) (mount_point) (fs_num)
        full_path="$1"
        mount_point="$2"
        fs_num="$3"
    
    
        if [[ ! -e /fstab ]]; then
            touch /fstab
        fi

        lsblk -fp # needed, dont know why
        part_fs="$(lsblk -fp | grep -w "$full_path" | awk '{print $2}')"
        echo "part_fs of $full_path: $part_fs"
        printf "\n"
        echo "$full_path $mount_point $part_fs defaults 0 $fs_num" 
        echo "$full_path $mount_point $part_fs defaults 0 $fs_num" >> /fstab
        echo ""
    
        if [[ "$mount_point" == "/" ]]; then
            mount $full_path /mnt
            pacstrap -K /mnt base linux linux-firmware linux-headers
        fi
        
    }

    add_mount_points () {
        mount_arr=("$@")
        # normal partitions
        for (( i=0; i<${#mount_arr[@]}; i++ )); do
            case ${mount_arr[$i]} in
                "none")
                    break;;
                "//")
                    break;;
                "")
                    break;;
                *)
                    mkdir -p /mnt${mount_arr[$i]}
                    echo "mkdir -p /mnt${mount_arr[$i]}"
                    ;;
            esac
        done
    }
    
    parted_partitioning
    lvm_partitioning
    add_mount_points "${mount_point_par_arr[@]}"
    add_mount_points "${lv_mount[@]}"
    mkdir -p /mnt/etc
    cp /fstab /mnt/etc/fstab

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
                            mkfs.ext4 -F $partition_to_set
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
    chmod +x /mnt/valc-2.sh
    [ $? -ne 0 ] && return 21 || : 

    cp $CONFIG_PATH /mnt/config
    cp $INSTALL_OPTION_PATH /mnt/install
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
