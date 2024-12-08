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

if $pack_location == "local" {
  file { 'get_opensearch_dashboards_tarball':
    path    => "${deployment_dir}/opensearch-dashboards/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
    ensure  => file,
    source  => "puppet:///modules/opensearch_dashboards/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { "unpack_opensearch_dashboards_tarball":
    command => "tar -zxvf ${deployment_dir}/opensearch-dashboards/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
    path    => $path,
    cwd     => "${deployment_dir}/opensearch-dashboards",
    user    => $deploy_user,
    onlyif  => "test ! -d ${opensearch_dashboards_dir}",
  }

  # file { 'remove_opensearch_dashboards_tarball':
  #   path      => "${deployment_dir}/opensearch-dashboards/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz",
  #   ensure    => absent,
  #   owner     => $deploy_user,
  #   group     => $deploy_group,
  #   subscribe => Exec["unpack_opensearch_dashboards_tarball"],
  # }
} elsif $pack_location == "remote" {
  notify { 'Remote mode not supported.': }
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

if $os == 'Darwin' {
  exec { 'run_opensearch_dashboards':
    command     => "nohup ${opensearch_dashboards_dir}/bin/opensearch-dashboards > ${deployment_dir}/opensearch-dashboards/logs/opensearch-dashboards.log 2>&1 &",
    path        => $facts['path'],
    unless      => "pgrep -f \"${opensearch_dashboards_dir}\"",
  }
} elsif $os == 'Debian' {
  file { 'copy_opensearch_dashboards_service':
    path    => "${systemctl_path}/opensearch_dashboards.service",
    ensure  => file,
    content => template('opensearch_dashboards/opensearch_dashboards.service.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  service { 'opensearch_dashboards.service':
    ensure     => running,
    enable     => true,
    require    => [
      File['copy_opensearch_dashboards_service'],
    ],
  }
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
