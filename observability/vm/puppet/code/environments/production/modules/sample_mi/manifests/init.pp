class sample_mi inherits sample_mi::params {

  # package { 'openjdk-17-jdk':
  #   ensure => installed,
  # }

  file { 'creae_mi_base_dir':
    path   => "${deployment_dir}/mi",
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  archive { 'extract_mi_product_archive_from_puppet':
    path         => "${deployment_dir}/temp/wso2mi-${mi_version}.zip",
    ensure       => present,
    source       => "puppet:///modules/sample_mi/wso2mi-${mi_version}.zip",
    extract      => true,
    extract_path => "${deployment_dir}/mi",
    creates      => $mi_dir,
    cleanup      => true,
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

  exec { 'run_mi':
    command     => "nohup /bin/sh ${mi_dir}/bin/micro-integrator.sh > ${mi_dir}/repository/logs/console.log 2>&1 &",
    path        => $facts['path'],
  }

  # exec { 'run_mi':
  #   command   => "nohup ${shell} ${mi_dir}/bin/micro-integrator.sh > ${mi_dir}/repository/logs/console.log 2>&1 &",
  #   path      => $facts['path'],
  #   user      => $deploy_user,
  #   environment => ["JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.0.2.jdk/Contents/Home"],
  #   cwd       => $mi_dir,
  #   logoutput=> true,
  # }

}
