class opensearch inherits opensearch::params {

  include o11y_common
  include o11y_common::java

  file { "${deployment_dir}/opensearch":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${deployment_dir}/opensearch/logs":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

if $pack_location == "local" {
  file { 'get_opensearch_tarball':
    path    => "${deployment_dir}/opensearch/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    ensure  => file,
    source  => "puppet:///modules/opensearch/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { "unpack_opensearch_tarball":
    command => "tar -zxvf ${deployment_dir}/opensearch/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    path    => $path,
    cwd     => "${deployment_dir}/opensearch",
    user    => $deploy_user,
    onlyif  => "test ! -d ${opensearch_dir}",
  }

  # file { 'remove_opensearch_tarball':
  #   path      => "${deployment_dir}/opensearch/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
  #   ensure    => absent,
  #   owner     => $deploy_user,
  #   group     => $deploy_group,
  #   subscribe => Exec["unpack_opensearch_tarball"],
  # }
} elsif $pack_location == "remote" {
  notify { 'Remote mode not supported.': }
}

  file { 'copy_install_script':
    path    => "${opensearch_dir}/opensearch-tar-install.sh",
    ensure  => file,
    content => template('opensearch/opensearch-tar-install.sh.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { 'install_opensearch':
    command     => "${shell} ${opensearch_dir}/opensearch-tar-install.sh",
    path        => ['/bin', '/usr/bin'],
    environment => ["OPENSEARCH_INITIAL_ADMIN_PASSWORD=${opensearch_admin_password}"],
    user        => $deploy_user,
    subscribe   => File['copy_install_script'],
    refreshonly => true,
  }

  file { "${opensearch_dir}/config/opensearch.yml":
    ensure  => file,
    content => template('opensearch/opensearch.yml.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

if $os == 'Debian' {

  file { 'copy_opensearch_service':
    path    => "${systemctl_path}/opensearch.service",
    ensure  => file,
    content => template('opensearch/opensearch.service.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  service { 'opensearch.service':
    ensure     => running,
    enable     => true,
    require    => [
      File['copy_opensearch_service'],
    ],
  }
} elsif $os == 'Darwin' {

  exec { 'run_opensearch':
    command     => "nohup ${opensearch_dir}/bin/opensearch > ${deployment_dir}/opensearch/logs/opensearch.log 2>&1 &",
    path        => ['/bin', '/usr/bin'],
    environment => ["OPENSEARCH_INITIAL_ADMIN_PASSWORD=${opensearch_admin_password}"],
    user        => $deploy_user,
    unless      => "pgrep -f \"opensearch.path.home=${opensearch_dir}\"",
  }
}

}
