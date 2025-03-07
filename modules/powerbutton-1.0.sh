#!/bin/bash
MODULE_NAME="powerbutton"

function install() {
    echo "[$MODULE_NAME] Configuring power button to shut down the system..."

    # Ustawienie, aby komputer się wyłączał po naciśnięciu przycisku zasilania
    sudo sh -c 'echo "HandlePowerKey=poweroff" >> /etc/systemd/logind.conf'
    sudo systemctl restart systemd-logind
    echo "[$MODULE_NAME] Power button configured to shut down the system."
}

function uninstall() {
    echo "[$MODULE_NAME] Reverting power button configuration..."

    # Przywrócenie domyślnego działania przycisku zasilania (np. hibernacja lub inne)
    sudo sed -i '/HandlePowerKey=poweroff/d' /etc/systemd/logind.conf
    sudo systemctl restart systemd-logind
    echo "[$MODULE_NAME] Power button action reverted."
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
