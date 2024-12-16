class data_prepper::docker_compose inherits data_prepper::params {

  class { 'docker': }

  package { 'docker-compose-plugin':
      ensure  => present,
  }

  # # 6. Ensure Docker service is running and enabled
  # service { 'docker':
  #   ensure    => running,
  #   enable    => true,
  # }

  # # 7. Install Docker Compose
  # # Download Docker Compose if it is not already installed
  # exec { 'download_docker_compose':
  #   command => "/usr/bin/curl -L ${docker_compose_download_url} -o ${docker_compose_install_path}",
  #   creates => $docker_compose_install_path,
  #   require => Service['docker'],
  # }

  # # Ensure the Docker Compose binary is executable
  # file { $docker_compose_install_path:
  #   ensure => 'file',
  #   mode   => '0755',
  #   owner  => 'root',
  #   group  => 'root',
  #   require => Exec['download_docker_compose'],
  # }

  # # (Optional) Verify the installation
  # exec { 'verify_docker_compose':
  #   command => "/usr/local/bin/docker-compose --version",
  #   unless  => "/usr/local/bin/docker-compose --version | grep ${docker_compose_version}",
  #   require => File[$docker_compose_install_path],
  # }
}
