#!/bin/bash
MODULE_NAME="disable-wifi-settings"

PKLA_FILE="disable-network-control.pkla"
PKLA_PATH="/etc/polkit-1/localauthority/50-local.d/$PKLA_FILE"

function install() {
    echo "[$MODULE_NAME] Disabling Wi-Fi settings access..."
    
    sudo mkdir -p "$(dirname "$PKLA_FILE")"

    # Tworzenie pliku .pkla z odpowiednimi uprawnieniami
    cat <<EOF | sudo tee "$PKLA_FILE" > /dev/null
[Wifi management]
Identity=unix-user:*
Action=org.freedesktop.NetworkManager.settings.*
ResultAny=no
ResultInactive=no
ResultActive=no

[Wifi sysad management]
Identity=unix-group:sudo;unix-user:root
Action=org.freedesktop.NetworkManager.settings.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

    # Przeniesienie pliku na właściwe miejsce
    sudo mv "$PKLA_FILE" "$PKLA_PATH"

    echo "[$MODULE_NAME] Wi-Fi settings access disabled."
}

function uninstall() {
    echo "[$MODULE_NAME] Restoring Wi-Fi settings access..."
    
    # Usunięcie pliku konfiguracyjnego
    if [[ -f "$PKLA_PATH" ]]; then
        sudo rm "$PKLA_PATH"
        echo "[$MODULE_NAME] Wi-Fi settings access restored."
    else
        echo "[$MODULE_NAME] No configuration file found to remove."
    fi
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
