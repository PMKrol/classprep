#!/bin/bash
MODULE_NAME="screensaver_config"

function install() {
    echo "[$MODULE_NAME] Installing configuration..."

    # Wyłączenie autolocka w kscreensaverrc
    kwriteconfig5 --file kscreensaverrc --group Daemon --key Autolock false
    echo "[$MODULE_NAME] Autolock disabled in kscreensaverrc."

    # Wyłączenie wymagania hasła po wznowieniu po wygaszeniu ekranu
    kwriteconfig5 --file ~/.kde/share/config/kscreenlockerrc --group 'Daemon' --key 'LockOnResume' 'false'
    echo "[$MODULE_NAME] Password prompt after screen lock disabled."

    # Wyłączenie automatycznego blokowania ekranu w systemie
    kwriteconfig5 --file ~/.kde/share/config/kwinrc --group 'Windows' --key 'ScreenSaverActive' 'false'
    echo "[$MODULE_NAME] Screen saver and lock disabled."

    # Maskowanie celów sleep i suspend, aby zapobiec usypianiu
    sudo systemctl mask sleep.target suspend.target
    echo "[$MODULE_NAME] Sleep and suspend targets masked."

    echo "[$MODULE_NAME] Installation completed."
}

function uninstall() {
    echo "[$MODULE_NAME] Reverting configuration..."

    # Przywracanie domyślnego ustawienia Autolock
    kwriteconfig5 --file kscreensaverrc --group Daemon --key Autolock true
    echo "[$MODULE_NAME] Autolock re-enabled in kscreensaverrc."

    # Przywrócenie wymagania hasła po wygaszeniu ekranu
    kwriteconfig5 --file ~/.kde/share/config/kscreenlockerrc --group 'Daemon' --key 'LockOnResume' 'true'
    echo "[$MODULE_NAME] Password prompt after screen lock re-enabled."

    # Przywrócenie ustawienia blokowania ekranu
    kwriteconfig5 --file ~/.kde/share/config/kwinrc --group 'Windows' --key 'ScreenSaverActive' 'true'
    echo "[$MODULE_NAME] Screen saver and lock re-enabled."

    # Odmaskowanie celów sleep i suspend
    sudo systemctl unmask sleep.target suspend.target
    echo "[$MODULE_NAME] Sleep and suspend targets unmasked."

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
