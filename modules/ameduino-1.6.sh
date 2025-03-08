#!/bin/bash

MODULE_NAME="AMEDUINO_Installation"

# Define version and paths
AVERSION="ameduino_pmkrol2"
INSTALL_DIR="/usr/local/bin/ameduino64"
SYMLINK="/usr/local/bin/ameduino"
ICON_PATH="/home/student/Pulpit/ameduino.desktop"
PROCESSING_ZIP_URL="https://github.com/PMKrol/classprep/blob/main/processing.zip?raw=true"
TEMP_DIR="/tmp/processing"

# Function to install AMEDUINO
function install_ameduino() {
    echo "[$MODULE_NAME] Installing AMEDUINO..."

    # Download and unzip the processing.zip
    echo "[$MODULE_NAME] Downloading processing.zip..."
    wget -O /tmp/processing.zip $PROCESSING_ZIP_URL

    # Unzip the downloaded zip file
    echo "[$MODULE_NAME] Unzipping processing.zip..."
    mkdir -p $TEMP_DIR
    unzip -o /tmp/processing.zip -d $TEMP_DIR

    # Go to the application directory
    cd $TEMP_DIR/processing/$AVERSION/application.linux64

    # Remove any previous installations
    echo "[$MODULE_NAME] Cleaning up previous installations..."
    sudo rm -rf $INSTALL_DIR
    sudo mkdir $INSTALL_DIR

    # Copy files to the installation directory
    echo "[$MODULE_NAME] Copying files..."
    sudo cp -r * $INSTALL_DIR
    sudo chmod +x $INSTALL_DIR/$AVERSION
    sudo chown student $INSTALL_DIR -R

    # Create symlink to easily run the application
    echo "[$MODULE_NAME] Creating symlink..."
    sudo rm -f $SYMLINK
    echo "#!/bin/bash" | sudo tee $SYMLINK
    echo "$INSTALL_DIR/$AVERSION" | sudo tee -a $SYMLINK
    sudo chmod +x $SYMLINK

    # Create a desktop icon
    echo "[$MODULE_NAME] Installing desktop icon..."
    if [ -e $ICON_PATH ]; then
        echo "[$MODULE_NAME] Removing old desktop icon..."
        rm $ICON_PATH
    fi

    echo "#!/usr/bin/env xdg-open" >> $ICON_PATH
    echo "[Desktop Entry]" >> $ICON_PATH
    echo "Version=1.0" >> $ICON_PATH
    echo "Type=Application" >> $ICON_PATH
    echo "Name=ameduino" >> $ICON_PATH
    echo "Exec=ameduino" >> $ICON_PATH
    echo "Icon=" >> $ICON_PATH
    echo "Path=" >> $ICON_PATH
    echo "Terminal=false" >> $ICON_PATH
    echo "StartupNotify=false" >> $ICON_PATH

    # Secure the icon for the user 'san'
    echo "[$MODULE_NAME] Securing desktop icon for user 'san'..."
    #sudo chown student:student $ICON_PATH
    #sudo chmod 444 $ICON_PATH
    sudo chattr +i $ICON_PATH
    
    echo "[$MODULE_NAME] AMEDUINO installation completed successfully!"
}

# Function to uninstall AMEDUINO
function uninstall_ameduino() {
    echo "[$MODULE_NAME] Uninstalling AMEDUINO..."

    # Remove installation files and symlink
    echo "[$MODULE_NAME] Removing installation files and symlink..."
    sudo rm -rf $INSTALL_DIR
    sudo rm -f $SYMLINK

    # Remove the desktop icon
    echo "[$MODULE_NAME] Removing desktop icon..."
    if [ -e $ICON_PATH ]; then
        sudo chattr -i $ICON_PATH
        rm $ICON_PATH
    fi

    echo "[$MODULE_NAME] AMEDUINO uninstalled successfully!"
}

# Main logic to handle installation or uninstallation
case "$1" in
    install)
        install_ameduino
        ;;
    uninstall)
        uninstall_ameduino
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
