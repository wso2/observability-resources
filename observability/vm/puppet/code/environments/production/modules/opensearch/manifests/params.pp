class opensearch::params inherits o11y_common::params {

  # JDK Distributions
  $java_dir = "/opt"
  $java_symlink = "${java_dir}/java"
  # $jdk_name = 'amazon-corretto-17.0.6.10.1-linux-x64'
  $java_home = "${java_dir}/${jdk_name}"

  $deployment_mode = 'single_node'
  $opensearch_host = 'localhost'
  $opensearch_version = '2.15.0'
  $opensearch_download_url = "https://artifacts.opensearch.org/releases/bundle/opensearch/${opensearch_version}/opensearch-${opensearch_version}-linux-${cpu}.tar.gz"
  $opensearch_dir = "${deployment_dir}/opensearch/opensearch-${opensearch_version}"
  $opensearch_admin_password = 'Observer_123'
}
