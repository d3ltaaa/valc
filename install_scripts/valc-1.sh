CONFIG_PATH="/config"
INSTALL_OPTION_PATH="/install"
HISTORY_PATH="/commands"
SUGGESTION=""

exe() {
	# exe hepls contain a block of code in a repeatable format in case something goes wrong
	return_code=1

	while [ $return_code -ne 0 ]; do

		"$@"

		return_code=$?
		# check if everything worked
		if [ $return_code -eq 0 ]; then
			echo "================>>      Checks out"
			sleep 1
			break
		fi

		while [ $return_code -ne 0 ]; do
			echo "Error code: $return_code !"
			read -p "Something went wrong here :( Do you want to redo the command? [y/n]: " yn
			case $yn in
			[Yy]*) break ;;
			[Nn]*)
				return_code=0
				break
				;;
			*) echo "Enter 'y' or 'n'!" ;;
			esac
		done
	done
}

notification() {
	clear
	echo "================>>      $1"
	sleep 1
}

question_purpose() {

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

		echo "1" >$INSTALL_OPTION_PATH

	else

		echo "0" >$INSTALL_OPTION_PATH

	fi

}


download_config() {

	notification "Download config"

	until [[ $VALUE_config =~ (d|t|l|v|s|c|dw|tw|lw|vw|sw|cw|n) ]]; do

		if [[ ! -z $VALUE_config ]]; then

			echo "Either: d, t, l, v, s, c or n!"

		fi

		read -p "Which config file do you want to use? [d/t/l/v/s/c dw/tw/lw/vw/sw/cw n]: " VALUE_config

	done

	USE_CONFIG_FILE=1

	case $VALUE_config in

	"d")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/DESKTOP_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		break
		;;
	"t")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/THINKPAD_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		break
		;;
	"l")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/LAPTOP_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		break
		;;
	"v")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/VIRTUAL_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		break
		;;
	"s")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/STANDARD_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		break
		;;
	"c")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/STANDARD_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwxyz"
		exit 0
		;;
	"dw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/DESKTOP_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		break
		;;
	"tw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/THINKPAD_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		break
		;;
	"lw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/LAPTOP_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		break
		;;
	"vw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/VIRTUAL_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		break
		;;
	"sw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/STANDARD_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		break
		;;
	"cw")
		curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_options/STANDARD_WAYLAND_config >/config
    SUGGESTION="ab1cdefghijklmnopqrstuvwyz"
		exit 0
		;;
	"n")
		break
		;;
	esac

}

