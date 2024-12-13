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

if $os == 'Debian' {

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

} else {
  $docker_compose_installed = inline_template('<%=`which docker-compose 2>&1`.empty? ? false : true %>')
  if $docker_compose_installed == "true" {
    notify { 'Docker Compose found. Installing Data Pepper...': }

    file { 'docker_compose_file':
      path    => "${data_prepper_dir}/docker-compose.yml",
      ensure  => file,
      content => template('data_prepper/docker-compose.yml.erb'),
      owner  => $deploy_user,
      group  => $deploy_group,
      force   => true,
      mode    => '0644',
    }

    exec { 'run_data_prepper':
      command     => "docker-compose -f ${data_prepper_dir}/docker-compose.yml up -d",
      path        => $path,
      user        => $deploy_user,
      subscribe   => File['docker_compose_file'],
    }
  } else {
    notify { 'Docker Compose not found. Skipping Data Pepper installation. Tracing support will not be available.': }
    return()
  }
}
}
