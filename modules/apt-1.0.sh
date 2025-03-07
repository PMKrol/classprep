#!/bin/bash
MODULE_NAME="apt"

function install() {
    echo "[$MODULE_NAME] Installing required packages..."

    sudo apt update
    sudo apt upgrade -y
    
    # Remove conflicting package
    sudo apt remove modemmanager -y

    # Install required packages
    sudo apt install -y \
        veyon-service \
        mc \
        screen \
        openssh-server \
        openssh-client \
        x11vnc \
        apache2 \
        openjdk-8-jdk \
        gnome-disk-utility \
        smartmontools \
        net-tools \
        arduino \
        net-tools \
        nmap

    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling packages..."

    echo "    ### UNINSTALLING DISABLED!! ###"
    /*# Remove installed packages
    sudo apt remove --purge -y \
        veyon-service \
        mc \
        screen \
        openssh-server \
        openssh-client \
        x11vnc \
        apache2 \
        openjdk-8-jdk \
        gnome-disk-utility \
        smartmontools \
        net-tools \
        arduino*/

    echo "[$MODULE_NAME] Uninstallation completed."
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
