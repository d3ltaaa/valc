CONFIG_PATH="/config"
INSTALL_OPTION_PATH="/install"

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

update_system() {

	fname="update_system"

	notification "$fname"

	pacman -Syu --noconfirm
	[ $? -ne 0 ] && return 22 || :
}

ena_parallel() {

	fname="ena_parallel"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		parallel=$(grep -w PARALLEL: $CONFIG_PATH | awk '{print $2}') &&
			sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = $parallel/" /etc/pacman.conf
		[ $? -ne 0 ] && return 13 || :

	fi
}

time_setup() {

	fname="time_setup"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		time_zone=$(grep -w TIME: $CONFIG_PATH | awk '{print $2}') &&
			ln -sf /usr/share/zoneinfo${time_zone} /etc/localtime &&
			hwclock --systohc
		[ $? -ne 0 ] && return 23 || :
	fi
}

language_setup() {

	fname="language_setup"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		lang1=$(grep -w -A2 LANGUAGE: $CONFIG_PATH | awk 'NR==2')
		lang2=$(grep -w -A2 LANGUAGE: $CONFIG_PATH | awk 'NR==3')

		echo "$lang1" >>/etc/locale.gen &&
			locale-gen &&
			echo "$lang2" >/etc/locale.conf
		[ $? -ne 0 ] && return 24 || :

	fi
}

kb_setup() {

	fname="kb_setup"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		kb=$(grep -w KEYBOARD: $CONFIG_PATH | awk '{print $2}')
		echo "KEYMAP=$kb" >/etc/vconsole.conf
		[ $? -ne 0 ] && return 25 || :

	fi

}

host_name() {

	fname="host_name"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		hostname=$(grep -w NAME: $CONFIG_PATH | awk '{print $2}')

	fi
}

host_setup() {

	fname="host_setup"

	notification "$fname"

	echo $hostname >/etc/hostname &&
		echo "127.0.0.1       localhost" >>/etc/hosts &&
		echo "::1             localhost" >>/etc/hosts &&
		echo "127.0.1.1       $hostname.localdomain $hostname" >>/etc/hosts

	[ $? -ne 0 ] && return 27 || :
}

host_pw() {

	fname="host_pw"

	notification "$fname"

	passwd
	[ $? -ne 0 ] && return 28 || :
}

user_name() {

	fname="user_name"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		user=$(grep -w USER: $CONFIG_PATH | awk '{print $2}')

	fi
}

user_add() {

	fname="user_add"

	notification "$fname"

	useradd -m $user
	[ $? -ne 0 ] && return 30 || :
}

user_pw() {

	fname="user_pw"

	notification "$fname"

	passwd $user
	[ $? -ne 0 ] && return 31 || :
}

