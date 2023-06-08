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

exe grub_setup

exe video_setup

exe inst_packages

exe blue_setup

exe yay_setup

exe yay_installations

exe inst_remnote





