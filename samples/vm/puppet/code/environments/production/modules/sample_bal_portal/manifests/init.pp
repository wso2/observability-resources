class sample_bal_portal inherits sample_bal_portal::params {

  include common
  include common::java

  file { $samples_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $app_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $app_logs_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file {'copy_Config.toml':
    path   => "${app_dir}/Config.toml",
    ensure => file,
    content => template('sample_bal_portal/Config.toml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0644',
  }

  file { "${app_dir}/portal.jar":
    ensure  => file,
    source  => 'puppet:///modules/sample_bal_portal/portal.jar',
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

if $os == 'Darwin' {
  exec { 'run_bal_sales_sample':
    command     => "nohup java -jar ${app_dir}/portal.jar > ${app_logs_dir}/app.log 2>&1 &",
    path        => ['/bin', '/usr/bin'],
    environment => ["BAL_CONFIG_FILES=${app_dir}/Config.toml"],
  }
}
}
