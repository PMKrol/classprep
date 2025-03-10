#!/bin/bash

# ClassPrep: Main installation and configuration script

set -e

MODULES_DIR="/etc/classprep/modules"
GITHUB_REPO="https://github.com/PMKrol/classprep.git"

# Function to update the system
update_system() {
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y
}

# Function to install required dependencies
install_dependencies() {
    echo "Installing required packages..."
    sudo apt install -y git curl vim python3 python3-pip
}

# Function to set up the student and san environments
setup_environment() {
    echo "Configuring environment..."

    # Ensure the modules directory exists
    sudo mkdir -p "$MODULES_DIR" /opt/classprep

    # Create the 'student' user (if it does not exist)
    if id "student" &>/dev/null; then
        echo "User 'student' already exists."
    else
        sudo useradd -m student -s /bin/bash
        echo "student:student" | sudo chpasswd
        echo "Created user 'student' with default password."
    fi

    # Ścieżka do katalogu /home/student
    home_dir="/home/student"
    
    # Sprawdzamy, czy istnieją katalogi Desktop i Downloads
    if [ -d "$home_dir/Desktop" ] && [ -d "$home_dir/Downloads" ]; then
        echo "Katalogi Desktop i Downloads już istnieją. Nic nie robię."
    else
        # Jeśli nie istnieją, sprawdzamy katalogi Pulpit i Pobrane
        if [ -d "$home_dir/Pulpit" ]; then
            echo "Tworzę dowiązanie do katalogu Pulpit"
            ln -s "$home_dir/Pulpit" "$home_dir/Desktop"
        fi
        if [ -d "$home_dir/Pobrane" ]; then
            echo "Tworzę dowiązanie do katalogu Pobrane"
            ln -s "$home_dir/Pobrane" "$home_dir/Downloads"
        fi
    fi

    # Create the 'san' user (if it does not exist)
    if id "san" &>/dev/null; then
        echo "User 'san' already exists."
    else
        sudo useradd -m san -s /bin/bash
        echo "Podaj hasło dla użytkownika 'san':"
        read -s password
        echo "san:$password" | sudo chpasswd
        echo "Utworzono użytkownika 'san' z podanym hasłem."
    fi

    # Add 'san' to the sudo group
    if groups san | grep -q '\bsudo\b'; then
        echo "'san' already has sudo privileges."
    else
        echo "Granting 'san' sudo privileges..."
        sudo usermod -aG sudo san
    fi

    # Remove 'student' from the sudo group (if they are in it)
    if groups student | grep -q '\bsudo\b'; then
        echo "Removing 'student' from sudo group..."
        sudo deluser student sudo
    else
        echo "'student' does not have sudo privileges."
    fi
    
    sudo chown san:san /opt/classprep

    echo "Environment configured!"
}

# Function to fetch the latest modules from GitHub
fetch_modules() {
    echo "Fetching latest modules..."
    sudo mkdir -p "$MODULES_DIR"

    TEMP_DIR=$(mktemp -d)
    sudo git clone --depth=1 "$GITHUB_REPO" "$TEMP_DIR"

    # Move only the contents of the 'modules' directory
    if [[ -d "$TEMP_DIR/modules" ]]; then
        sudo mv "$TEMP_DIR/modules/"* "$MODULES_DIR/"
    fi

    # Cleanup temporary directory
    sudo rm -rf "$TEMP_DIR"

    echo "Modules fetched successfully."
        
    # List installed modules
    echo "Installed modules:"
    ls -lh "$MODULES_DIR"
}

