class opensearch_dashboards inherits opensearch_dashboards::params
{
  include o11y_common

  file { "${deployment_dir}/opensearch-dashboards":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${deployment_dir}/opensearch-dashboards/logs":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  archive { "${deployment_dir}/temp/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz":
    ensure       => present,
    source       => "puppet:///modules/opensearch_dashboards/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
    extract      => true,
    extract_path => "${deployment_dir}/opensearch-dashboards",
    creates      => $opensearch_dashboards_dir,
    cleanup      => true,
  }

  archive { 'download_opensearch_dashboards_if_not_available_in_puppet':
    path         => "${deployment_dir}/temp_http/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
    ensure       => present,
    source       => $opensearch_dashboards_download_url,
    extract      => true,
    extract_path => "${deployment_dir}/opensearch-dashboards",
    creates      => $opensearch_dashboards_dir,
    cleanup      => true,
  }

if $os == 'Darwin' {

  # install nodejs, if not already installed
  exec { 'install_node':
    command => 'brew install node',
    unless  => 'node --version',
    path    => $facts['path'],
  }

  # need to delete the pre-packed node folder to force the use of the os-specific installed node
  file { 'delete_builtin_node_folder':
    path    => "${opensearch_dashboards_dir}/node",
    ensure  => 'absent',
    recurse => false,
    force   => true,
  }
}

  exec { 'run_opensearch_dashboards':
    command     => "nohup ${opensearch_dashboards_dir}/bin/opensearch-dashboards > ${deployment_dir}/opensearch-dashboards/logs/opensearch-dashboards.log 2>&1 &",
    path        => $facts['path'],
    unless      => "pgrep -f \"${opensearch_dashboards_dir}\"",
  }

  file { "${deployment_dir}/opensearch-dashboards/wso2":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { 'copy_install_script':
    path    => "${deployment_dir}/opensearch-dashboards/wso2/import_wso2_integration_dashboards.sh",
    ensure  => file,
    content => template('opensearch_dashboards/import_wso2_integration_dashboards.sh.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  file { 'copy_inregration_app_log_template':
    path    => "${deployment_dir}/opensearch-dashboards/wso2/wso2-integration-app-index-template-request.json",
    ensure  => file,
    content => template('opensearch_dashboards/wso2-integration-app-index-template-request.json.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  file { 'copy_inregration_metrics_log_template':
    path    => "${deployment_dir}/opensearch-dashboards/wso2/wso2-integration-metrics-index-template-request.json",
    ensure  => file,
    content => template('opensearch_dashboards/wso2-integration-metrics-index-template-request.json.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  file { 'copy_inregration_dashboards':
    path    => "${deployment_dir}/opensearch-dashboards/wso2/wso2-integration-dashboards-vm.ndjson",
    ensure  => file,
    content => template('opensearch_dashboards/wso2-integration-dashboards-vm.ndjson.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { 'import_wso2_integration_dashboards':
    command     => "${shell} ${deployment_dir}/opensearch-dashboards/wso2/import_wso2_integration_dashboards.sh",
    path        => $facts['path'],
    logoutput   => true,
  }

}
