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

    # Create the 'san' user (if it does not exist)
    if id "san" &>/dev/null; then
        echo "User 'san' already exists."
    else
        sudo useradd -m san -s /bin/bash
        echo "san:san" | sudo chpasswd
        echo "Created user 'san' with default password."
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
                    
                    # Uninstall the old version (run with uninstall argument)
                    echo "Running uninstall for old version ($installed_version) of module: $module"
                    sudo "$latest_version" uninstall
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
    echo "6. Run all steps"
    echo "7. Exit"
    echo "==================================="

    read -p "Select an option: " option
    case $option in
        1) update_system ;;
        2) install_dependencies ;;
        3) setup_environment ;;
        4) fetch_modules ;;
        5) install_modules ;;
        6) update_system && install_dependencies && setup_environment && fetch_modules && install_modules ;;
        7) exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac
}

# Run menu
main_menu