# Function to install the latest version of all local modules
install_modules() {
    echo "Installing latest versions of local modules..."
    
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo "Module directory not found. Please fetch modules first."
        exit 1
    fi

    # Extract unique module names, including those without versions
    module_names=$(find "$MODULES_DIR" -type f -name "*.sh" | sed -E 's|.*/([^/]+)-[0-9]+\.[0-9]+\.sh$|\1|' | sed -E 's|.*/([^/]+)\.sh$|\1|' | sort -u)

    if [[ -z "$module_names" ]]; then
        echo "No modules found in $MODULES_DIR"
        exit 1
    fi

    # Create directory for storing installed module versions
    INSTALLED_MODULES_DIR="/etc/classprep/installed_modules"
    sudo mkdir -p "$INSTALLED_MODULES_DIR"

    for module in $module_names; do
        # Find versioned files for this module
        versioned_files=$(ls "$MODULES_DIR/$module"-*.sh 2>/dev/null)

        if [[ -z "$versioned_files" ]]; then
            echo "No versioned files found for module: $module"
            continue
        fi

        # Find the latest version by sorting the versioned files
        latest_version=$(echo "$versioned_files" | sort -V | tail -n 1)

        if [[ -n "$latest_version" ]]; then
            # Extract version (X.Y) from the filename
            version=$(echo "$latest_version" | sed -E 's|.*/([^/]+)-([0-9]+\.[0-9]+)\.sh$|\2|')

            # Check if the module has already been installed
            installed_version_file="$INSTALLED_MODULES_DIR/$module"
            if [[ -f "$installed_version_file" ]]; then
                installed_version=$(cat "$installed_version_file")
                
                # Compare versions (X.Y)
                if [[ "$installed_version" == "$version" ]]; then
                    echo "Module $module is already up to date (version $version). Skipping installation."
                    continue
                elif [[ "$installed_version" < "$version" ]]; then
                    echo "Module $module has an older version ($installed_version). Uninstalling old version and installing new one."

                    # Identify the old version file
                    old_version_file=$(echo "$versioned_files" | grep -E "([0-9]+\.[0-9]+)" | sort -V | head -n 1)

                    if [[ -n "$old_version_file" ]]; then
                        echo "Uninstalling old version ($installed_version) using $old_version_file"
                        
                        # Run uninstall for the old version using the identified file
                        sudo chmod +x "$old_version_file"
                        sudo "$old_version_file" uninstall
                    else
                        echo "No old version found to uninstall for module: $module"
                    fi
                fi
            fi

            # Installing the new version (pass install argument)
            echo "Installing module: $latest_version"
            sudo chmod +x "$latest_version"
            sudo "$latest_version" install

            # Save the installed version
            echo "$version" | sudo tee "$INSTALLED_MODULES_DIR/$module" > /dev/null
            echo "Installed version $version for module $module."
        else
            echo "No valid versions found for module: $module"
        fi
    done

    echo "All available modules installed."
}

# Function to install classprep.sh
install_classprep() {
    echo "Installing ClassPrep..."
    local script_url="https://raw.githubusercontent.com/PMKrol/classprep/main/classprep.sh"
    local script_path="/usr/local/bin/classprep.sh"

    # Download script
    if sudo curl -fsSL "$script_url" -o "$script_path"; then
        sudo chmod +x "$script_path"
        echo "ClassPrep installed successfully in $script_path"
    else
        echo "Failed to download ClassPrep."
        exit 1
    fi
}

# Function to run SMART long test and monitor progress
run_smart_test() {
    local disk="/dev/sda"

    echo "Starting SMART long test on $disk..."
    sudo smartctl -t long "$disk"

    echo "Monitoring SMART test progress..."
    while true; do
        progress=$(sudo smartctl -a "$disk" | grep "Self-test execution status" | awk -F'[()%]' '{gsub(/ /, "", $2); print $2}')
        
        if [[ "$progress" == "0" ]]; then
            break
        fi
        
        echo "Test in progress... (Status: $progress)"
        sleep 5  # Sprawdzaj co 60 sekund
    done

    sudo smartctl -a $disk

    echo "SMART test completed. Press Enter to shut down."
    read -r
    shutdown -h now
}

# Main menu
main_menu() {
    echo "==================================="
    echo " ClassPrep - Installation Script"
    echo "==================================="
    echo "1. Update system"
    echo "2. Install dependencies"
    echo "3. Configure admin account"
    echo "4. Fetch latest modules"
    echo "5. Install all local modules"
    echo "6. Install ClassPrep & Run SMART Test"
    echo "7. Run all steps"
    echo "8. Exit"
    echo "==================================="

    read -p "Select an option: " option
    case $option in
        1) update_system ;;
        2) install_dependencies ;;
        3) setup_environment ;;
        4) fetch_modules ;;
        5) install_modules ;;
        6) install_classprep && run_smart_test ;;
        7) setup_environment && update_system && install_dependencies && fetch_modules && install_modules && install_classprep && run_smart_test ;;
        8) exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac
}

# Check if the script is called with an argument
if [[ -n "$1" ]]; then
    case $1 in
        1) update_system ;;
        2) install_dependencies ;;
        3) setup_environment ;;
        4) fetch_modules ;;
        5) install_modules ;;
        6) install_classprep && run_smart_test ;;
        7) setup_environment && update_system && install_dependencies && fetch_modules && install_modules && install_classprep && run_smart_test ;;
        8) exit 0 ;;
        *) echo "Invalid argument! Please provide a valid option number." ;;
    esac
else
    main_menu
fi
