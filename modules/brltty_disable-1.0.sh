#!/bin/bash
MODULE_NAME="brltty_disable"

function disable() {
    echo "[$MODULE_NAME] Disabling brltty services..."

    # Stop brltty-udev.service
    sudo systemctl stop brltty-udev.service
    echo "[$MODULE_NAME] brltty-udev.service stopped."

    # Mask brltty-udev.service
    sudo systemctl mask brltty-udev.service
    echo "[$MODULE_NAME] brltty-udev.service masked."

    # Stop brltty.service
    sudo systemctl stop brltty.service
    echo "[$MODULE_NAME] brltty.service stopped."

    # Disable brltty.service
    sudo systemctl disable brltty.service
    echo "[$MODULE_NAME] brltty.service disabled."

    echo "[$MODULE_NAME] brltty services have been disabled."
}

function enable() {
    echo "[$MODULE_NAME] Enabling brltty services..."

    # Unmask brltty-udev.service
    sudo systemctl unmask brltty-udev.service
    echo "[$MODULE_NAME] brltty-udev.service unmasked."

    # Start brltty-udev.service
    sudo systemctl start brltty-udev.service
    echo "[$MODULE_NAME] brltty-udev.service started."

    # Enable brltty.service
    sudo systemctl enable brltty.service
    echo "[$MODULE_NAME] brltty.service enabled."

    # Start brltty.service
    sudo systemctl start brltty.service
    echo "[$MODULE_NAME] brltty.service started."

    echo "[$MODULE_NAME] brltty services have been re-enabled."
}

case "$1" in
    install) disable ;;
    uninstall) enable ;;
    *)
        echo "Usage: $0 {disable|enable}"
        exit 1
        ;;
esac
