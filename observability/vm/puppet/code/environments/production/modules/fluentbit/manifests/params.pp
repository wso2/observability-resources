class fluentbit::params inherits o11y_common::params {
  $fluentbit_version = '3.1.10'
  $fluentbit_dir = "${deployment_dir}/fluentbit"
  $config_path = "${fluentbit_dir}/wso2-integration.conf"

  $opensearch_host = 'localhost'
  $opensearch_port = 9200
  $opensearch_user = 'admin'
  $opensearch_password = 'Observer_123'

  $bal_logs_path = "${deployment_dir}/bal_apps/shipments/logs/app.log"
  $bal_log_paths = ["${deployment_dir}/bal_apps/shipments/logs/app.log", "${deployment_dir}/bal_apps/inventory/logs/app.log"]

  $mi_version = "4.3.0"
  $mi_logs_path = "${deployment_dir}/mi/wso2mi-${mi_version}/repository/logs"
  $mi_app_logs_path = "${mi_logs_path}/wso2carbon.log"
  $mi_metrics_logs_path = "${mi_logs_path}/metrics.log"

  $deployment_name = "deployment_1"
}
