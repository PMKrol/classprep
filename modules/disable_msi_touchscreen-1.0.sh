#!/bin/bash
MODULE_NAME="disable-msi-touchscreen"

RULES_FILE="20-block-touchscreen-msi.rules"
RULES_PATH="/lib/udev/rules.d/$RULES_FILE"

function install() {
    echo "[$MODULE_NAME] Disabling MSI touchscreen..."

    # Tworzenie reguły udev
    cat <<EOF | sudo tee "$RULES_FILE" > /dev/null
# MSI Touchscreen disable, Quanta Computer, Inc. OpticalTouchScreen
SUBSYSTEM=="usb", ATTRS{idVendor}=="0408", ATTRS{idProduct}=="3008", ATTR{authorized}="0"
EOF

    # Przeniesienie pliku na właściwe miejsce
    sudo mv "$RULES_FILE" "$RULES_PATH"

    # Wymuszenie ponownego wczytania reguł udev
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo "[$MODULE_NAME] MSI touchscreen disabled."
}

function uninstall() {
    echo "[$MODULE_NAME] Restoring MSI touchscreen access..."
    
    # Usunięcie pliku reguł udev
    if [[ -f "$RULES_PATH" ]]; then
        sudo rm "$RULES_PATH"
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        echo "[$MODULE_NAME] MSI touchscreen access restored."
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
