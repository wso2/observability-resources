# Class: fluentbit
class fluentbit inherits fluentbit::params {

  if $os == 'Linux' {
    exec { 'install fluent-bit':
      command => 'apt install -y fluent-bit',
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      unless  => 'fluent-bit --version | grep "Fluent Bit"',
    }
  }

  # exec { 'install_fluentbit':
  #   command => 'brew install fluent-bit@3.1.10',
  #   path    => ['/usr/local/bin', '/usr/bin', '/bin'],
  #   require => Exec['brew_tap_fluentbit'],
  #   unless  => '/usr/local/bin/fluent-bit --version | grep "Fluent Bit v3.1.10"',
  # }

  file { "${deployment_dir}/fluentbit":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${deployment_dir}/fluentbit/logs":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $config_path:
    ensure  => file,
    content => template('fluentbit/fluent-bit.conf.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode    => '0644',
  }

  file { "${deployment_dir}/fluentbit/wso2-integration-parsers.conf":
    ensure  => file,
    content => template('fluentbit/wso2-integration-parsers.conf.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

  file { "${deployment_dir}/fluentbit/fluent-bit-wrapper.sh":
    ensure  => file,
    content => template('fluentbit/fluent-bit-wrapper.sh.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  exec { 'run_fluent-bit':
    command     => "${shell} ${deployment_dir}/fluentbit/fluent-bit-wrapper.sh",
    path        => $facts['path'],
    unless      => "ps aux | grep '[f]luent-bit -c ${config_path}'",
    logoutput   => true,
  }
}
