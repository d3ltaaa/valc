CONFIG_PATH="/home/$USER/config"
INSTALL_OPTION_PATH="/home/$USER/install"

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

reown_dirs() {

	fname="reown_dirs"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w REOWN_DIR: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :REOWN_DIR $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		dir_group=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))
		for ((i = 0; i < ${#dir_group[@]}; i = $i + 2)); do
			echo "${dir_group[$i]} ${dir_group[$i + 1]}"
			sudo chown ${dir_group[$i + 1]} ${dir_group[$i]}
			sudo chmod g=xrw ${dir_group[$i]}
		done

	fi

}

inst_packages() {

	fname="inst_packages"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		sudo pacman -Syu

		graphics_driver=$(grep -w GRAPHICS_DRIVER: $CONFIG_PATH | awk '{print $2}')
		sudo pacman --noconfirm -S $graphics_driver
		[ $? -ne 0 ] && return 43 || :

		beg=$(grep -n -w PACKAGES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :PACKAGES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		packages=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

		sudo pacman --noconfirm -S $packages
		[ $? -ne 0 ] && return 43 || :

	fi

}

paru_setup() {

	fname="paru_setup"

	notification "$fname"

	dir="$(command -v paru)"

	if [[ $dir == "" ]]; then
		git clone https://aur.archlinux.org/paru.git /usr/local/src/paru
		cd /usr/local/src/paru
		makepkg -si --noconfirm
		[ $? -ne 0 ] && return 45 || :

	fi
}

paru_installations() {

	fname="paru_installations"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w PARU_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :PARU_PACKAGES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		packages=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

		for package in ${packages[@]}; do
			paru -S $package --noconfirm
			[ $? -ne 0 ] && return 46 || :
		done

	fi

}

download_setup() {

	fname="download_setup"

	notification "$fname"

	git clone https://github.com/d3ltaaa/.valc.git /usr/local/share/valc
	[ $? -ne 0 ] && return 48 || :
}

inst_var_packages() {

	fname="inst_var_packages"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w VAR_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :VAR_PACKAGES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		var_packages=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))

		for package in ${var_packages[@]}; do

			case $package in
			"remnote")
				curl -L -o remnote https://www.remnote.com/desktop/linux &&
					chmod +x remnote &&
					sudo mv remnote /opt
				[ $? -ne 0 ] && return 47 || :
				;;

			"auto-cpufreq")
				git clone https://github.com/AdnanHodzic/auto-cpufreq.git /usr/local/src/auto-cpufreq
				[ $? -ne 0 ] && return 47 || :
				cd /usr/local/src/auto-cpufreq && sudo ./auto-cpufreq-installer --install
				sudo auto-cpufreq --install
				[ $? -ne 0 ] && return 47 || :
				;;
			esac
		done
	fi
}

inst_wallpaper() {

	fname="inst_wallpaper"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH && [[ $(awk 'NR==1' $INSTALL_OPTION_PATH) -eq 1 ]]; then
		mkdir -p $HOME/Pictures/Wallpapers &&
			mkdir -p $HOME/.config/wall &&
			curl https://raw.githubusercontent.com/d3ltaaa/backgrounds/main/arch_nord_dark_bg.png >~/Pictures/Wallpapers/arch_nord_dark_bg.png &&
			cp ~/Pictures/Wallpapers/arch_nord_dark_bg.png ~/.config/wall/picture
		[ $? -ne 0 ] && return 51 || :
	fi

}

inst_fonts() {

	fname="inst_fonts"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		sudo mkdir -p /usr/share/fonts/TTF &&
			sudo mkdir -p /usr/share/fonts/ICONS &&
			mkdir -p ~/Downloads &&
			curl https://fonts.google.com/download?family=Ubuntu%20Mono >~/Downloads/UbuntuMono.zip &&
			curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/NerdFontsSymbolsOnly.zip >~/Downloads/NerdFontIcons.zip &&
			sudo mv ~/Downloads/UbuntuMono.zip /usr/share/fonts/TTF &&
			sudo mv ~/Downloads/NerdFontIcons.zip /usr/share/fonts/ICONS &&
			cd /usr/share/fonts/TTF &&
			sudo unzip /usr/share/fonts/TTF/UbuntuMono.zip &&
			sudo rm UbuntuMono.zip &&
			sudo rm UFL.txt &&
			cd /usr/share/fonts/ICONS &&
			sudo unzip /usr/share/fonts/ICONS/NerdFontIcons.zip &&
			sudo rm NerdFontIcons.zip &&
			sudo rm readme.md &&
			sudo rm LICENSE
		[ $? -ne 0 ] && return 52 || :

	fi
}

