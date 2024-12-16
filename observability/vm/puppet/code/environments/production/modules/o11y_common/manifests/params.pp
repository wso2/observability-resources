class o11y_common::params {
  $os = $facts['os']['family']
  $cpu_fact = $facts['os']['architecture']
  if $cpu_fact == 'amd64' {
    $cpu = 'x64'
  } else {
    $cpu = $cpu_fact
  }
  $shell = '/bin/sh'
  $path = $facts['path']
  $pack_location = 'local'

  $o11y_tracing = true

if $os == 'Darwin' {
  $user_id = $facts['identity']['uid']
  $user_group_id = $facts['identity']['gid']
  $deploy_user = $facts['identity']['user']
  $deploy_group = $facts['identity']['group']
  $deployment_dir = "/Users/${deploy_user}/wso2_observability"
  $darwin_home = "/Users/${deploy_user}"
  $demo = true
} elsif $os == 'Debian' {
  $user_id = 802
  $user_group_id = 802
  $deployment_dir = '/opt/wso2-observability'
  $deploy_user = 'wso2carbon'
  $deploy_group = 'wso2'
  $demo = true
}
  $systemctl_path = '/etc/systemd/system'

  # JDK Distributions
  $java_dir = "/opt"
  $java_symlink = "/usr/bin/java"
  $jdk_name = 'openjdk-17.0.2_linux-x64_bin'
  # $jdk_name = 'amazon-corretto-17.0.6.10.1-linux-x64'
  $java_home = "${java_dir}/jdk-17.0.2"
}
