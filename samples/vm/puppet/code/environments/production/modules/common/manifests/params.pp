class common::params {
  $os = $facts['os']['family']
  $cpu = $facts['os']['architecture']
  $shell = '/bin/sh'

  $deployment_dir = '/Users/chathura/work/programs/opensearch/envs/env5/deployment'
  $deploy_user = 'chathura'
  $deploy_group = 'admin'
  $demo = true

  # JDK Distributions
  $java_dir = "/opt"
  $java_symlink = "${java_dir}/java"
  $jdk_name = 'amazon-corretto-17.0.6.10.1-linux-x64'
  $java_home = "${java_dir}/${jdk_name}"
  $pack_location = 'local'
}
