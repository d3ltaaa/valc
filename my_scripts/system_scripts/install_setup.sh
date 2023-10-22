#!/bin/bash

APP_PATH=/run/media/$USER/INST/apps/Linux

check_for_disk() {

    if [[ -e /run/media/$USER/INST ]]; then
        echo "Disk connected!"
    else 
        echo "Disk not connected!"
        exit 1
    fi
}

install_fritzing () {

    if [[ ! -e /opt/fritzing ]]; then

        echo "Installing: fritzing ..." 
        sudo cp $APP_PATH/$fritzing_name /opt/fritzing && echo "Installed: fritzing!" || echo "Failed installing: Fritzing!" 

    else
        echo "Already installed: fritzing!"
    fi

}

install_synergy () {
    if flatpak list | grep -q synergy; then
        echo "Already installed: Synergy!"
    else
        echo "Installing: Synergy ..."
        sudo flatpak --assumeyes install $APP_PATH/$synergy_name && \
        flatpak list | grep synergy && \
        run_synergy && \
        echo "Installed: Synergy!" || \
        echo "Failed installing: Synergy!"


    fi
}

install_tor () {

    if [[ -e /opt/tor-browser ]]; then
        echo "Already installed: Tor!"
    else
        echo "Installing: Tor ..."
        sudo cp -r $APP_PATH/$tor_name /opt && \
        cd /opt/ && \
        sudo tar -xf /opt/$tor_name && \
        sudo rm /opt/$tor_name && \
        sudo chown -R $USER:$USER /opt/tor-browser && \
        echo "Installed: Tor!" || \
        echo "Failed installing: Tor!"
    fi

}

copy_configs () {

    if [[ -e /run/media/$USER/INST/config/ip ]]; then

        echo "Copying ssh files ..."
        mkdir -p ~/.ssh
        cp /run/media/$USER/INST/config/ip/* /home/$USER/.ssh/ && echo "Succeeded!"

    else
        echo "No ssh files to copy!"
    fi

}

check_for_fritzing () {

    fritzing_name=$(ls $APP_PATH | grep fritzing)

    if [ -z "$fritzing_name" ]; then
        echo "Fritzing is not on the USB!"
    else
        echo "$APP_PATH/$fritzing_name"
        install_fritzing 
    fi

}

check_for_synergy () {

    synergy_name=$(ls $APP_PATH | grep synergy)

    if [ -z "$synergy_name" ]; then
        echo "Synergy installer is not on the USB!"
    else
        echo "$APP_PATH/$synergy_name"
        install_synergy
    fi

}

check_for_tor () {

    tor_name=$(ls $APP_PATH | grep tor)

    if [ -z "$tor_name" ]; then
        echo "Tor installer is not on the USB!"
    else
        echo "$APP_PATH/$tor_name"
        install_tor
    fi
}

add_git_config () {

    git_output=$(cat ~/.gitconfig | grep -w name)
    if [ -z "$git_output" ]; then
        read -p "What is your email?: " email
        read -p "What is your git name?: " git_name

        git config --global user.email "$email" && 
        git config --global user.name "$git_name" && 
        sudo git config --global user.email "$email" &&
        sudo git config --global user.name "$git_name"
        echo "Succeeded!"
    else
        echo "Git already configured!"
    fi

}

run_synergy () {
    cat /run/media/$USER/INST/config/synergy_code | tr -d '\n' | xclip -selection clipboard
    flatpak run com.symless.synergy
}
check_for_disk
copy_configs
add_git_config
check_for_fritzing
check_for_tor
check_for_synergy
