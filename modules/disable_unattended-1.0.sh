#!/bin/bash
MODULE_NAME="disable-unattended"

function install() {
    echo "[$MODULE_NAME] Disabling automatic upgrades..."

    # Copy the configuration file to disable automatic upgrades
    sudo cp /usr/share/unattended-upgrades/20auto-upgrades-disabled /etc/apt/apt.conf.d/

    echo "[$MODULE_NAME] Automatic upgrades have been disabled."
}

function uninstall() {
    echo "[$MODULE_NAME] Restoring automatic upgrades (removing the override)..."

    # Remove the override file
    sudo rm -f /etc/apt/apt.conf.d/20auto-upgrades-disabled

    echo "[$MODULE_NAME] Automatic upgrades configuration has been restored."
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
