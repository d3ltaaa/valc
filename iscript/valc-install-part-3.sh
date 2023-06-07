#!/bin/bash

# update grub 
sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# video driver
while true; do
    read -p "Does the device have an amd-gpu? [y/n]" yn
    case $yn in
        [yY]* ) sudo pacman --noconfirm -S xf86-video-amdgpu; break;;
        [nN]* ) sudo pacman --noconfirm -S xf86-video-fbdev; break;;
        * ) echo "Enter 'y' or 'n'!";;
    esac
done

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


# bluetooth

systemctl enable bluetooth.service
systemctl --user enable pulseaudio


# yay-AUR-helper

mkdir ~/.yay

cd ~/.yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm


# remnote

curl -L -o remnote https://www.remnote.com/desktop/linux
chmod +x remnote
sudo mv remnote /opt


# spotify
yay -S ncspot --noconfirm
yay -S brillo --noconfirm
yay -S picom-jonaburg-git --noconfirm


