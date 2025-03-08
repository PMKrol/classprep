#!/bin/bash
MODULE_NAME="arduino"
   
# Definiowanie ścieżki do ikony na pulpicie
DESKTOP_FILE="/home/student/Pulpit/Arduino_IDE.desktop"

function install() {
    echo "[$MODULE_NAME] Installing Arduino..."

    # Add user to the dialout group
    sudo usermod -a -G dialout student
    sudo usermod -a -G dialout san
    
    # Install Arduino IDE
    sudo apt install arduino -y
    
    # Check if Arduino directory exists in student's home
    ARDUINO_DIR="/home/student/Arduino"
    sudo -u student arduino &
        
#     if [[ ! -d "$ARDUINO_DIR" ]]; then
#     #    Run Arduino as student to create the directory
#         
#      #   Wait until Arduino directory is created
#         echo "[$MODULE_NAME] Waiting for Arduino directory to appear..."
#         while [[ ! -d "$ARDUINO_DIR" ]]; do
#             sleep 1
#         done
#         
#       #  Kill the Arduino process
#         echo "[$MODULE_NAME] Arduino directory found. Killing Arduino process..."
#         pkill -f "arduino"
#     fi

    # Optional: Remove modemmanager if needed
    # sudo apt remove modemmanager -y

    # Copy the .desktop file to the student's desktop
    cp /usr/share/applications/arduino.desktop "/home/student/Pulpit"

#     #Tworzenie pliku .desktop
#     echo "#!/usr/bin/env xdg-open" >> $DESKTOP_FILE
#     echo "[Desktop Entry]" > $DESKTOP_FILE
#     echo "X-SnapInstanceName=arduino" >> $DESKTOP_FILE
#     echo "Type=Application" >> $DESKTOP_FILE
#     echo "Name=Arduino IDE" >> $DESKTOP_FILE
#     echo "# Name=arduino-mhall119" >> $DESKTOP_FILE
#     echo "GenericName=Arduino IDE" >> $DESKTOP_FILE
#     echo "# GenericName=arduino-mhall119" >> $DESKTOP_FILE
#     echo "Comment=Open-source electronics prototyping platform" >> $DESKTOP_FILE
#     echo "X-SnapAppName=arduino" >> $DESKTOP_FILE
#     echo "Exec=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/arduino_arduino.desktop /snap/bin/arduino" >> $DESKTOP_FILE
#     echo "# Exec=arduino-mhall119.arduino" >> $DESKTOP_FILE
#     echo "Icon=/snap/arduino/85/meta/gui/arduino.png" >> $DESKTOP_FILE
#     echo "Terminal=false" >> $DESKTOP_FILE
#     echo "Categories=Development;IDE;Electronics;" >> $DESKTOP_FILE
#     echo "MimeType=text/x-arduino" >> $DESKTOP_FILE
#     echo "Keywords=embedded electronics;electronics;avr;microcontroller;" >> $DESKTOP_FILE
#     echo "StartupWMClass=processing-app-Base" >> $DESKTOP_FILE

#    # Nadanie odpowiednich uprawnień do pliku .desktop
#    chmod +x $DESKTOP_FILE

    echo "Desktop entry for Arduino IDE has been created on the Desktop."

    
    # Set the file permissions to read-only for the user (only root can delete it)
    #sudo chmod 444 "/home/student/Pulpit/arduino.desktop"
    #sudo chown root:root "/home/student/Pulpit/arduino.desktop"
    
    sudo chattr +i "/home/student/Pulpit/arduino.desktop"
    
    echo "[$MODULE_NAME] Arduino installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling Arduino..."
    
    # Remove Arduino IDE
    sudo apt remove arduino -y

    # Remove the .desktop file from the desktop
    echo "[$MODULE_NAME] Removing the Arduino desktop shortcut..."
    sudo chattr -i "/home/student/Pulpit/arduino.desktop"
    sudo rm -f "/home/student/Pulpit/arduino.desktop"

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
