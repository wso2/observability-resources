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
      path    => $path,
      unless  => 'fluent-bit --version | grep "Fluent Bit"',
    }
  }

  file { 'create fluentbit directory':
    path   => $fluentbit_dir,
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${fluentbit_dir}/logs":
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

  file { "${fluentbit_dir}/wso2-integration-parsers.conf":
    ensure  => file,
    content => template('fluentbit/wso2-integration-parsers.conf.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

  file { "${fluentbit_dir}/fluent-bit-wrapper.sh":
    ensure  => file,
    content => template('fluentbit/fluent-bit-wrapper.sh.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

if $os == 'Debian' {

  file { 'copy_fluentbit_service':
    path    => "${systemctl_path}/wso2-fluentbit.service",
    ensure  => file,
    content => template('fluentbit/wso2-fluentbit.service.erb'),
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0755',
  }

  service { 'wso2-fluentbit.service':
    ensure     => running,
    enable     => true,
    require    => [
      File['copy_fluentbit_service'],
    ],
  }
} elsif $os == 'Darwin' {
  exec { 'run_fluent-bit':
    command     => "${shell} ${fluentbit_dir}/fluent-bit-wrapper.sh",
    path        => $facts['path'],
    unless      => "ps aux | grep '[f]luent-bit -c ${config_path}'",
    logoutput   => true,
  }
}
}
