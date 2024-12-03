class data_prepper::params inherits o11y_common::params {
  # Define the desired Docker Compose version
  $docker_compose_version = 'v2.29.5'  # Update to the desired version

  # Define the download URL for Docker Compose
  $docker_compose_download_url = "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)"

  # Define the installation path
  $docker_compose_install_path = '/usr/local/bin/docker-compose'

  $otel_trace_port = 4317
  $opensearch_host = 'host.docker.internal'
  $opensearch_username = 'admin'
  $opensearch_password = 'Observer_123'

  $data_prepper_dir = "${deployment_dir}/data-prepper"
}
