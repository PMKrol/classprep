#!/bin/bash

MODULE_NAME="webgcode"

# Function to install Apache2
function install_apache() {
    echo "[$MODULE_NAME] Installing Apache2..."
    #sudo apt update
    sudo apt install apache2 -y
    echo "[$MODULE_NAME] Apache2 installation completed."
}

# Function to download and set up WebGCode
function setup_webgcode() {
    echo "[$MODULE_NAME] Downloading WebGCode..."
    wget "https://github.com/nraynaud/webgcode/archive/refs/heads/gh-pages.zip" -O gh-pages.zip

    echo "[$MODULE_NAME] Extracting WebGCode..."
    7z x gh-pages.zip -aoa

    echo "[$MODULE_NAME] Copying WebGCode files to Apache server..."
    sudo cp -r webgcode-gh-pages/* /var/www/html

    echo "[$MODULE_NAME] Setting correct permissions..."
    sudo chmod -R 775 /var/www/html
    echo "[$MODULE_NAME] WebGCode setup completed."
}

# Function to create a desktop shortcut for G-code Viewer
function create_desktop_shortcut() {
    echo "[$MODULE_NAME] Creating desktop shortcut..."

    ICON="/home/student/Pulpit/Gcode.desktop"
    echo "[Desktop Entry]" > $ICON
    echo "Encoding=UTF-8" >> $ICON
    echo "Name=G-code Viewer" >> $ICON
    echo "Type=Link" >> $ICON
    echo "URL=http://localhost/" >> $ICON
    echo "Icon=text-html" >> $ICON

    # Making the desktop shortcut executable
    chmod +x $ICON
    echo "[$MODULE_NAME] Desktop shortcut created at $ICON."
}

# Function to install all components
function install() {
    install_apache
    setup_webgcode
    create_desktop_shortcut
}

# Function to uninstall (cleanup)
function uninstall() {
    echo "[$MODULE_NAME] Uninstalling WebGCode setup..."

    # Removing WebGCode from Apache web directory
    sudo rm -rf /var/www/html/*

    # Removing the desktop shortcut
    rm -f /home/student/Pulpit/Gcode.desktop

    echo "[$MODULE_NAME] Uninstallation completed."
}

# Check the provided arguments (install/uninstall)
case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
