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

    cp target/bookpark-*.car puppet/code/environments/production/modules/sample_mi/files

    # Copy the metrics logging handler to the MI pupper location. (This is a temporary workaround)
    cd - > /dev/null
    cd ../deployment/integration-demo/extensions/metrics-handler/source || exit
    mvn clean package
    cd - > /dev/null
    cp deployment/integration-demo/extensions/metrics-handler/source/target/mimetrics-*.jar puppet/code/environments/production/modules/sample_mi/files
    
    # Navigate back to the initial directory
    cd - > /dev/null
}

# Build the Ballerina projects
for project in "${BAL_PROJECTS[@]}"; do
    build_project $project
done

# Build the MI project
build_mi_project "$MI_BOOKPARK"

echo "All projects built and installed successfully."
