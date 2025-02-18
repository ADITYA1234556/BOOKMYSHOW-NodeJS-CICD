#!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common
cd /tmp
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server --no-pager
# Grafana is now running on http://localhost:3000
# Default credentials are admin:admin