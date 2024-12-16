class sample_mi inherits sample_mi::params {

  include common
  include common::java

if $os == "Debian" {
  package { 'unzip':
    ensure   => installed,
  }
}

  file { 'creae_mi_base_dir':
    path   => "${deployment_dir}/mi",
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { 'get_mi_zip':
    path    => "${deployment_dir}/mi/wso2mi-${mi_version}.zip",
    ensure  => file,
    source  => "puppet:///modules/sample_mi/wso2mi-${mi_version}.zip",
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { "unpack_mi_zip":
    command => "unzip ${deployment_dir}/mi/wso2mi-${mi_version}.zip",
    path    => $path,
    cwd     => "${deployment_dir}/mi",
    creates => "${deployment_dir}/mi/wso2mi-${mi_version}",
    user    => $deploy_user,
  }

  file { 'copy the metrics handler':
    path   => "${mi_dir}/lib/mimetrics-${mimetrics_version}.jar",
    ensure => file,
    source => "puppet:///modules/sample_mi/mimetrics-${mimetrics_version}.jar",
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0644',
  }

  file { "${mi_dir}/conf/log4j2.properties":
    ensure  => file,
    content => template('sample_mi/log4j2.properties.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

  file { "${mi_dir}/conf/deployment.toml":
    ensure  => file,
    content => template('sample_mi/deployment.toml.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

  file { 'deploy_bookpark_capp':
    path   => "${mi_dir}/repository/deployment/server/carbonapps/bookpark_${bookpark_version}.car",
    ensure => file,
    source => "puppet:///modules/sample_mi/bookpark_${bookpark_version}.car",
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0644',
  }

if $os == 'Debian' {

  file { 'copy_mi_service':
    path    => "${systemctl_path}/wso2-mi.service",
    ensure  => file,
    content => template('sample_mi/wso2-mi.service.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  service { 'wso2-mi.service':
    ensure     => running,
    enable     => true,
    require    => [
      File['copy_mi_service'],
    ],
  }
} elsif $os == 'Darwin' {

  exec { 'run_mi':
    command     => "nohup /bin/sh ${mi_dir}/bin/micro-integrator.sh > ${mi_dir}/repository/logs/console.log 2>&1 &",
    path        => $facts['path'],
  }
}

}
