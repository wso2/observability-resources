class sample_mi::params inherits common::params {
  $mi_version = "4.4.0"
  $mimetrics_version = "1.0.0"
  $bookpark_version = "1.0.3"

  $mi_dir = "${deployment_dir}/mi/wso2mi-${mi_version}"

  $trace_log_enabled = false
}
