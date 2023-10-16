CONFIG_PATH="~/config"
INSTALLTION_OPTION_PATH="~/install"

inst_packages () {

    fname="inst_packages"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

        sudo pacman -Syu

        graphics_driver=$(grep -i -w GRAPHICS_DRIVER: $CONFIG_PATH | awk '{print $2}')
        sudo pacman --noconfirm -S  $graphics_driver
        [ $? -ne 0 ] && return 43 || :


        beg=$(grep -n -i -w PACKAGES: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :PACKAGES $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        packages=$(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH)

        sudo pacman --noconfirm -S $packages
        [ $? -ne 0 ] && return 43 || :

    else

        read -p "Which packages do you want to install?: " packages

        sudo pacman -Syu
        sudo pacman --noconfirm -S $packages
        [ $? -ne 0 ] && return 43 || :

    fi

}


enable_services () {

    fname="enable_services"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

        beg=$(grep -n -i -w SERVICES: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :SERVICES $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        services=($(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH))

        for service in ${services[@]}; do
            systemctl enable $service
            [ $? -ne 0 ] && return 44 || :

        done

    fi

    
}


yay_setup () {

    fname="yay_setup"

    notification "$fname"

    git clone https://aur.archlinux.org/yay.git /usr/local/src &&
    cd /usr/local/src &&
    makepkg -si --noconfirm 
    [ $? -ne 0 ] && return 45 || :

}


yay_installations () {

    fname="yay_installations"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

        beg=$(grep -n -i -w YAY_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :YAY_PACKAGES $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        packages=$(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH)

        for package in ${packages[@]}; do
            yay -S $package --noconfirm 
            [ $? -ne 0 ] && return 46 || :
        done

    fi

}


download_setup () {

    fname="download_setup"

    notification "$fname"

    git clone https://github.com/d3ltaaa/.valc.git /usr/local/share/
    [ $? -ne 0 ] && return 48 || :
}


inst_var_packages () {

    fname="inst_var_packages"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then
        
        beg=$(grep -n -i -w VAR_PACKAGES: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :VAR_PACKAGES $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        var_packages=($(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH))

        for package in ${var_packages[@]}; do

            case $package in
                "remnote")
                    curl -L -o remnote https://www.remnote.com/desktop/linux &&
                    chmod +x remnote &&
                    sudo mv remnote /opt
                    [ $? -ne 0 ] && return 47 || :
                    ;;

                "auto-cpufreq")
                    git clone https://github.com/AdnanHodzic/auto-cpufreq.git /usr/local/src
                    cd /usr/local/src/auto-cpufreq && sudo ./auto-cpufreq-installer
                    sudo auto-cpufreq --install
                    ;;
            esac
        done
    fi
}


building_software () {

    fname="building_software"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

        beg=$(grep -n -i -w BUILD: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :BUILD $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        build_dirs=($(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH))


        for dir in ${build_dirs[@]}; do
            cd $dir 
            make && 
            sudo make install
            [ $? -ne 0 ] && return 50 || :
        done

    fi
}


inst_wallpaper () {

    fname="download_wallpaper"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH && [[ $(awk 'NR==1' install) -eq 1 ]]; then
        mkdir -p ~/Pictures/Wallpapers &&
        mkdir -p ~/.config/wall &&
        curl https://raw.githubusercontent.com/d3ltaaa/backgrounds/main/arch_nord_dark_bg.png > ~/Pictures/Wallpapers/arch_nord_dark_bg.png &&
        cp ~/Pictures/Wallpapers/arch_nord_dark_bg.png ~/.config/wall/picture
        [ $? -ne 0 ] && return 51 || :
    fi
    
}


inst_fonts () {

    fname="inst_fonts"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

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

    fi
}


links_setup () {

    fname="links_setup"

    # notification "$fname"

    # if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then
    

    beg=$(grep -n -i -w LINKS: $CONFIG_PATH | cut -d':' -f1)
    end=$(grep -n -i -w :LINKS $CONFIG_PATH | cut -d':' -f1)

    # grab everything between the two lines
    links=($(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH))

    for link in ${links[@]}; do
        origin=$(echo $link | cut -d':' -f1)
        destination=$(echo $link | cut -d':' -f2)

        files=($(ls -A $origin))
        for file in ${files[@]}; do
            ln -s -f $origin/$file $destination
        done
    done
        
}


create_folder () {

    fname="create_folder"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

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


dwm_auto () {

    fname="dwm_auto"

    notification "$fname"

    if grep -w -q "$fname" $INSTALLATION_OPTION_PATH; then

        mkdir ~/.dwm
        touch ~/.dwm/autostart.sh
        chmod +x ~/.dwm/autostart.sh

        beg=$(grep -n -i -w AUTOSTART: $CONFIG_PATH | cut -d':' -f1)
        end=$(grep -n -i -w :AUTOSTART $CONFIG_PATH | cut -d':' -f1)

        # grab everything between the two lines
        autostart=$(sed -n "$((${beg}+1)),$((${end}-1))p" $CONFIG_PATH)

        echo "$autostart" > ~/.dwm/autostart.sh

    fi
}


create_remove () {

    fname="create_remove"

    notification "$fname"

    cd &&
    touch ~/remove.sh &&
    echo "sudo rm /valc-install-part-2.sh" >> ~/remove.sh &&
    echo "cd" >> ~/remove.sh &&
    echo "sudo rm valc-install-part-3.sh" >> ~/remove.sh &&
    chmod +x ~/remove.sh

    sudo mv /config ~/.config.cfg

    [ $? -ne 0 ] && return 53 || :
}

exe inst_packages
exe enable_services
exe yay_setup
exe yay_installations
exe download_setup
exe inst_var_packages
exe building_software
exe inst_wallpaper
exe inst_fonts
exe links_setup
exe create_folder
exe dwm_auto
exe create_remove
