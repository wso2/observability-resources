export FACTER_profile=opensearch
puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

export FACTER_profile=opensearch_dashboards
puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

export FACTER_profile=fluentbit
puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

export FACTER_profile=sample_bal_shipment
puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

export FACTER_profile=sample_mi
puppet apply --environmentpath=environments --environment=production environments/production/manifests/site.pp

