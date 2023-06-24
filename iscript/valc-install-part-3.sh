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
}

inst_packages () {

    notification "Installing packages"
    sudo pacman --noconfirm -S xorg xorg-xinit webkit2gtk base-devel \
    	alsa-utils pulseaudio pavucontrol \
    	bluez bluez-utils pulseaudio-bluetooth blueman \
    	firefox thunar \
        thermald \
    	lf feh xdotool zathura zathura-pdf-mupdf \
        xournalpp discord \
    	neofetch ranger git neovim dunst xwallpaper xclip acpi upower \
    	flatpak xdg-desktop-portal-gtk unzip \
    	fuse2 ripgrep pamixer sox \
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

thermald_setup () {
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
    yay -S picom-jonaburg-git --noconfirm
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

    ln -s ~/.valc/setup/.dwm ~/ &&
    ln -s ~/.valc/setup/.scripts ~/ &&
    ln -s ~/.valc/setup/.xinitrc ~/ &&
    ln -s ~/.valc/setup/.bash_profile ~/ &&
    ln -s ~/.valc/setup/.bashrc ~/ 
    [ $? -ne 0 ] && return 49 || :

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
    curl https://raw.githubusercontent.com/dxnst/nord-wallpapers/master/operating-systems/archlinux.png > archlinux.png &&
    curl https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/ign_nordic_triangle.png > trian &&gle.png
    curl https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/arch-nord-dark.png > arch-nord-dark.png &&
    curl https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/arch-nord-light.png > arch-nord-light.png
    [ $? -ne 0 ] && return 51 || :

}

inst_fonts () {

    notification "Installing fonts"

    sudo mkdir -p /usr/share/fonts/TTF &&
    sudo mkdir -p /usr/share/fonts/ICONS &&
    mkdir ~/Downloads &&
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


create_remove () {

    notification "Making a remove script"

    cd &&
    touch ~/remove.sh &&
    echo "sudo rm /valc-install-part-2.sh" >> ~/remove.sh &&
    echo "cd" >> ~/remove.sh &&
    echo "sudo rm valc-install-part-3.sh" >> ~/remove.sh &&
    chmod +x ~/remove.sh

    [ $? -ne 0 ] && return 53 || :

}

exe grub_setup

exe video_setup

exe inst_packages

exe blue_setup

exe thermald_setup

exe yay_setup

exe yay_installations

exe inst_remnote

exe download_setup

exe links_setup

exe building_suckless

exe inst_wallpaper

exe inst_fonts

exe create_remove



