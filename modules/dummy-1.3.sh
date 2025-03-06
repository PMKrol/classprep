#!/bin/bash
MODULE_NAME="dummy"

function install() {
    echo "[$MODULE_NAME] Installing dummy."
    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling dummy..."
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
