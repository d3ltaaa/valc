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
        flatpak install $APP_PATH/$synergy_name && \
        flatpak update && \
        flatpak list | grep synergy && \
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

check_for_disk
check_for_fritzing
check_for_synergy
check_for_tor

