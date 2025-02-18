#!/bin/bash

# Create a Prometheus system user
sudo useradd --system --no-create-home --shell /bin/false prometheus

# Create required directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus
cd /tmp

# Download Prometheus
PROM_VERSION="2.47.1"
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Extract Prometheus files
tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
rm -rf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROM_VERSION}.linux-amd64/

# Move binaries to /usr/local/bin
sudo mv prometheus promtool /usr/local/bin/

# Move configuration files
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Set correct ownership
sudo chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/

# Create systemd service file
sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and enable Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check Prometheus status
sudo systemctl status prometheus --no-pager