#!/bin/bash
MODULE_NAME="arduino"

function install() {
    echo "[$MODULE_NAME] Installing Arduino..."

    # Add user to the dialout group
    sudo usermod -a -G dialout student
    
    # Install Arduino IDE
    sudo apt install arduino -y
    
    # Check if Arduino directory exists in student's home
    ARDUINO_DIR="/home/student/Arduino"
    if [[ ! -d "$ARDUINO_DIR" ]]; then
        # Run Arduino as student to create the directory
        sudo -u student arduino &
        
        # Wait until Arduino directory is created
        echo "[$MODULE_NAME] Waiting for Arduino directory to appear..."
        while [[ ! -d "$ARDUINO_DIR" ]]; do
            sleep 1
        done
        
        # Kill the Arduino process
        echo "[$MODULE_NAME] Arduino directory found. Killing Arduino process..."
        pkill -f "arduino"
    fi

    # Optional: Remove modemmanager if needed
    # sudo apt remove modemmanager -y

    # Copy the .desktop file to the student's desktop
    cp /var/lib/snapd/desktop/applications/arduino_arduino.desktop "/home/student/Pulpit/Arduino IDE"

    # Set the file permissions to read-only for the user (only root can delete it)
    sudo chmod 444 "/home/student/Pulpit/Arduino IDE"
    sudo chown root:root "/home/student/Pulpit/Arduino IDE"
    
    echo "[$MODULE_NAME] Arduino installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling Arduino..."
    
    # Remove Arduino IDE
    sudo apt remove arduino -y

    # Remove the .desktop file from the desktop
    echo "[$MODULE_NAME] Removing the Arduino desktop shortcut..."
    sudo rm -f "/home/student/Pulpit/Arduino IDE"

    echo "[$MODULE_NAME] Arduino uninstallation completed."
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
