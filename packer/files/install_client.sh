#! /bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq puppet unzip wget jq webfs python3-pip > /dev/null

sudo puppet module install KyleAnderson-consul
sudo puppet module install reppard-envconsul
sudo puppet module install gdhbashton-consul_template

echo "Starting local web server for consul binary..."
sudo webfsd -r /tmp/ -p 8888

RETRY="provider=gce project_name=$2 tag_value=$3"

sudo puppet apply -e "class { '::consul':
  pretty_config      => true,
  install_method => 'url',
  download_url   => 'http://localhost:8888/consul.zip',
  service_ensure => 'stopped',
  service_enable => false,
  version        => '1.0.2-beta',
  config_hash => {
    'client_addr'      => '0.0.0.0',
    'data_dir'         => '/opt/consul',
    'datacenter'       => '$1',
    'log_level'        => 'INFO',
    'retry_join'       => [
      '$RETRY'
    ],
  }
}

class { 'envconsul':
  platform => 'linux',
  arch     => 'amd64',
}

include consul_template
"

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -qq puppet webfs > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq > /dev/null
echo "Finished!"
