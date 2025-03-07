#!/bin/bash

MODULE_NAME="vnc"

# Function to install required packages
function install_packages() {
    echo "[$MODULE_NAME] Installing net-tools and nmap..."
    #sudo apt update
    sudo apt install net-tools nmap -y
    echo "[$MODULE_NAME] Packages installation completed."
}

# Function to create the x11vnc service file
function create_x11vnc_service() {
    echo "[$MODULE_NAME] Creating x11vnc service file..."

    # Define the path for the service file
    ICON="/etc/systemd/system/x11vnc.service"
    
    # Create the x11vnc service file
    echo '# File: /etc/systemd/system/x11vnc.service' | sudo tee $ICON > /dev/null
    echo '[Unit]' | sudo tee -a $ICON > /dev/null
    echo 'Description="x11vnc"' | sudo tee -a $ICON > /dev/null
    echo 'Requires=display-manager.service' | sudo tee -a $ICON > /dev/null
    echo 'After=display-manager.service' | sudo tee -a $ICON > /dev/null
    echo '' | sudo tee -a $ICON > /dev/null
    echo '[Service]' | sudo tee -a $ICON > /dev/null
    echo 'ExecStart=/usr/bin/x11vnc -loop -nopw -xkb -repeat -noxrecord -noxfixes -noxdamage -forever -rfbport 5900 -display :0 -auth guess' | sudo tee -a $ICON > /dev/null
    echo '#ExecStart=/usr/bin/x11vnc -loop -nopw -noxdamage -forever -rfbport 5900 -auth guess -display :0' | sudo tee -a $ICON > /dev/null
    echo 'ExecStop=/usr/bin/killall x11vnc' | sudo tee -a $ICON > /dev/null
    echo 'Restart=on-failure' | sudo tee -a $ICON > /dev/null
    echo 'RestartSec=2' | sudo tee -a $ICON > /dev/null
    echo 'User=student' | sudo tee -a $ICON > /dev/null
    echo '' | sudo tee -a $ICON > /dev/null
    echo '[Install]' | sudo tee -a $ICON > /dev/null
    echo 'WantedBy=multi-user.target' | sudo tee -a $ICON > /dev/null

    echo "[$MODULE_NAME] x11vnc service file created."
}

# Function to enable and start the x11vnc service
function start_x11vnc_service() {
    echo "[$MODULE_NAME] Enabling and starting x11vnc service..."

    sudo systemctl daemon-reload
    sudo systemctl enable x11vnc.service
    sudo systemctl start x11vnc.service

    echo "[$MODULE_NAME] x11vnc service started."
}

# Function to install and configure everything
function install() {
    install_packages
    create_x11vnc_service
    start_x11vnc_service
}

# Function to uninstall (cleanup)
function uninstall() {
    echo "[$MODULE_NAME] Uninstalling x11vnc service..."

    # Stop and disable the service
    sudo systemctl stop x11vnc.service
    sudo systemctl disable x11vnc.service

    # Remove the x11vnc service file
    sudo rm -f /etc/systemd/system/x11vnc.service

    # Reload the systemd daemon
    sudo systemctl daemon-reload

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
