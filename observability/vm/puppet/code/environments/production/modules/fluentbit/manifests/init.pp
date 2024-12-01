# Class: fluentbit
class fluentbit inherits fluentbit::params {

  include o11y_common

  if $os == 'Debian' {
    exec { 'install fluent-bit':
      command => 'apt install -y fluent-bit',
      path    => $path,
      unless  => 'fluent-bit --version | grep "Fluent Bit"',
    }
  }

  if $os == 'Darwin' {
    exec { 'install fluent-bit':
      command => 'brew install fluent-bit',
      path    => $facts['path'],
      unless  => 'fluent-bit --version | grep "Fluent Bit"',
    }
  }

  file { 'create fluentbit directory':
    path   => "${deployment_dir}/fluentbit",
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
