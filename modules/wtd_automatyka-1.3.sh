#!/bin/bash
MODULE_NAME="wtd_automatyka"

function install() {
    echo "[$MODULE_NAME] Starting installation process..."

    # Ścieżka do katalogu Pobrane
    cd /home/student/Pobrane || { echo "Failed to change directory to ~/Pobrane"; exit 1; }

    # Pobranie pliku z bibliotekami Arduino
    wget -q https://github.com/PMKrol/classprep/raw/main/arduino-libraries.zip -O arduino-libraries.zip && echo "[$MODULE_NAME] Arduino libraries wget ok"

    # Rozpakowanie pliku z bibliotekami
    7z x arduino-libraries.zip -aoa -bso0 -bsp0
    echo "[$MODULE_NAME] Unzipped Arduino libraries."
    
    sudo mkdir -p /home/student/snap/arduino/current/Arduino/libraries/

    # Kopiowanie bibliotek Arduino do odpowiedniego katalogu
    sudo cp -r libraries/* /home/student/snap/arduino/current/Arduino/libraries/
    echo "[$MODULE_NAME] Copied Arduino libraries."

    # Pobranie pliku Dodatek.txt z GitHub
    wget -q https://raw.githubusercontent.com/PMKrol/classprep/refs/heads/main/Dodatek.txt -O /home/student/Pulpit/Dodatek.txt
    echo "[$MODULE_NAME] Copied Dodatek.txt to Pulpit."

    # Zabezpieczenie plików przed modyfikacją (ustawienie uprawnień tylko do odczytu)
    chmod -R 444 /home/student/snap/arduino/current/Arduino/libraries/
    chmod 444 /home/student/Pulpit/Dodatek.txt
    echo "[$MODULE_NAME] Set read-only permissions for Arduino libraries and Dodatek.txt."

    # Zmiana właściciela plików na użytkownika 'san'
    chown -R san:san /home/student/snap/arduino/current/Arduino/libraries/
    chown san:san /home/student/Pulpit/Dodatek.txt
    echo "[$MODULE_NAME] Changed ownership of libraries and Dodatek.txt to 'san'."

    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling..."

    # Usunięcie bibliotek Arduino
    rm -rf /home/student/snap/arduino/current/Arduino/libraries/*
    echo "[$MODULE_NAME] Removed Arduino libraries."

    # Usunięcie pliku Dodatek.txt
    rm /home/student/Pulpit/Dodatek.txt
    echo "[$MODULE_NAME] Removed Dodatek.txt from Pulpit."

    # Usunięcie rozpakowanych plików
    #rm -rf libraries/
    #rm arduino-libraries.zip

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
