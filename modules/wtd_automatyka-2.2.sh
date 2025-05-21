#!/bin/bash
MODULE_NAME="wtd_automatyka"

function install() {
    echo "[$MODULE_NAME] Starting installation process..."

    # Ścieżka do katalogu Pobrane
    #sudo chmod 777 /home/student/Downloads
    cd /tmp || { echo "Failed to change directory to ~/Downloads"; exit 1; }

    # Pobranie pliku z bibliotekami Arduino
    sudo wget -q https://github.com/PMKrol/classprep/raw/main/arduino-libraries.zip -O arduino-libraries.zip && echo "[$MODULE_NAME] Arduino libraries wget ok"

    # Rozpakowanie pliku z bibliotekami
    sudo 7z x arduino-libraries.zip -aoa -bso0 -bsp0
    echo "[$MODULE_NAME] Unzipped Arduino libraries."
    
    sudo mkdir -p /home/student/Arduino/libraries/

    # Kopiowanie bibliotek Arduino do odpowiedniego katalogu
    sudo cp -r libraries/* /home/student/Arduino/libraries/
    echo "[$MODULE_NAME] Copied Arduino libraries."

    # Pobranie pliku Dodatek.txt z GitHub
    sudo wget -q https://raw.githubusercontent.com/PMKrol/classprep/refs/heads/main/Dodatek.txt -O /home/student/Desktop/Dodatek.txt
    echo "[$MODULE_NAME] Copied Dodatek.txt to Pulpit."

    # Zabezpieczenie plików przed modyfikacją (ustawienie uprawnień tylko do odczytu)
    #chmod -R 444 /home/student/Arduino/libraries/
    #chmod 444 /home/student/Desktop/Dodatek.txt
    sudo chattr +i /home/student/Desktop/Dodatek.txt
    sudo chattr -R +i /home/student/Arduino/libraries/
    echo "[$MODULE_NAME] Set read-only permissions for Arduino libraries and Dodatek.txt."

    # Zmiana właściciela plików na użytkownika 'san'
    #chown -R san:san /home/student/Arduino/libraries/
    #chown san:san /home/student/Desktop/Dodatek.txt
    #echo "[$MODULE_NAME] Changed ownership of libraries and Dodatek.txt to 'san'."
    
    # Usunięcie rozpakowanych plików
    sudo rm -rf libraries/
    sudo rm arduino-libraries.zip

    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling..."
    
    
    echo "[$MODULE_NAME] Removing RO attributes."
    sudo chattr -i /home/student/Desktop/Dodatek.txt
    sudo chattr -R -i /home/student/Arduino/libraries/

    # Usunięcie bibliotek Arduino
    sudo rm -rf /home/student/Arduino/libraries/*
    echo "[$MODULE_NAME] Removed Arduino libraries."

    # Usunięcie pliku Dodatek.txt
    sudo rm /home/student/Desktop/Dodatek.txt
    echo "[$MODULE_NAME] Removed Dodatek.txt from Pulpit."

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
