class sample_bal_shipments inherits sample_bal_shipments::params {

  include common
  include common::java

  file { $samples_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $shipment_app_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $shipment_app_logs_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file {'copy_Config.toml':
    path   => "${shipment_app_dir}/Config.toml",
    ensure => file,
    content => template('sample_bal_shipments/Config.toml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0644',
  }

  file { "${shipment_app_dir}/shipments.jar":
    ensure  => file,
    source  => 'puppet:///modules/sample_bal_shipments/shipments.jar',
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

if $os == 'Darwin' {
  exec { 'run_bal_sales_sample':
    command     => "nohup java -jar ${shipment_app_dir}/shipments.jar > ${shipment_app_logs_dir}/app.log 2>&1 &",
    path        => ['/bin', '/usr/bin'],
    environment => ["BAL_CONFIG_FILES=${shipment_app_dir}/Config.toml"],
  }
}
}
