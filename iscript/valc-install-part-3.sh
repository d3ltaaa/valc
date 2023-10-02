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
VALUE_VIDEO_SETUP=0
VALUE_FOLDER_SETUP=0
VALUE_IP_SETUP=0
VALUE_MONITOR_SETUP=0
VALUE_KB_SETUP=0

determine_config () {

    if [ -e $CONFIG_PATH ]; then
        echo "config found"
        USE_CONFIG_FILE=1
    fi


    if [[ $USE_CONFIG_FILE -eq 1 ]]; then

        while true; do

            invalid_value=0

            echo "determine_config"
            echo "grub_setup"
            echo "video_setup: V"
            echo "inst_packages"
            echo "blue_setup"
            echo "enable_services "
            echo "yay_setup"
            echo "yay_installations"
            echo "inst_remnote"
            echo "download_setup"
            echo "links_setup"
            echo "create_folder: C"
            echo "building_suckless"
            echo "inst_wallpaper"
            echo "inst_fonts"
            echo "manage_monitor: M"
            echo "kb_setup: K"


            read -p "What do you want to use the config file for? [V/C/M/K]: " choice

            choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

            if [ -z "$choice" ]; then
                USE_CONFIG_FILE=0
            fi


            for char in $(echo "$choice" | grep -o .); do
                case "$char" in
                    v)
                        VALUE_VIDEO_SETUP=1
                        ;;
                    c)
                        VALUE_FOLDER_SETUP=1
                        ;;
                    m)
                        VALUE_MONITOR_SETUP=1
                        ;;
                    k)
                        VALUE_KB_SETUP=1
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

grub_setup () {

    # update grub 
    notification "Setting up Grub"
    sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub &&
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    [ $? -ne 0 ] && return 40 || :

}

video_setup () {

    # video driver
    notification "Installing video driver"
    if [ $VALUE_VIDEO_SETUP -eq 1 ]; then

        graphics_driver=$(grep -i -w GRAPHICS_DRIVER: $CONFIG_PATH | awk '{print $2}')
        sudo pacman --noconfirm -S  $graphics_driver

    else
        while true; do
            read -p "Does the device have an amd-gpu? [y/n]: " yn
            case $yn in
                [yY]* ) 
                    sudo pacman --noconfirm -S xf86-video-amdgpu
                    [ $? -ne 0 ] && return 41 || :
                    break;;
                [nN]* ) 
                    sudo pacman --noconfirm -S xf86-video-fbdev
                    [ $? -ne 0 ] && return 42 || :
                    break;;
                * ) echo "Enter 'y' or 'n'!";;
            esac
        done
    fi
}

inst_packages () {

    notification "Installing packages"

    sudo pacman -Syu
    sudo pacman --noconfirm -S xorg xorg-xinit webkit2gtk base-devel \
        tmux \
    	alsa-utils \
        pulseaudio \
        pavucontrol \
    	bluez \
        bluez-utils \
        pulseaudio-bluetooth \
        blueman \
    	firefox \
        thunar \
        thermald \
        fuse-exfat \
    	lf \
        picom \
        udisks2 \
        feh \
        xdotool \
        zathura \
        zathura-pdf-mupdf \
        xournalpp discord \
    	neofetch \
        ranger \
        git \
        neovim \
        telegram-desktop \
        virtualbox \
        dunst \
        xwallpaper \
        ffmpeg4.4 \
        xclip \
        mpv \
        yt-dlp \
        acpi \
        upower \
        xbindkeys \
    	flatpak \
        xdg-desktop-portal-gtk \
        unzip \
    	fuse2 \
        ripgrep \
        pamixer \
        pulsemixer \
        sox \
        gimp \
    	imagemagick

    [ $? -ne 0 ] && return 43 || :

}

blue_setup () {

    # bluetooth
    notification "Enabling Bluetooth and Audio"
    systemctl enable bluetooth.service &&
    systemctl --user enable pulseaudio
    [ $? -ne 0 ] && return 44 || :
}


enable_services () {
    sudo systemctl enable sshd
    sudo systemctl enable thermald
}

yay_setup () {

    # yay-AUR-helper
    notification "Installing Yay-AUR-helper"
    mkdir ~/.yay &&
    
    cd ~/.yay &&
    git clone https://aur.archlinux.org/yay.git &&
    cd yay &&
    makepkg -si --noconfirm &&
    [ $? -ne 0 ] && return 45 || :

}

yay_installations () {

    notification "Installing yay packages"
    yay -S ncspot --noconfirm &&
    yay -S brillo --noconfirm &&
    # yay -S picom-jonaburg-git --noconfirm &&
    yay -S xvkbd --noconfirm 
    # yay -S coreshot 
    [ $? -ne 0 ] && return 46 || :

}

inst_auto_cpu_freq () {
    cd ~/.config/
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq && sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
}

inst_remnote () {

    # remnote
    notification "Installing Remnote"
    curl -L -o remnote https://www.remnote.com/desktop/linux &&
    chmod +x remnote &&
    sudo mv remnote /opt
    [ $? -ne 0 ] && return 47 || :

}

download_setup () {

    notification "Downloading valc from github"
    
    cd ~/
    git clone https://github.com/d3ltaaa/.valc.git
    [ $? -ne 0 ] && return 48 || :

}

