#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_message() {
    echo "======================================"
    echo "$1"
    echo "======================================"
}

# Get the current user
CURRENT_USER=$(whoami)

# Define the files directory
FILES_DIR="../../files"

# Check if FILES_DIR exists
if [ ! -d "$FILES_DIR" ]; then
    echo "Error: Directory $FILES_DIR does not exist."
    exit 1
fi

# 1. Install OpenJDK 17 from tar.gz
install_openjdk() {
    print_message "Installing OpenJDK 17"

    # Find the OpenJDK tar.gz file
    JDK_TAR=$(find "$FILES_DIR" -maxdepth 1 -type f -name "openjdk-17*.tar.gz" | head -n 1)

    if [ -z "$JDK_TAR" ]; then
        echo "Error: OpenJDK 17 tar.gz file not found in $FILES_DIR."
        exit 1
    fi

    # Define installation directory
    INSTALL_DIR="/usr/lib/jvm"

    # Create the installation directory if it doesn't exist
    sudo mkdir -p "$INSTALL_DIR"

    # Extract the tar.gz file
    sudo tar -xzf "$JDK_TAR" -C "$INSTALL_DIR"

    # Find the extracted folder
    EXTRACTED_DIR=$(tar -tzf "$JDK_TAR" | head -1 | cut -f1 -d"/")
    JDK_PATH="$INSTALL_DIR/$EXTRACTED_DIR"

    # Set JAVA_HOME and update PATH
    sudo update-alternatives --install /usr/bin/java java "$JDK_PATH/bin/java" 1
    sudo update-alternatives --set java "$JDK_PATH/bin/java"

    sudo update-alternatives --install /usr/bin/javac javac "$JDK_PATH/bin/javac" 1
    sudo update-alternatives --set javac "$JDK_PATH/bin/javac"

    # Verify installation
    java -version
}

# 2. Install Maven
install_maven() {
    print_message "Installing Maven"

    # Update package index
    sudo apt-get update

    # Install Maven
    sudo apt-get install -y maven

    # Verify installation
    mvn -version
}

# 3. Install Ballerina from .deb
install_ballerina() {
    print_message "Installing Ballerina"

    # Find the Ballerina .deb file
    BALLERINA_DEB=$(find "$FILES_DIR" -maxdepth 1 -type f -name "ballerina*.deb" | head -n 1)

    if [ -z "$BALLERINA_DEB" ]; then
        echo "Error: Ballerina .deb file not found in $FILES_DIR."
        exit 1
    fi

    # Install the .deb package
    sudo dpkg -i "$BALLERINA_DEB"

    # Fix dependencies if any
    sudo apt-get install -f -y

    # Verify installation
    ballerina version
}

# Execute the functions
install_openjdk
install_maven
install_ballerina

print_message "Host is prepared for executing puppet successfully!"
