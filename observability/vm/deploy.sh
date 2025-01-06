#!/bin/bash

OS_TYPE=$(uname)
ARCH=$(uname -m)
FILES_DIR="../../files"
PUPPET_RELEASE="puppet8-release-noble.deb"
JAVA_DOWNLOAD_URL="https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz"
OPENSEARCH_DOWNLOAD_URL="https://artifacts.opensearch.org/releases/bundle/opensearch/2.15.0/opensearch-2.15.0-linux-x64.tar.gz"
if [ $ARCH == "arm64" ]; then
    OPENSEARCH_DOWNLOAD_URL='https://artifacts.opensearch.org/releases/bundle/opensearch/2.15.0/opensearch-2.15.0-linux-arm64.tar.gz'
fi
OPENSEARCH_DASHBOARDS_DOWNLOAD_URL="https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.15.0/opensearch-dashboards-2.15.0-linux-x64.tar.gz"
if [ $ARCH == "arm64" ]; then
    OPENSEARCH_DASHBOARDS_DOWNLOAD_URL='https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.15.0/opensearch-dashboards-2.15.0-linux-arm64.tar.gz'
fi

print() {
    echo "====== $1 ======"
}

if [ $# -eq 0 ]; then
    print "Usage:"
    echo "sudo -E sh deploy.sh opensearch: Install Opensearch."
    echo "sudo -E sh deploy.sh opensearch-dashboards: Install Opensearch Dashboards."
    echo "sudo -E sh deploy.sh fluentbit: Install Fluent Bit."
    echo "sudo -E sh deploy.sh data-prepper: Install Data Prepper."
    echo "sudo -E sh deploy.sh local: Deploy the complete observability solution locally."
    exit 1
fi

install_puppet() {
    if command -v puppet >/dev/null 2>&1; then
        print "Puppet is installed."
        return 0
    fi

    if [ "$OS_TYPE" == "Darwin" ]; then
        print "Please install Puppet agent."
        exit 1
    fi

    cd $FILES_DIR
    wget https://apt.puppet.com/${PUPPET_RELEASE}
    sudo dpkg -i ${PUPPET_RELEASE}
    sudo apt-get update
    sudo apt-get install puppet-agent
    cd - > /dev/null
    cd /usr/bin
    sudo ln -s /opt/puppetlabs/bin/puppet puppet
    cd - > /dev/null
    echo "Puppet installed successfully."
}

if [ "$1" == "local" ]; then
    if [ $OS_TYPE != "Darwin" ]; then
        if [ ! -f "$FILES_DIR"/openjdk-17*.tar.gz ]; then
            echo "Downloading OpenJDK 17..."
            wget $JAVA_DOWNLOAD_URL -P $FILES_DIR
        fi
        cp "$FILES_DIR"/openjdk-17*.tar.gz puppet/code/environments/production/modules/o11y_common/files/

        install_puppet
        cd puppet/code
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
        puppet module install puppetlabs-docker --version 10.0.1 --modulepath /opt/puppetlabs/puppet/modules/
    fi

    if [ ! -f "$FILES_DIR"/opensearch-2.*.tar.gz ]; then
        print "Downloading Opensearch..."
        wget $OPENSEARCH_DOWNLOAD_URL -P $FILES_DIR
    fi
    cp "$FILES_DIR"/opensearch-2.*.tar.gz puppet/code/environments/production/modules/opensearch/files/

    if [ ! -f "$FILES_DIR"/opensearch-dashboards-2.*.tar.gz ]; then
        echo "Downloading Opensearch Dashboards..."
        wget $OPENSEARCH_DASHBOARDS_DOWNLOAD_URL -P $FILES_DIR
    fi
    cp "$FILES_DIR"/opensearch-dashboards-2.*.tar.gz puppet/code/environments/production/modules/opensearch_dashboards/files/

    print "Installing Opensearch..."
    export FACTER_profile=opensearch
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

    print "Installing Opensearch Dashboards..."
    export FACTER_profile=opensearch_dashboards
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

    print "Installing Fluent Bit..."
    export FACTER_profile=fluentbit
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

    print "Installing Data Prepper..."
    export FACTER_profile=data_prepper
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

    echo "Observability solution deployed successfully."

elif [ "$1" == "opensearch" ]; then

    if [ $OS_TYPE != "Darwin" ]; then
        if [ ! -f "$FILES_DIR"/openjdk-17*.tar.gz ]; then
            wget $JAVA_DOWNLOAD_URL -P $FILES_DIR
        fi
        cp "$FILES_DIR"/openjdk-17*.tar.gz puppet/code/environments/production/modules/o11y_common/files/

        install_puppet
        cd puppet/code
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
    fi

    if [ ! -f "$FILES_DIR"/opensearch-2.*.tar.gz ]; then
        wget $OPENSEARCH_DOWNLOAD_URL -P $FILES_DIR
    fi
    cp "$FILES_DIR"/opensearch-2.*.tar.gz puppet/code/environments/production/modules/opensearch/files/

    export FACTER_profile=opensearch
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp
    echo "Opensearch deployed successfully."

elif [ "$1" == "opensearch-dashboards" ]; then

    if [ $OS_TYPE != "Darwin" ]; then
        install_puppet
        cd puppet/code
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
    fi

    if [ ! -f "$FILES_DIR"/opensearch-dashboards-2.*.tar.gz ]; then
        wget $OPENSEARCH_DASHBOARDS_DOWNLOAD_URL -P $FILES_DIR
    fi
    cp "$FILES_DIR"/opensearch_dashboards-2.*.tar.gz puppet/code/environments/production/modules/opensearch_dashboards/files/

    export FACTER_profile=opensearch_dashboards
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp
    echo "Opensearch Dashboards deployed successfully."

elif [ "$1" == "fluentbit" ]; then

    if [ $OS_TYPE != "Darwin" ]; then
        install_puppet
        cd puppet/code
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
    fi
    
    export FACTER_profile=fluentbit
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp
    echo "Fluent Bit deployed successfully."
    
elif [ "$1" == "data-prepper" ]; then

    if [ $OS_TYPE != "Darwin" ]; then
        install_puppet
        cd puppet/code
        puppet module install puppetlabs-apt --version 9.4.0 --modulepath /opt/puppetlabs/puppet/modules/
        puppet module install puppetlabs-docker --version 10.0.1 --modulepath /opt/puppetlabs/puppet/modules/
    fi
    
    export FACTER_profile=data_prepper
    puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp
    print "Data Prepper deployed successfully."
        
else
    print "Invalid option. Please refer the usage."
fi