links_setup () {

    notification "Setting up links"
    
    [ -e ~/.bash_profile ] && rm ~/.bash_profile
    [ -e ~/.bashrc ] && rm  ~/.bashrc

    mkdir -p ~/.config &&
    ln -s ~/.valc/config/nvim ~/.config &&
    ln -s ~/.valc/config/suckless ~/.config &&
    ln -s ~/.valc/config/neofetch ~/.config &&
    ln -s ~/.valc/config/picom ~/.config &&
    ln -s ~/.valc/config/dunst ~/.config &&
    ln -s ~/.valc/config/lf ~/.config

    ln -s ~/.valc/setup/.scripts ~/ &&
    ln -s ~/.valc/setup/.xinitrc ~/ &&
    ln -s ~/.valc/setup/.bash_profile ~/ &&
    ln -s ~/.valc/setup/.bashrc ~/ &&
    ln -s ~/.valc/setup/.xbindkeysrc ~/ &&
    ln -s ~/.valc/config/tmux ~/.config/ && 
    mkdir -p ~/.ssh && 
    ln -s ~/.valc/setup/ssh_files/repl_ip_in_ssh_config.sh ~/.ssh/repl_ip_in_ssh_config.sh 
    [ $? -ne 0 ] && return 49 || :

}

create_folder () {

    notification "Folder"

    if [ $VALUE_FOLDER_SETUP -eq 1 ]; then

        fol_arr=($(grep -i -w FOLDERS $CONFIG_PATH | cut -d ' ' -f2-))
        for folder in ${fol_arr[@]}; do
            mkdir ~/$folder
        done

    else
        while true; do
            read -p "Which folder do you want to create in the home directory? [N]: " choice
            case $choice in
                [Nn] )
                    break
                    ;;
                *)
                    mkdir ~/$choice
                    ;;
            esac
        done
    fi
}

building_suckless () {
    
    notification "Building suckless software"

    cd ~/.config/suckless/dwm &&
    make &&
    sudo make install &&
    cd ~/.config/suckless/st &&
    make && 
    sudo make install &&
    cd ~/.config/suckless/dmenu &&
    make && 
    sudo make install &&
    cd ~/.config/suckless/dwmblocks &&
    make &&
    sudo make install

    [ $? -ne 0 ] && return 50 || :

}

inst_wallpaper () {

    notification "Downloading wallpapers"

    mkdir -p ~/Pictures/Wallpapers &&
    mkdir -p ~/.config/wall &&
    touch ~/.config/wall/picture &&
    cd ~/Pictures/Wallpapers &&
    curl https://raw.githubusercontent.com/d3ltaaa/backgrounds/main/arch_nord_dark_bg.png > arch_nord_dark_bg.png
    [ $? -ne 0 ] && return 51 || :

}

inst_fonts () {

    notification "Installing fonts"

    sudo mkdir -p /usr/share/fonts/TTF &&
    sudo mkdir -p /usr/share/fonts/ICONS &&
    mkdir -p ~/Downloads &&
    curl https://fonts.google.com/download?family=Ubuntu%20Mono > ~/Downloads/UbuntuMono.zip &&
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/NerdFontsSymbolsOnly.zip > ~/Downloads/NerdFontIcons.zip &&
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

}


dwm_auto () {

    notification "Create dwm-auto"

    if [ $VALUE_MONITOR_SETUP -eq 1 ] || [ $VALUE_KB_SETUP -eq 1 ]; then
        mkdir ~/.dwm
        touch ~/.dwm/autostart.sh
        chmod +x ~/.dwm/autostart.sh

        echo "#This is a generated script!" > ~/.dwm/autostart.sh
        echo "dwmblocks &" >> ~/.dwm/autostart.sh
    fi
}





monitor_setup () {

    notification "Monitor setup"
    
    if [ $VALUE_MONITOR_SETUP -eq 1 ]; then
        mon_arr=($(grep -i -w MONITOR $CONFIG_PATH | cut -d ' ' -f2-))
        # turn_off=($(grep -i -w TURN-OFF $CONFIG_PATH | cut -d ' ' -f2-))


        # for mon in ${turn_off[@]}; do
        #     echo "xrandr --output $mon --off " >> ~/.dwm/autostart.sh
        # done
    

        monitor_count=${#mon_arr[@]}


        string="xrandr --output ${mon_arr[0]}"

        for (( i=1; i<$monitor_count; i++ )); do
            string+=" --left-of ${mon_arr[i]}"
        done

        echo $string >> ~/.dwm/autostart.sh

    fi

    echo "picom &" >> ~/.dwm/autostart.sh
}

kb_setup () {

    if [ $VALUE_KB_SETUP -eq 1]; then

        kb_layout=$(grep -i -w KEYBOARD $CONFIG_PATH | awk '{print $3}')
        echo "setxkbmap $kb_layout" >> ~/.dwm/autostart.sh

    else

        echo "setxkbmap de" >> ~/.dwm/autostart.sh
    fi
}


create_remove () {

    notification "Making a remove script"

    cd &&
    touch ~/remove.sh &&
    echo "sudo rm /valc-install-part-2.sh" >> ~/remove.sh &&
    echo "cd" >> ~/remove.sh &&
    echo "sudo rm valc-install-part-3.sh" >> ~/remove.sh &&
    chmod +x ~/remove.sh

    sudo mv /config ~/.config.cfg

    [ $? -ne 0 ] && return 53 || :

}

exe determine_config

exe grub_setup

exe video_setup

exe inst_packages

exe blue_setup

exe enable_services 

exe yay_setup

exe yay_installations

exe inst_remnote

exe download_setup

exe links_setup

exe create_folder

exe building_suckless

exe inst_wallpaper

exe inst_fonts

exe dwm_auto

exe monitor_setup

exe kb_setup

exe create_remove



