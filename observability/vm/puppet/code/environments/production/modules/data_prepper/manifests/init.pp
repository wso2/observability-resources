class data_prepper inherits data_prepper::params {

  include o11y_common

  if $o11y_tracing == false {
    return()
  }

  file { 'create data-prepper directory':
    path   => $data_prepper_dir,
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { "${data_prepper_dir}/logs":
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }

  file { 'data-prepper-pipelines':
    path    => "${data_prepper_dir}/pipelines.yaml",
    ensure  => file,
    content => template('data_prepper/pipelines.yaml.erb'),
    owner  => $deploy_user,
    group  => $deploy_group,
    force   => true,
    mode    => '0644',
  }

  # Ensure the Docker service is running
  class { 'docker':
  }

  # Ensure the Docker image is pulled
  docker::image { 'opensearchproject/data-prepper:latest':
    ensure => present,
  }

  # Run the Docker container
  docker::run { 'data-prepper-node':
    image         => 'opensearchproject/data-prepper:latest',
    ensure        => present,
    ports         => [
      "8021:8021",
      "${otel_trace_port}:${otel_trace_port}",
    ],
    volumes       => [
      "${data_prepper_dir}/pipelines.yaml:/usr/share/data-prepper/pipelines/pipelines.yaml",
    ],
    require       => [
      Docker::Image['opensearchproject/data-prepper:latest'],
    ],
    subscribe     => File['data-prepper-pipelines'],
  }
}