determine_config() {

	while true; do

		invalid_value=0

		# echo "download_config           "
		# echo "determine_config          "
		echo "kb_setup_live:           a"
		# echo "time_setup_live           "
		# echo "upd_cache                 "
		echo "ena_parallel_live:       b"
		echo "config_partitioning:     1"
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
		# echo "mkinitcpio_setup          "
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
		echo "ufw_setup:               y"
		echo "fail2ban_setup:          z"
		# echo "create_remove             "

		read -p "What do you want to use the config file for?: " -e -i  $SUGGESTION VALUE_ans
    

		VALUE_ans=$(echo "$VALUE_ans" | tr '[:upper:]' '[:lower:]')

		for char in $(echo "$VALUE_ans" | grep -o .); do

			case "$char" in

			a) echo "kb_setup_live" >>$INSTALL_OPTION_PATH ;;
			b) echo "ena_parallel_live" >>$INSTALL_OPTION_PATH ;;
			1) echo "config_partitioning" >>$INSTALL_OPTION_PATH ;;
			c) echo "ena_parallel" >>$INSTALL_OPTION_PATH ;;
			d) echo "time_setup" >>$INSTALL_OPTION_PATH ;;
			e) echo "language_setup" >>$INSTALL_OPTION_PATH ;;
			f) echo "kb_setup" >>$INSTALL_OPTION_PATH ;;
			g) echo "host_name" >>$INSTALL_OPTION_PATH ;;
			h) echo "user_name" >>$INSTALL_OPTION_PATH ;;
			i) echo "user_mod" >>$INSTALL_OPTION_PATH ;;
			j) echo "inst_important_packages" >>$INSTALL_OPTION_PATH ;;
			k) echo "grub_setup" >>$INSTALL_OPTION_PATH ;;
			l) echo "systemd_setup" >>$INSTALL_OPTION_PATH ;;
			m) echo "enable_services_root" >>$INSTALL_OPTION_PATH ;;
			n) echo "reown_dirs" >>$INSTALL_OPTION_PATH ;;
			o) echo "inst_packages" >>$INSTALL_OPTION_PATH ;;
			p) echo "paru_installations" >>$INSTALL_OPTION_PATH ;;
			q) echo "inst_var_packages" >>$INSTALL_OPTION_PATH ;;
			r) echo "inst_wallpaper" >>$INSTALL_OPTION_PATH ;;
			s) echo "inst_fonts" >>$INSTALL_OPTION_PATH ;;
			t) echo "links_setup" >>$INSTALL_OPTION_PATH ;;
			u) echo "building_software" >>$INSTALL_OPTION_PATH ;;
			v) echo "create_folder" >>$INSTALL_OPTION_PATH ;;
			w) echo "enable_services" >>$INSTALL_OPTION_PATH ;;
			x) echo "dwm_auto" >>$INSTALL_OPTION_PATH ;;
			y) echo "ufw_setup" >>$INSTALL_OPTION_PATH ;;
			z) echo "fail2ban_setup" >>$INSTALL_OPTION_PATH ;;
			*)
				invalid_value=1
				break
				;;

			esac
		done

		if [ $invalid_value -eq 0 ]; then
			break
		fi

	done

}
kb_setup_live() {

	fname="kb_setup"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		kb_lan=$(grep -w KEYBOARD: $CONFIG_PATH | awk '{print $2}') &&
			loadkeys $kb_lan
		[ $? -ne 0 ] && return 10 || :

	fi
}

time_setup_live() {

	fname="time_setup"

	notification "$fname"

	timedatectl set-ntp true
	[ $? -ne 0 ] && return 11 || :
}

upd_cache() {

	fname="upd_cache"

	notification "$fname"

	pacman -Sy
	[ $? -ne 0 ] && return 12 || :
}

ena_parallel_live() {

	fname="ena_parallel_live"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		parallel=$(grep -w PARALLEL: $CONFIG_PATH | awk '{print $2}') &&
			sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = $parallel/" /etc/pacman.conf
		[ $? -ne 0 ] && return 13 || :

	fi
}

