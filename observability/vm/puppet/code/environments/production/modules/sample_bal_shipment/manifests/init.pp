class sample_bal_shipment inherits sample_bal_shipment::params {

  # package { 'openjdk-17-jdk':
  #   ensure => installed,
  # }

  file { $samples_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $sales_app_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { $sales_app_logs_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${sales_app_dir}/shipments.jar":
    ensure  => file,
    source  => 'puppet:///modules/sample_bal_shipment/shipments.jar',
    owner   => $deploy_user,
    group   => $deploy_group,
    mode    => '0644',
  }

  exec { 'run_bal_sales_sample':
    command   => "nohup java -jar ${sales_app_dir}/shipments.jar > ${sales_app_logs_dir}/app.log 2>&1 &",
    path      => ['/bin', '/usr/bin'],
  }

}
