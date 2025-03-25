#!/bin/bash
MODULE_NAME="stress"

# Ścieżka do archiwum
ZIP_URL="https://github.com/PMKrol/classprep/raw/refs/heads/main/GpuTest.zip"
TEMP_ZIP="/tmp/GpuTest.zip"
BIN_PATH="/bin"

function install() {
    echo "[$MODULE_NAME] Installing stress/test stuff..."

    # Instalacja pakietów
    sudo apt install stress memtester lm-sensors -y

    # Pobranie i wypakowanie GpuTest
    echo "[$MODULE_NAME] Downloading GpuTest..."
    wget -q "$ZIP_URL" -O "$TEMP_ZIP"

    if [[ -f "$TEMP_ZIP" ]]; then
        echo "[$MODULE_NAME] Extracting GpuTest..."
        sudo unzip -o "$TEMP_ZIP" GpuTest libgxl3d_r_linux.so -d "$BIN_PATH"
        sudo chmod +x "$BIN_PATH/GpuTest"
        rm -f "$TEMP_ZIP"
        echo "[$MODULE_NAME] GpuTest installed successfully!"
    else
        echo "[$MODULE_NAME] Failed to download GpuTest!" >&2
        exit 1
    fi
}

function uninstall() {
    echo "[$MODULE_NAME] Uninstalling..."
    
    # Usunięcie pakietów
    #sudo apt remove --purge stress memtester -y

    # Usunięcie plików GpuTest
    echo "[$MODULE_NAME] Removing GpuTest files..."
    sudo rm -f "$BIN_PATH/GpuTest" "$BIN_PATH/libgxl3d_r_linux.so"
    
    echo "[$MODULE_NAME] Uninstallation complete."
}

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
