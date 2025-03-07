#!/bin/bash
MODULE_NAME="Veyon_setup"

function install() {
    echo "[$MODULE_NAME] Starting installation process..."

    # Instalacja veyon-service
    sudo apt install veyon-service -y
    echo "[$MODULE_NAME] Installed veyon-service."

    # Włączenie veyon.service
    sudo systemctl enable veyon.service
    echo "[$MODULE_NAME] Enabled veyon.service."

    # Pobranie pliku konfiguracyjnego Veyon.conf z GitHub
    sudo wget "https://raw.githubusercontent.com/PMKrol/classprep/refs/heads/main/Veyon.conf" -O /etc/xdg/Veyon\ Solutions/Veyon.conf
    echo "[$MODULE_NAME] Downloaded Veyon.conf to /etc/xdg/Veyon Solutions/."

    # Restartowanie usługi veyon
    sudo service veyon restart
    echo "[$MODULE_NAME] Restarted veyon service."

    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling..."

    # Wyłączenie veyon.service
    sudo systemctl disable veyon.service
    echo "[$MODULE_NAME] Disabled veyon.service."

    # Usunięcie veyon-service
    sudo apt remove veyon-service -y
    echo "[$MODULE_NAME] Removed veyon-service."

    # Usunięcie pliku konfiguracyjnego Veyon.conf
    sudo rm -f /etc/xdg/Veyon\ Solutions/Veyon.conf
    echo "[$MODULE_NAME] Removed Veyon.conf."

    # Zatrzymanie usługi veyon
    sudo service veyon stop
    echo "[$MODULE_NAME] Stopped veyon service."

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
