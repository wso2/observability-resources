class sample_bal_shipments::params inherits common::params {
  $samples_dir = "${deployment_dir}/bal_apps"
  $shipment_app_dir = "${samples_dir}/shipments"
  $shipment_app_logs_dir = "${shipment_app_dir}/logs"
}
