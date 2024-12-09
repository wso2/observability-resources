# Class: fluentbit
class fluentbit inherits fluentbit::params {

  include o11y_common

  if $os == 'Debian' {

    include apt

    # Add the custom APT repository
    apt::source { 'fluentbit_repo':
      ensure          => present,
      location        => "https://packages.fluentbit.io/ubuntu/${os_codename}",
      release         => $os_codename,
      repos           => 'main',
      key             => {
        'id'     => 'fluentbit-key',
        'source' => 'https://packages.fluentbit.io/fluentbit.key',
      },
    }

    # Ensure the APT package lists are updated
    exec { 'apt_update':
      command     => '/usr/bin/apt-get update',
      refreshonly => true,
      subscribe   => Apt::Source['fluentbit_repo'],
    }

    # Install the package from the custom repository
    package { 'fluent-bit':
      ensure  => present,
      require => Exec['apt_update'],
    }

    # file { 'copy_fluentbit_install_script':
    #   path    => "${fluentbit_dir}/ubuntu-install.sh",
    #   ensure  => file,
    #   content => template('fluentbit/ubuntu-install.sh.erb'),
    #   owner   => $deploy_user,
    #   group   => $deploy_group,
    #   mode    => '0644',
    # }

    # exec { 'install fluent-bit':
    #   command => "${shell} ${fluentbit_dir}/ubuntu-install.sh",
    #   path    => $path,
    #   user    => $deploy_user,
    #   # unless  => 'fluent-bit --version | grep "Fluent Bit"',
    # }

    file { '/usr/bin/fluent-bit':
      ensure  => "link",
      target  => '/opt/fluent-bit/bin/fluent-bit',
      require => Exec["install fluent-bit"],
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
