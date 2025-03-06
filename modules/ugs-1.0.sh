#!/bin/bash
MODULE_NAME="ugs"

function install() {
    echo "[$MODULE_NAME] Installing Universal G-Code Sender (UGS)..."

    # Install OpenJDK 8
    sudo apt install openjdk-8-jdk -y
    
    # Download the Universal G-Code Sender zip file
    wget https://ugs.jfrog.io/ugs/UGS/v2.0.11/UniversalGcodeSender.zip

    # Extract the zip file
    7z x UniversalGcodeSender.zip -aoa

    # Copy the UniversalGcodeSender.jar to /opt
    sudo cp UniversalGcodeSender/UniversalGcodeSender.jar /opt

    # Create a script to launch UGS on the desktop
    echo '#! /bin/bash' > /home/student/Pulpit/UGS.sh
    echo 'java -jar /opt/UniversalGcodeSender.jar' >> /home/student/Pulpit/UGS.sh

    # Make the script executable
    chmod +x /home/student/Pulpit/UGS.sh

    # Make the script undeletable by student user
    sudo chattr +i /home/student/Pulpit/UGS.sh

    # Optional: Remove the downloaded zip and extracted files
    rm -f UniversalGcodeSender.zip
    rm -rf UniversalGcodeSender

    echo "[$MODULE_NAME] Installation completed. UGS is ready to use on the desktop."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling Universal G-Code Sender..."

    # Remove the Universal G-Code Sender files
    sudo rm -f /opt/UniversalGcodeSender.jar

    # Remove the UGS launch script from the desktop (remove the immutable flag first)
    sudo chattr -i /home/student/Pulpit/UGS.sh
    rm -f /home/student/Pulpit/UGS.sh

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
