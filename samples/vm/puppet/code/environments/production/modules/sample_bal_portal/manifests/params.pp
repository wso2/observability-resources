class sample_bal_portal::params inherits common::params {
  $samples_dir = "${deployment_dir}/bal_apps"
  $app_dir = "${samples_dir}/portal"
  $app_logs_dir = "${app_dir}/logs"

  $shipment_service = 'localhost:9101'
  $crm_service = 'localhost:9102'
  $inventory_service = 'localhost:9103'
  $bookpark_service = 'localhost:8290'
}
