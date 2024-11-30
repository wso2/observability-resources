class opensearch inherits opensearch::params {

  /*
  * Java Distribution
  */

  # Copy JDK to Java distribution path
  if $pack_location == "local" {
    file { "jdk-distribution":
      path   => "${java_home}.tar.gz",
      source => "puppet:///modules/${module_name}/jdk/${jdk_name}.tar.gz",
      notify => Exec["unpack-jdk"],
    }
  }
  elsif $pack_location == "remote" {
    exec { "retrieve-jdk":
      command => "wget -q ${remote_jdk} -O ${java_home}.tar.gz",
      path    => "/usr/bin/",
      onlyif  => "/usr/bin/test ! -f ${java_home}.tar.gz",
      notify  => Exec["unpack-jdk"],
    }
  }

  # Unzip distribution
  exec { "unpack-jdk":
    command => "tar -zxvf ${java_home}.tar.gz",
    path    => "/bin/",
    cwd     => "${java_dir}",
    onlyif  => "/usr/bin/test ! -d ${java_home}",
  }

  # Create symlink to Java binary
  file { "${java_symlink}":
    ensure  => "link",
    target  => "${java_home}",
    require => Exec["unpack-jdk"]
  }

  /*
  * OpenSearch Distribution
  */

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

  archive { 'extract_opensearch_archive_from_puppet':
    path         => "${deployment_dir}/temp/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    ensure       => present,
    source       => "puppet:///modules/opensearch/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    extract      => true,
    extract_path => "${deployment_dir}/opensearch",
    creates      => $opensearch_dir,
    cleanup      => true,
  }

  archive { 'download_opensearch_if_not_available_in_puppet':
    path         => "${deployment_dir}/temp_http/opensearch-${opensearch_version}-linux-${cpu}.tar.gz",
    ensure       => present,
    source       => $opensearch_download_url,
    extract      => true,
    extract_path => "${deployment_dir}/opensearch",
    creates      => $opensearch_dir,
    cleanup      => true,
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
    environment => ["OPENSEARCH_INITIAL_ADMIN_PASSWORD=${admin_password}"],
    unless      => 'pgrep -f "opensearch --securityadmin"',
  }

  exec { 'run_opensearch':
    command     => "nohup ${opensearch_dir}/bin/opensearch > ${deployment_dir}/opensearch/logs/opensearch.log 2>&1 &",
    path        => ['/bin', '/usr/bin'],
    environment => ["OPENSEARCH_INITIAL_ADMIN_PASSWORD=${admin_password}"],
    unless      => "pgrep -f \"opensearch.path.home=${opensearch_dir}\"",
  }

}
