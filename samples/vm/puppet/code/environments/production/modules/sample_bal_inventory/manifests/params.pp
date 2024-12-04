class sample_bal_inventory::params inherits common::params {
  $samples_dir = "${deployment_dir}/bal_apps"
  $app_dir = "${samples_dir}/inventory"
  $app_logs_dir = "${app_dir}/logs"

  $shipment_service = 'localhost:9101'
}
