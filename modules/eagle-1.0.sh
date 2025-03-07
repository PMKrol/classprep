#!/bin/bash

MODULE_NAME="EAGLE_Installation"

# Function to install Autodesk EAGLE
function install_eagle() {
    echo "[$MODULE_NAME] Installing Autodesk EAGLE..."

    # Variables for installation
    installer="Autodesk_EAGLE_9.6.2_English_Linux_64bit.tar.gz"
    version="9.6.2"
    target_dir="/opt"

    # Unzip the installer
    echo "[$MODULE_NAME] Unzipping installer..."
    gunzip --force -k $installer

    installer=${installer%.gz}
    echo "[$MODULE_NAME] Unpacking the archive to $target_dir..."
    sudo tar --warning none --no-same-owner -xf $installer -C $target_dir

    # Clean up installer files
    rm *.tar

    # Set appropriate permissions
    echo "[$MODULE_NAME] Setting permissions..."
    sudo chmod 755 /opt/eagle-$version
    sudo chmod -R a+r /opt/eagle-$version/*
    sudo chmod a+x /opt/eagle-$version/eagle
    sudo find /opt/eagle-$version/ -type d -exec chmod a+x {} \;
    sudo rm /opt/eagle-$version/lib/libxcb*
    sudo chmod 755 /opt/eagle-$version/lib/*
    sudo chmod 755 /opt/eagle-$version/libexec/QtWebEngineProcess

    # Create desktop icon
    echo "[$MODULE_NAME] Installing desktop icon..."
    icon=$HOME/Pulpit/EAGLE_$version.desktop

    if [ -e $icon ]; then
        rm $icon
    fi

    echo "[Desktop Entry]" >> $icon
    echo "Version=1.0" >> $icon
    echo "Type=Application" >> $icon
    echo "Name=EAGLE_$version" >> $icon
    echo "Exec=/opt/eagle-$version/eagle" >> $icon
    echo "Icon=/opt/eagle-$version/bin/eagle-logo.png" >> $icon
    echo "Terminal=false" >> $icon
    echo "StartupNotify=false" >> $icon

    # Download and unpack EAGLE.zip from GitHub
    echo "[$MODULE_NAME] Downloading EAGLE.zip from GitHub..."
    wget https://github.com/PMKrol/classprep/raw/main/EAGLE.zip -O /home/student/Pulpit/EAGLE.zip

    echo "[$MODULE_NAME] Unzipping EAGLE.zip..."
    unzip /home/student/Pulpit/EAGLE.zip -d /home/student/

    # Change the ownership of the unzipped folder to root (san user)
    echo "[$MODULE_NAME] Changing ownership of EAGLE directory to root (san)..."
    sudo chown -R san:san /home/student/EAGLE

    echo "[$MODULE_NAME] Autodesk EAGLE installation completed."
}

# Function to uninstall Autodesk EAGLE
function uninstall_eagle() {
    echo "[$MODULE_NAME] Uninstalling Autodesk EAGLE..."

    # Remove EAGLE directory and files
    echo "[$MODULE_NAME] Removing EAGLE directory and files..."
    sudo rm -rf /opt/eagle-$version

    # Remove desktop icon
    icon=$HOME/Pulpit/EAGLE_$version.desktop
    if [ -e $icon ]; then
        rm $icon
    fi

    # Remove the unzipped EAGLE directory from /home/student
    echo "[$MODULE_NAME] Removing unzipped EAGLE directory..."
    sudo rm -rf /home/student/EAGLE

    echo "[$MODULE_NAME] Autodesk EAGLE uninstalled successfully."
}

# Main logic to decide install or uninstall
case "$1" in
    install)
        install_eagle
        ;;
    uninstall)
        uninstall_eagle
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
