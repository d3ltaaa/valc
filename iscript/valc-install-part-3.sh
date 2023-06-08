#!/bin/bash


exe () {
    exit_code=1
    while [ $exit_code -ne 0 ]; do

        $1

        # check if everything worked
        if [ $? -eq 0 ]; then
            exit_code=0
            echo "Checks out"; sleep 1
            break
        fi

        while true; do
            read -p "Something went wrong here :( Do you want to redo the command? [y/n]: " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit_code=0; break;;
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
    sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

}

video_setup () {

    # video driver
    notification "Installing video driver"
    while true; do
        read -p "Does the device have an amd-gpu? [y/n]: " yn
        case $yn in
            [yY]* ) sudo pacman --noconfirm -S xf86-video-amdgpu; break;;
            [nN]* ) sudo pacman --noconfirm -S xf86-video-fbdev; break;;
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
    	lf feh xdotool zathura zathura-pdf-mupdf \
        xournalpp discord \
    	neofetch ranger git neovim dunst xwallpaper xclip acpi upower \
    	flatpak xdg-desktop-portal-gtk unzip \
    	fuse2 ripgrep pamixer sox \
    	imagemagick

}

blue_setup () {

    # bluetooth
    notification "Enabling Bluetooth and Audio"
    systemctl enable bluetooth.service
    systemctl --user enable pulseaudio

}

yay_setup () {

    # yay-AUR-helper
    notification "Installing Yay-AUR-helper"
    mkdir ~/.yay
    
    cd ~/.yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm

}

yay_installations () {

    notification "Installing yay packages"
    yay -S ncspot --noconfirm
    yay -S brillo --noconfirm
    yay -S picom-jonaburg-git --noconfirm

}

inst_remnote () {

    # remnote
    notification "Installing Remnote"
    curl -L -o remnote https://www.remnote.com/desktop/linux
    chmod +x remnote
    sudo mv remnote /opt

}

download_setup () {

    notification "Downloading .setup from github"
    
    cd ~/
    git clone https://github.com/d3ltaaa/.setup.git

}

links_setup () {

    notification "Setting up links"

    mkdir -p ~/.config
    ln -s ~/.setup/config/nvim ~/.config
    ln -s ~/.setup/config/suckless ~/.config
    ln -s ~/.setup/config/neofetch ~/.config
    ln -s ~/.setup/config/picom ~/.config
    ln -s ~/.setup/config/dunst ~/.config
    ln -s ~/.setup/config/lf ~/.config

    ln -s ~/.setup/system/.dwm ~/
    sudo rm -r ~/.scripts
    ln -s ~/.setup/system/.scripts ~/
    ln -s ~/.setup/system/.xinitrc ~/
    rm ~/.bash_profile
    ln -s ~/.setup/system/.bash_profile ~/
    rm ~/.bashrc
    ln -s ~/.setup/system/.bashrc ~/

}

building_suckless () {
    
    notification "Building suckless software"

    cd ~/.config/suckless/dwm
    make 
    sudo make install
    cd ~/.config/suckless/st
    make 
    sudo make install
    cd ~/.config/suckless/dmenu
    make 
    sudo make install
    cd ~/.config/suckless/dwmblocks
    make
    sudo make install

}

inst_wallpaper () {

    notification "Downloading wallpapers"

    mkdir -p ~/Pictures/Wallpapers
    mkdir -p ~/.config/wall
    touch ~/.config/wall/picture
    cd ~/Pictures/Wallpapers
    curl https://raw.githubusercontent.com/dxnst/nord-wallpapers/master/operating-systems/archlinux.png > archlinux.png
    curl https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/ign_nordic_triangle.png > triangle.png
    curl https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/arch-nord-dark.png > arch-nord-dark.png
    curl https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/arch-nord-light.png > arch-nord-light.png

}

inst_fonts () {

    notification "Installing fonts"

    sudo mkdir -p /usr/share/fonts/TTF
    sudo mkdir -p /usr/share/fonts/ICONS
    mkdir ~/Downloads
    curl https://fonts.google.com/download?family=Ubuntu%20Mono > ~/Downloads/UbuntuMono.zip
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/NerdFontsSymbolsOnly.zip > ~/Downloads/NerdFontIcons.zip

    sudo mv ~/Downloads/UbuntuMono.zip /usr/share/fonts/TTF
    sudo mv ~/Downloads/NerdFontIcons.zip /usr/share/fonts/ICONS
    cd /usr/share/fonts/TTF
    sudo unzip /usr/share/fonts/TTF/UbuntuMono.zip
    sudo rm UbuntuMono.zip
    sudo rm UFL.txt
    cd /usr/share/fonts/ICONS
    sudo unzip /usr/share/fonts/ICONS/NerdFontIcons.zip
    jsudo rm NerdFontIcons.zip
    sudo rm readme.md
    sudo rm LICENSE

}


create_remove () {

    notification "Making a remove script"

    cd
    touch ~/remove.sh
    echo "sudo rm /valc-install-part-2.sh" >> ~/remove.sh
    echo "cd" >> ~/remove.sh
    echo "sudo rm valc-install-part-3.sh" >> ~/remove.sh
    chmod +x ~/remove.sh

}

exe grub_setup

exe video_setup

exe inst_packages

exe blue_setup

exe yay_setup

exe yay_installations

exe inst_remnote

exe download_setup

exe links_setup

exe building_suckless

exe inst_wallpaper

exe inst_fonts

exe create_remove



