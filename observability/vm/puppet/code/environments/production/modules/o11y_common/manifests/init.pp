class o11y_common inherits o11y_common::params {

if $os == 'Debian' {
  group { $deploy_group:
    ensure => present,
    gid    => $user_group_id,
    system => true,
  }

  user { $deploy_user:
    ensure  => present,
    uid     => $user_id,
    gid     => $user_group_id,
    home    => "/home/${deploy_user}",
    system  => true,
    require => Group["${deploy_group}"]
  }
}

  file { $deployment_dir:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

}
