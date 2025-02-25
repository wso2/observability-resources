#!/bin/bash

CRM="../source/tmart/crm"
INVENTORY="../source/tmart/inventory"
SHIPMENT="../source/tmart/shipments"
PORTAL="../source/tmart/portal"
MI_BOOKPARK="../source/tomsbooks/bookpark"

docker pull --platform linux/amd64  ballerina/jvm-runtime:2.0
export DOCKER_BUILDKIT=0

build_project() {
    local project_path=$1
    
    echo "Building Ballerina project in $project_path"
    
    # Navigate to the project directory
    cd "$project_path" || exit
    
    # Run the Ballerina build command
    bal build --cloud=docker
    
    # Check if the build was successful
    if [ $? -eq 0 ]; then
        echo "Build successful for project: $project_path"
    else
        echo "Build failed for project: $project_path"
        exit 1
    fi
    
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
    mvn clean package -Pdocker
    
    # Check if the build was successful
    if [ $? -eq 0 ]; then
        echo "Maven build successful for project: $project_path"
    else
        echo "Maven build failed for project: $project_path"
        exit 1
    fi

    # Copy the metrics logging handler to the MI image. (This is a temporary workaround)
    # cd - > /dev/null
    # cd ../source/extensions/metrics-handler/source || exit
    # mvn clean package
    # cd - > /dev/null
    # cp ../source/extensions/metrics-handler/source/target/mimetrics-1.0.0.jar ../source/extensions/metrics-handler/docker
    # cd ../source/extensions/metrics-handler/docker || exit
    # export DOCKER_DEFAULT_PLATFORM=linux/amd64
    # docker build -t bookpark-m:1.0.3 .
    
    # Navigate back to the initial directory
    cd - > /dev/null
}

# Build the Ballerina projects
build_project "$CRM"
build_project "$INVENTORY"
build_project "$SHIPMENT"
build_project "$PORTAL"

# Build the MI project
build_mi_project "$MI_BOOKPARK"

# cd "deployment" || exit
helm uninstall integration-demo
helm upgrade --install integration-demo integration-demo
# helm upgrade --install apim-demo apim-demo/all-in-one

echo "All projects built and installed successfully."