user_mod() {

	fname="user_mod"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		group_string=""

		groups=($(grep -w USER_GROUPS: $CONFIG_PATH | cut -d' ' -f2-))
		custom_groups=($(grep -w CUSTOM_GROUPS: $CONFIG_PATH | cut -d' ' -f2-))

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

inst_important_packages() {

	fname="inst_important_packages"

	notification "$fname"

	pacman --noconfirm -S sudo &&
		sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers | sudo EDITOR='tee -a' visudo
	[ $? -ne 0 ] && return 33 || :

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w IMPORTANT_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :IMPORTANT_PACKAGES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		imp_packages=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

		pacman --noconfirm -S $imp_packages
		[ $? -ne 0 ] && return 34 || :

	fi

}

mkinitcpio_setup() {

	fname="mkinitcpio_setup"

	notification "$fname"

	# set keyboard_layout
	keyboard_layout=$(grep -w KEYBOARD: $CONFIG_PATH | cut -d' ' -f3)
	sed -i '1s/^/KEYMAP='"$keyboard_layout"'\n/' /etc/mkinitcpio.conf

	# set HOOKS
	hooks="$(grep -A1 -w HOOKS: $CONFIG_PATH | awk 'NR==2')"
	if [[ "$hooks" != ":HOOKS" ]]; then
		sed -i "/^HOOKS=/c\\HOOKS=($hooks)" /etc/mkinitcpio.conf
	fi

	# set MODULES
	modules="$(grep -A1 -w MODULES: $CONFIG_PATH | awk 'NR==2')"
	if [[ "$modules" != ":MODULES" ]]; then
		sed -i "/^MODULES=/c\\MODULES=($modules)" /etc/mkinitcpio.conf
	fi

	mkinitcpio -p linux
	[ $? -ne 0 ] && return 34 || :
}

grub_setup() {

	fname="grub_setup"

	notification "$fname"

	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		disk_to_par=($(grep -w -A7 PARTITION $CONFIG_PATH | awk 'NR==2'))
		par_arr=($(grep -w -A7 PARTITION $CONFIG_PATH | awk 'NR==3'))
		par_crypt_arr=($(grep -w -A7 PARTITION $CONFIG_PATH | awk 'NR==7'))
		par_type_arr=($(grep -w -A7 PARTITION $CONFIG_PATH | awk 'NR==8'))
		dual_boot=$(grep -w PARTITION: $CONFIG_PATH | awk '{print $2}')

		for ((i = 0; i < ${#par_type_arr[@]}; i++)); do
			if [[ "${par_type_arr[$i]}" == "swap" ]]; then
				sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="resume=\/dev\/'"${par_arr[$i]}"' /' /etc/default/grub
			elif [[ "${par_crypt_arr[$i]}" != "no" ]]; then

				device_UUID=$(blkid | grep -w crypto_LUKS | awk '{print $2}' | awk -F'"' '{print $2}')
				crypt_name="$(lsblk -flo +TYPE | grep -w crypt | awk '{print $1}')"
				root_path="$(lsblk -fpl | grep -w / | awk '{print $1}')"
				sed -i 's#GRUB_CMDLINE_LINUX="#GRUB_CMDLINE_LINUX="cryptdevice=UUID='"$device_UUID"':'"$crypt_name"' root='"$root_path"' #' /etc/default/grub
			fi
		done

		# add swap if lvm to /etc/default/grub
		beg=$(grep -n -w LVM: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :LVM $CONFIG_PATH | cut -d':' -f1)

		output=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

		vg_names=($(echo "$output" | grep -w "LV |" | cut -d '|' -f2))

		for ((i = 0; i < ${#vg_names[@]}; i++)); do

			lv_names=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A1 | awk 'NR==2'))
			lv_fs=($(echo "$output" | grep -w "LV | ${vg_names[$i]}" -A3 | awk 'NR==4'))

			for ((j = 0; j < ${#lv_names[@]}; j++)); do

				if [[ "${lv_fs[$j]}" == "swap" ]]; then
					sed -i 's#GRUB_CMDLINE_LINUX="#GRUB_CMDLINE_LINUX="resume=/dev/mapper/'"${vg_names[$i]}"'-'"${lv_names[$j]}"' #' /etc/default/grub
				fi

			done
		done

		# dual boot
		if [[ "$dual_boot" == "dual" ]]; then
			sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=-1/' /etc/default/grub
			sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=-1/' /etc/default/grub
			sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
		else
			sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=0/' /etc/default/grub
			sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
			echo "ok"
		fi

	fi

	grub-mkconfig -o /boot/grub/grub.cfg
	[ $? -ne 0 ] && return 36 || :
}

systemd_setup() {

	fname="systemd_setup"

	notification "$fname"

	sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=poweroff/' /etc/systemd/logind.conf
	sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=hibernate/' /etc/systemd/logind.conf
	grub-mkconfig -o /boot/grub/grub.cfg
	[ $? -ne 0 ] && return 37 || :

}

enable_services_root() {

	fname="enable_services_root"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		services=($(grep -w SERVICES: $CONFIG_PATH | cut -d' ' -f2-))

		for service in ${services[@]}; do
			systemctl enable $service
			[ $? -ne 0 ] && return 44 || :

		done

	fi

}

inst_part_3() {

	fname="inst_part"

	notification "$fname"

	curl https://raw.githubusercontent.com/d3ltaaa/valc/main/install_scripts/valc-3.sh >/home/$user/valc-3.sh
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
exe mkinitcpio_setup
exe grub_setup
exe systemd_setup
exe enable_services_root
exe inst_part_3
mv $CONFIG_PATH /home/$user
mv $INSTALL_OPTION_PATH /home/$user
clear
echo "The next commands are: "
echo "exit; umount -R /mnt; shutdown"
echo "Remove usb, start device, login, ./valc-3.sh"
