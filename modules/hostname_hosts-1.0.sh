#!/bin/bash
MODULE_NAME="hostname_hosts"

function configure() {
    echo "[$MODULE_NAME] Configuring /etc/hostname and /etc/hosts."

    # Edytowanie /etc/hostname
    echo "Enter new hostname: "
    read new_hostname
    echo $new_hostname | sudo tee /etc/hostname > /dev/null
    echo "[$MODULE_NAME] /etc/hostname configured."

    # Edytowanie /etc/hosts
    echo "Updating /etc/hosts with new hostname..."
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts
    echo "[$MODULE_NAME] /etc/hosts updated."

    echo "[$MODULE_NAME] Configuration completed."
}

function revert() {
    echo "[$MODULE_NAME] Reverting configuration..."

    # Revert /etc/hostname to default
    echo "Reverting /etc/hostname to default..."
    sudo echo "localhost" | sudo tee /etc/hostname > /dev/null

    # Revert /etc/hosts to default
    echo "Reverting /etc/hosts..."
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\tlocalhost/" /etc/hosts

    echo "[$MODULE_NAME] Reversion completed."
}

case "$1" in
    install) configure ;;
    uninstall) revert ;;
    *)
        echo "Usage: $0 {configure|revert}"
        exit 1
        ;;
esac
