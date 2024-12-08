class data_prepper inherits data_prepper::params {

if $o11y_tracing == false {
  return()
}

if $os == 'Debian' {
  include docker_compose
}

  file { 'create data-prepper directory':
    path   => $data_prepper_dir,
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${data_prepper_dir}/logs":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${data_prepper_dir}/pipelines.yaml":
    ensure  => file,
    content => template('data_prepper/pipelines.yaml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode    => '0644',
  }

  file { "${data_prepper_dir}/docker-compose.yml":
    ensure  => file,
    content => template('data_prepper/docker-compose.yml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode    => '0644',
  }

  exec { 'run_data_prepper':
    command     => "nohup docker-compose up > logs/data_prepper.log 2>&1 &",
    cwd         => $data_prepper_dir,
    path        => $facts['path'],
    logoutput   => true,
  }
}