config_partitioning() {

	fname="config_partitioning"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		# create partitions
		parted_partitioning() {

			disk_to_par=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==2'))
			par_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==3'))
			par_start_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==4'))
			par_end_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==5'))
			par_type_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==6'))
			par_crypt_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR== 7'))
			file_system_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==8'))
			mount_point_par_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==9'))
			par_fstab_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==10'))
			par_update_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==11'))

			# clear fstab
			touch /fstab
			echo "" >/fstab
			# make partition tables
			disk=""

			if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]]; then
				for ((i = 0; i < ${#disk_to_par[@]}; i++)); do
					if [[ $disk != ${disk_to_par[$i]} ]]; then
						if vgs &>/dev/null; then
							vgs
							vgchange -a n
						fi
						parted -s /dev/${disk_to_par[$i]} mklabel gpt
					fi
					disk="${disk_to_par[$i]}"
				done
			fi

			for ((i = 0; i < ${#par_arr[@]}; i++)); do
				# make partitions
				if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]]; then
					parted -s /dev/${disk_to_par[$i]} mkpart primary ${par_type_arr[$i]} ${par_start_arr[$i]} ${par_end_arr[$i]}

					# encrypt if it needs to be
					if [[ ${par_crypt_arr[$i]} != "no" ]]; then
						exe cryptluks /dev/${par_arr[$i]} ${par_crypt_arr[$i]}
					fi
				else
					if [[ ${par_crypt_arr[$i]} != "no" ]]; then
						cryptsetup open /dev/${par_arr[$i]} ${par_crypt_arr[$i]}
					fi

				fi

				if [[ ${par_fstab_arr[$i]} != "//" ]]; then
					# if normal partition
					# make fs, add fstab entry
					if [[ ${par_crypt_arr[$i]} != "no" ]]; then
						# if it needs to be encrypted, another path needs to be passed
						make_fs /dev/mapper/${par_crypt_arr[$i]} ${file_system_arr[$i]} ${par_update_arr[$i]}
						mount_root /dev/mapper/${par_crypt_arr[$i]} ${mount_point_par_arr[$i]}
					else
						make_fs /dev/${par_arr[$i]} ${file_system_arr[$i]} ${par_update_arr[$i]}
						mount_root /dev/${par_arr[$i]} ${mount_point_par_arr[$i]}
					fi

				else
					# if lvm
					# create physical volume and add to volume group

					# only mingle with lvm on install
					if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]]; then
						if [[ ${par_crypt_arr[$i]} != "no" ]]; then
							device_path="/dev/mapper/${par_crypt_arr[$i]}"
						else
							device_path="/dev/${par_arr[$i]}"
						fi

						pvcreate $device_path
						wipefs -a -f $device_path

						# if volume group already exists, extend it
						if vgdisplay | grep -w ${file_system_arr[$i]}; then
							vgextend ${file_system_arr[$i]} $device_path
						else
							vgcreate ${file_system_arr[$i]} $device_path
						fi
					fi
				fi
			done

		}

		lvm_partitioning() {
			beg=$(grep -n -w LVM: $CONFIG_PATH | cut -d':' -f1)
			end=$(grep -n -w :LVM $CONFIG_PATH | cut -d':' -f1)

			# grab everything between the two lines
			output=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

			vg_names=($(echo "$output" | grep -w "LV |" | cut -d '|' -f2))

			for ((i = 0; i < ${#vg_names[@]}; i++)); do

				lv_names=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A1 | awk 'NR==2'))
				lv_sizes=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A2 | awk 'NR==3'))
				lv_fs=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A3 | awk 'NR==4'))
				lv_mount=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A4 | awk 'NR==5'))
				lv_fstab=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A5 | awk 'NR==6'))
				lv_update=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A6 | awk 'NR==7'))

				for ((j = 0; j < ${#lv_names[@]}; j++)); do
					# create logical volumes
					string_free="${lv_sizes[$j]}"

					if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]]; then
						if [[ "${string_free: -4}" == "FREE" ]]; then
							lvcreate --yes -l ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}
						else
							lvcreate --yes -L ${lv_sizes[$j]} -n ${lv_names[$j]} ${vg_names[$i]}
						fi
					fi

					# make filesystem
					make_fs /dev/mapper/${vg_names[$i]}-${lv_names[$j]} ${lv_fs[$j]} ${lv_update[$j]}

					mount_root /dev/mapper/${vg_names[$i]}-${lv_names[$j]} ${lv_mount[$j]}
				done
			done
		}

		cryptluks() {
			# (/dev/${par_arr[i]}) (${par_crypt_arr[$i]})
			par_to_encrypt="$1"
			par_crypt="$2"

			cryptsetup luksFormat $par_to_encrypt
			[ $? -ne 0 ] && return 10 || :

			cryptsetup open $par_to_encrypt $par_crypt
			[ $? -ne 0 ] && return 10 || :
		}

		make_fs() {
			# (path to partition/lv) (fs)
			full_path="$1"
			file_system="$2"
			update_var="$3"

			if [[ $(awk 'NR==1' "$INSTALL_OPTION_PATH") == "1" ]] || [[ "$update_var" == "update" ]]; then

				if [ "$file_system" == "fat-32" ]; then
					mkfs.fat -F32 $full_path

				elif [ "$file_system" == "swap" ]; then
					mkswap $full_path

				elif [ "$file_system" == "ext4" ]; then
					mkfs.ext4 -F $full_path

				elif [ "$file_system" == "exfat" ]; then
					mkfs.exfat $full_path
				fi

			fi

		}

		mount_root() {
			# (path to partition/lv) (mount_point) (fs_num)
			full_path="$1"
			mount_point="$2"

			if [[ "$mount_point" == "/" ]]; then
				mount $full_path /mnt
			fi

		}

		add_mount_points() {
			mount_arr=("$@")
			# normal partitions
			for ((i = 0; i < ${#mount_arr[@]}; i++)); do
				case ${mount_arr[$i]} in
				"none") ;;
				"//") ;;
				"") ;;
				*)
					mkdir -p /mnt${mount_arr[$i]}
					;;
				esac
			done
		}

		mount_all() {

			par_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==3'))
			mount_point_par_arr=($(grep -w -A10 PARTITION: $CONFIG_PATH | awk 'NR==9'))

			for ((i = 0; i < ${#par_arr[@]}; i++)); do
				case ${mount_point_par_arr[$i]} in
				"none")
					swapon /dev/${par_arr[$i]}
					;;
				"//") ;;
				"") ;;
				"/") ;;
				*)
					mount /dev/${par_arr[$i]} /mnt${mount_point_par_arr[$i]}
					;;
				esac
			done

			beg=$(grep -n -w LVM: $CONFIG_PATH | cut -d':' -f1)
			end=$(grep -n -w :LVM $CONFIG_PATH | cut -d':' -f1)

			# grab everything between the two lines
			output=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

			vg_names=($(echo "$output" | grep -w "LV |" | cut -d '|' -f2))

			for ((i = 0; i < ${#vg_names[@]}; i++)); do

				lv_names=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A1 | awk 'NR==2'))
				lv_mount=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A4 | awk 'NR==5'))

				for ((j = 0; j < ${#lv_names[@]}; j++)); do
					case ${lv_mount[$j]} in
					"none")
						swapon /dev/${vg_names[$i]}/${lv_names[$j]}
						;;
					"//") ;;
					"") ;;
					"/") ;;
					*)
						mount /dev/${vg_names[$i]}/${lv_names[$j]} /mnt${lv_mount[$j]}
						;;
					esac
				done
			done

		}

		pacstrap_root() {
			pacman -Sy --noconfirm archlinux-keyring &&
				pacstrap -K /mnt base linux linux-firmware linux-headers lvm2
			[ $? -ne 0 ] && return 10 || :
		}

		# add lvm to mkinitcpio.conf
		output="$(grep "LVM:" $CONFIG_PATH | awk 'NR==2')"
		parted_partitioning
		lvm_partitioning
		add_mount_points "${mount_point_par_arr[@]}"
		add_mount_points "${lv_mount[@]}"
		mount_all
		exe pacstrap_root
		genfstab -U /mnt >>/mnt/etc/fstab

	fi

}

inst_part_2() {

	fname="inst_part_2"

	notification "$fname"

	curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_scripts/valc-2.sh >/mnt/valc-2.sh &&
		chmod +x /mnt/valc-2.sh
	[ $? -ne 0 ] && return 21 || :

	cp $CONFIG_PATH /mnt/config
	cp $INSTALL_OPTION_PATH /mnt/install
}

exe question_purpose
exe download_config
exe determine_config
exe kb_setup_live
exe time_setup_live
exe upd_cache
exe ena_parallel_live
exe config_partitioning
exe inst_part_2

notification "Changing root"
mv /config /mnt
mv /install /mnt
arch-chroot /mnt
