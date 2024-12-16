class sample_bal_crm inherits sample_bal_crm::params {

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
    content => template('sample_bal_crm/Config.toml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0644',
  }

  file { "${app_dir}/crm.jar":
    ensure  => file,
    source  => 'puppet:///modules/sample_bal_crm/crm.jar',
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

if $os == 'Darwin' {
  exec { 'run_bal_sales_sample':
    command     => "nohup java -jar ${app_dir}/crm.jar > ${app_logs_dir}/app.log 2>&1 &",
    path        => ['/bin', '/usr/bin'],
    environment => ["BAL_CONFIG_FILES=${app_dir}/Config.toml"],
  }
}
}
