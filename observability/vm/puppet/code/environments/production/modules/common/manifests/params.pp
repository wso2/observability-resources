class common::params {
  $os = $facts['os']['family']
  $cpu = $facts['os']['architecture']
  $shell = '/bin/sh'

  $deployment_dir = '/Users/chathura/work/programs/opensearch/envs/env4/deployment'
  $deploy_user = 'chathura'
  $deploy_group = 'admin'
  $demo = true
}
