class opensearch_dashboards::params inherits opensearch::params {
  $opensearch_dashboards_download_url = "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${opensearch_version}/opensearch-dashboards-${opensearch_version}-linux-${cpu}.tar.gz"
  $opensearch_dashboards_dir = "${deployment_dir}/opensearch-dashboards/opensearch-dashboards-${opensearch_version}"

  $opensearch_host = 'localhost'

  $node_version = '16.13.0'
  $node_cpu = "${os}-${cpu}"
  $nodejs_name = "node-v${node_version}-${node_cpu}"
  $node_download_url = "https://nodejs.org/dist/v${node_version}/${nodejs_name}.tar.gz"
  $node_download_dest = "/temp/node-v${node_version}-darwin-arm64.tar.gz"
}
