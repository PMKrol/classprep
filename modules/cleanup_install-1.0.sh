#!/bin/bash

# Ensure the script runs as root, prompting for sudo password if needed
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please enter your password."
    exec sudo "$0" "$@"
fi

# Define paths
DESKTOP_DIR="/home/student/Pulpit"
UNORDERED_DIR="$DESKTOP_DIR/.unordered"
SCRIPT_PATH="/usr/local/bin/cleanup.sh"
SERVICE_FILE="/etc/systemd/system/cleanup.service"
LOG_FILE="/var/log/cleanup.log"

install_script() {
    echo "Creating the cleanup script..."

    cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash

DESKTOP_DIR="/home/student/Pulpit"
UNORDERED_DIR="$DESKTOP_DIR/.unordered"
LOG_FILE="/var/log/cleanup.log"

# Create the .unordered directory if it doesn't exist
if [ ! -d "$UNORDERED_DIR" ]; then
    mkdir "$UNORDERED_DIR"
    echo "$(date): Created .unordered directory" >> "$LOG_FILE"
fi

# Exception list (files/directories that should not be moved)
exceptions=(
    "Arduino IDE"
    "Note.txt"
    "UGS.sh"
    ".unordered"
    "*.desktop"
    "*.html"
    ".directory"
)

# Log process start
echo "$(date): Starting file cleanup" >> "$LOG_FILE"

# Function to check if a file or directory is an exception
is_exception() {
    local item="$1"
    for exception in "${exceptions[@]}"; do
        if [[ "$(basename "$item")" == $exception ]]; then
            return 0  # It's an exception
        fi
    done
    return 1  # Not an exception
}

# Move files and directories that are not exceptions
for item in "$DESKTOP_DIR"/*; do
    if [ -f "$item" ] && ! is_exception "$item"; then
        mv "$item" "$UNORDERED_DIR" && echo "$(date): Moved file \"$item\"" >> "$LOG_FILE"
    elif [ -d "$item" ] && ! is_exception "$item"; then
        mv "$item" "$UNORDERED_DIR" && echo "$(date): Moved directory \"$item\"" >> "$LOG_FILE"
    fi
done

# Log process completion
echo "$(date): Cleanup completed" >> "$LOG_FILE"
EOF

    # Set correct permissions
    chmod +x "$SCRIPT_PATH"

    echo "Creating systemd service..."

    cat << EOF > "$SERVICE_FILE"
[Unit]
Description=Cleanup script to organize the desktop before X starts
Before=display-manager.service

[Service]
ExecStart=/usr/local/bin/cleanup.sh
Type=oneshot
User=root
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd configuration
    systemctl daemon-reload

    # Enable the service
    systemctl enable cleanup.service

    echo "Installation complete. The script will run before X starts on every boot."
}

uninstall_script() {
    echo "Removing cleanup script and service..."

    systemctl disable cleanup.service
    rm -f "$SERVICE_FILE"
    rm -f "$SCRIPT_PATH"

    systemctl daemon-reload

    echo "Uninstallation complete."
}

case "$1" in
    install)
        install_script
        ;;
    uninstall)
        uninstall_script
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
