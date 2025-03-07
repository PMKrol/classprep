#!/bin/bash

MODULE_NAME="smartcheck"

# Check if smartctl is installed
if ! command -v smartctl &> /dev/null; then
    echo "[$MODULE_NAME] smartctl is not installed. Installing..."
    sudo apt update
    sudo apt install smartmontools -y
fi

# Disk device, e.g. /dev/sda
DISK="/dev/sda"
LOG_FILE="/var/log/smart_test_result.log"

# Function to run a long SMART test
function run_smart_test() {
    echo "[$MODULE_NAME] Starting long SMART test on disk $DISK..."

    # Start the long SMART test
    sudo smartctl --test=long $DISK

    echo "[$MODULE_NAME] SMART test started. Please wait for completion."

    # Monitor the test status (checking every few seconds)
    while true; do
        # Read the test status from smartctl
        TEST_STATUS=$(sudo smartctl -a $DISK | grep -i "self-test execution status" | awk '{print $6}')
        
        if [[ "$TEST_STATUS" == "Completed" || "$TEST_STATUS" == "Interrupted" ]]; then
            echo "[$MODULE_NAME] SMART test completed. Status: $TEST_STATUS"
            break
        else
            echo "[$MODULE_NAME] SMART test in progress... ($TEST_STATUS)"
        fi
        # Delay before the next check
        sleep 5
    done

    # Save the result of the SMART test to the log file
    sudo smartctl -a $DISK | tee -a $LOG_FILE
    echo "[$MODULE_NAME] SMART test result has been saved to $LOG_FILE."
}

# Function to install the script (run the test)
function install() {
    #run_smart_test
    sudo smartctl --test=long $DISK
    echo "[$MODULE_NAME] SMART run without wait."

}

# Function to uninstall (no actual removal needed)
function uninstall() {
    echo "[$MODULE_NAME] Uninstallation is not required in this case."
    exit 0
}

# Check the provided arguments (install/uninstall)
case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
