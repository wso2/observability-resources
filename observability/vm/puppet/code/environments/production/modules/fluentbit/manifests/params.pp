class fluentbit::params inherits o11y_common::params {
  $fluentbit_version = '3.1.10'
  $config_path = "${deployment_dir}/fluentbit/wso2-integration.conf"

  $opensearch_host = 'localhost'
  $opensearch_port = 9200
  $opensearch_user = 'admin'
  $opensearch_password = 'Observer_123'

  $bal_logs_path = "${deployment_dir}/bal_apps/shipment/logs/app.logs"

  $mi_version = "4.3.0"
  $mi_logs_path = "${deployment_dir}/mi/wso2mi-${mi_version}/repository/logs"
  $mi_app_logs_path = "${mi_logs_path}/wso2carbon.log"
  $mi_metrics_logs_path = "${mi_logs_path}/metrics.log"
}
