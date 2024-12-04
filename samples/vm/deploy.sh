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
    if command -v java >/dev/null 2>&1; then
        echo "Java is already installed."
        return 0
    fi

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
    if command -v mvn >/dev/null 2>&1; then
        echo "Maven is already installed."
        return 0
    fi

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
    if command -v bal >/dev/null 2>&1; then
        echo "Ballerina is already installed."
        return 0
    fi

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

if [ "$1" == "prepare" ]; then
    if [ -f /etc/debian_version ]; then
        install_openjdk
        install_maven
        install_ballerina
    fi
fi

#!/bin/bash

BAL_PROJECTS=("crm" "inventory" "shipments" "portal")
MI_BOOKPARK="../tomsbooks/bookpark"

build_project() {
    local project_name=$1
    local project_path="../tmart/$project_name"
    local puppet_path="$(pwd)/puppet/code/environments/production/modules/sample_bal_$project_name/files"
    
    echo "Building Ballerina project in $project_path"

    # Navigate to the project directory
    cd "$project_path" || exit    
    
    # Run the Ballerina build command
    bal build
    
    # Check if the build was successful
    if [ $? -eq 0 ]; then
        echo "Build successful for project: $project_path"
    else
        echo "Build failed for project: $project_path"
        exit 1
    fi

    cp target/bin/$project_name.jar $puppet_path
    
    # Navigate back to the initial directory
    cd - > /dev/null
}

# Function to build the MI project
build_mi_project() {
    local project_path=$1
    
    echo "Building MI project in $project_path"
    
    # Navigate to the Maven project directory
    cd "$project_path" || exit
    
    # Run the Maven build command
    mvn clean package
    
    # Check if the build was successful
    if [ $? -eq 0 ]; then
        echo "Maven build successful for project: $project_path"
    else
        echo "Maven build failed for project: $project_path"
        exit 1
    fi

    cd - > /dev/null
    cp $project_path/target/bookpark_*.car puppet/code/environments/production/modules/sample_mi/files

    # Copy the metrics logging handler to the MI pupper location. (This is a temporary workaround)
    cd ../deployment/integration-demo/extensions/metrics-handler/source || exit
    mvn clean package
    cd - > /dev/null
    cp ../deployment/integration-demo/extensions/metrics-handler/source/target/mimetrics-*.jar puppet/code/environments/production/modules/sample_mi/files
    
    # Navigate back to the initial directory
    cd - > /dev/null
}

if [ "$1" == "prepare" ]; then
    # Build the Ballerina projects
    for project in "${BAL_PROJECTS[@]}"; do
        build_project $project
    done

    # Build the MI project
    build_mi_project "$MI_BOOKPARK"
    cd - > /dev/null
    cp ../../files/wso2mi-*.zip puppet/code/environments/production/modules/sample_mi/files

    print_message "Host is prepared for executing puppet."
fi

if [ "$1" == "local" ]; then
    print_message "Deploying samples locally..."
    cd puppet/code

    export FACTER_profile=sample_bal_shipments
    puppet apply --environmentpath=environments --environment=production -v environments/production/manifests/site.pp

    export FACTER_profile=sample_bal_inventory
    puppet apply --environmentpath=environments --environment=production -v environments/production/manifests/site.pp

    export FACTER_profile=sample_mi
    puppet apply --environmentpath=environments --environment=production -v environments/production/manifests/site.pp

    print_message "Samples deployed successfully!"
fi