links_setup() {

	fname="links_setup"

	# notification "$fname"

	# if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

	beg=$(grep -n -w LINKS: $CONFIG_PATH | cut -d':' -f1)
	end=$(grep -n -w :LINKS $CONFIG_PATH | cut -d':' -f1)

	# grab everything between the two lines
	links=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))

	for link in ${links[@]}; do
		origin=$(echo $link | cut -d':' -f1)
		destination=$(echo $link | cut -d':' -f2)

		cd ~/
		mkdir -p "$destination"

		files=($(ls -A $origin))
		for file in ${files[@]}; do
			ln -s -f $origin/$file $destination
		done
	done

}

building_software() {

	fname="building_software"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w BUILD: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :BUILD $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		build_dirs=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))

		for dir in ${build_dirs[@]}; do
			cd $dir
			sudo make install
			[ $? -ne 0 ] && return 50 || :
		done

	fi
}

create_folder() {

	fname="create_folder"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		fol_arr=($(grep -w FOLDER: $CONFIG_PATH | cut -d ' ' -f2-))
		for folder in ${fol_arr[@]}; do
			mkdir -p ~/$folder
		done

	fi
}

dwm_auto() {

	fname="dwm_auto"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		mon_bright_type=$(grep -w MONITOR: $CONFIG_PATH | awk '{print $2}')
		mon_connect=($(grep -w -A1 MONITOR: $CONFIG_PATH | awk 'NR==2'))
		mon_mode=($(grep -w -A2 MONITOR: $CONFIG_PATH | awk 'NR==3'))
		mon_rate=($(grep -w -A3 MONITOR: $CONFIG_PATH | awk 'NR==4'))
		mon_index=($(grep -w -A4 MONITOR: $CONFIG_PATH | awk 'NR==5'))
		mon_pos=($(grep -w -A5 MONITOR: $CONFIG_PATH | awk 'NR==6'))
		mon_pos_out=($(grep -w -A6 MONITOR: $CONFIG_PATH | awk 'NR==7'))

		mkdir -p $HOME/.dwm
		touch $HOME/.dwm/autostart.sh
		chmod +x $HOME/.dwm/autostart.sh

		xrandr_command_string="xrandr"

		for ((i = 0; i < ${#mon_connect[@]}; i++)); do

			xrandr_command_string+=" --output ${mon_connect[$i]} --mode ${mon_mode[$i]} --rate ${mon_rate[$i]}"

			if [[ $i != 0 ]]; then

				xrandr_command_string+=" ${mon_pos[$i]} ${mon_pos_out[$i]}"

			fi

		done

		echo $xrandr_command_string >$HOME/.dwm/autostart.sh

		beg=$(grep -n -w AUTOSTART: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :AUTOSTART $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		autostart=$(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH)

		echo "$autostart" >>$HOME/.dwm/autostart.sh

	fi
}

enable_services() {

	fname="enable_services"

	notification "$fname"

	if grep -w -q "$fname" $INSTALL_OPTION_PATH; then

		beg=$(grep -n -w SERVICES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :SERVICES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		services=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))

		beg=$(grep -n -w USER_SERVICES: $CONFIG_PATH | cut -d':' -f1)
		end=$(grep -n -w :USER_SERVICES $CONFIG_PATH | cut -d':' -f1)

		# grab everything between the two lines
		user_services=($(sed -n "$((${beg} + 1)),$((${end} - 1))p" $CONFIG_PATH))

		for service in ${services[@]}; do
			sudo systemctl enable $service
			[ $? -ne 0 ] && return 44 || :
		done

		for service in ${user_services[@]}; do
			systemctl --user enable $service
			[ $? -ne 0 ] && return 44 || :
		done

	fi

}

create_remove() {

	fname="create_remove"

	notification "$fname"

	cd &&
		touch ~/remove.sh &&
		echo "sudo rm ~/install" >>~/remove.sh &&
		echo "sudo rm /valc-2.sh" >>~/remove.sh &&
		echo "cd" >>~/remove.sh &&
		echo "sudo rm valc-3.sh" >>~/remove.sh &&
		echo "sudo mv ~/config ~/.config.cfg" >>~/remove.sh
	chmod +x ~/remove.sh

	[ $? -ne 0 ] && return 53 || :
}

exe reown_dirs
exe inst_packages
exe paru_setup
exe paru_installations
exe download_setup
exe inst_var_packages
exe inst_wallpaper
exe inst_fonts
exe links_setup
exe building_software
exe create_folder
exe dwm_auto
exe enable_services
exe create_remove
