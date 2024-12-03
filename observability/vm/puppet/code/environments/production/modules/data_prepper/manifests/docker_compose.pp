# docker_compose.pp

class docker_compose {

  # 1. Ensure that necessary packages are installed
  package { ['apt-transport-https', 'ca-certificates', 'curl', 'gnupg-agent', 'software-properties-common']:
    ensure => installed,
  }

  # 2. Add Docker’s official GPG key
  exec { 'add_docker_gpg_key':
    command => 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -',
    unless  => 'apt-key list | grep "Docker"',
    require => Package['curl'],
  }

  # 3. Add Docker APT repository
  exec { 'add_docker_repo':
    command => 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"',
    unless  => 'apt-cache policy | grep "download.docker.com"',
    require => Exec['add_docker_gpg_key'],
  }

  # 4. Update APT package index
  exec { 'apt_update':
    command     => 'apt-get update',
    refreshonly => true,
    subscribe   => Exec['add_docker_repo'],
  }

  # 5. Install Docker Engine
  package { 'docker-ce':
    ensure  => installed,
    require => Exec['apt_update'],
  }

  package { 'docker-ce-cli':
    ensure  => installed,
    require => Package['docker-ce'],
  }

  package { 'containerd.io':
    ensure  => installed,
    require => Package['docker-ce'],
  }

  # 6. Ensure Docker service is running and enabled
  service { 'docker':
    ensure    => running,
    enable    => true,
    require   => Package['docker-ce'],
  }

  # 7. Install Docker Compose
  # Download Docker Compose if it is not already installed
  exec { 'download_docker_compose':
    command => "/usr/bin/curl -L ${docker_compose_download_url} -o ${docker_compose_install_path}",
    creates => $docker_compose_install_path,
    require => Service['docker'],
  }

  # Ensure the Docker Compose binary is executable
  file { $docker_compose_install_path:
    ensure => 'file',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    require => Exec['download_docker_compose'],
  }

  # (Optional) Verify the installation
  exec { 'verify_docker_compose':
    command => "/usr/local/bin/docker-compose --version",
    unless  => "/usr/local/bin/docker-compose --version | grep ${docker_compose_version}",
    require => File[$docker_compose_install_path],
  }

}
