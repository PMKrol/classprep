#!/bin/bash

POLKIT_FILE="/etc/polkit-1/localauthority/50-local.d/nofurtherlogin.pkla"

install_policy() {
    echo "Creating PolicyKit rule to disable password prompts for power actions..."
    
    sudo mkdir -p "$(dirname "$POLKIT_FILE")"
    sudo tee "$POLKIT_FILE" > /dev/null << EOF
[Allow all users to shutdown]
Identity=unix-user:*
Action=org.freedesktop.login1.power-off-multiple-sessions
ResultAny=yes
ResultActive=yes

[Allow all users to reboot]
Identity=unix-user:*
Action=org.freedesktop.login1.reboot-multiple-sessions
ResultAny=yes
ResultActive=yes

[Allow all users to suspend]
Identity=unix-user:*
Action=org.freedesktop.login1.suspend-multiple-sessions
ResultAny=yes
ResultActive=yes

[Allow all users to ignore inhibit of shutdown]
Identity=unix-user:*
Action=org.freedesktop.login1.power-off-ignore-inhibit
ResultAny=yes
ResultActive=yes

[Allow all users to ignore inhibit of reboot]
Identity=unix-user:*
Action=org.freedesktop.login1.reboot-ignore-inhibit
ResultAny=yes
ResultActive=yes

[Allow all users to ignore inhibit of suspend]
Identity=unix-user:*
Action=org.freedesktop.login1.suspend-ignore-inhibit
ResultAny=yes
ResultActive=yes
EOF
    
    echo "Installation complete. Users can now shutdown, reboot, and suspend without password prompts."
}

uninstall_policy() {
    echo "Removing PolicyKit rule..."
    sudo rm -f "$POLKIT_FILE"
    echo "Uninstallation complete. Users will now require authentication for power actions."
}

case "$1" in
    install)
        install_policy
        ;;
    uninstall)
        uninstall_policy
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
