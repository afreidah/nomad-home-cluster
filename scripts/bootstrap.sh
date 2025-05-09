#!/bin/bash

set -e

# Constants
NOMAD_VERSION="1.8.0"
CONSUL_VERSION="1.17.1"
ARCH="arm64"  # Use "arm" if not on 64-bit OS
USER="pi"      # Or whatever your primary user is

# Ensure necessary tools are available
sudo apt-get update && sudo apt-get install -y \
  unzip curl wget jq gnupg lsb-release systemd

# Create needed directories
sudo mkdir -p /opt/nomad /opt/consul /etc/nomad.d /etc/consul.d
sudo chown -R ${USER}:${USER} /opt/nomad /opt/consul /etc/nomad.d /etc/consul.d

# Install Nomad
wget -q https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCH}.zip
unzip nomad_${NOMAD_VERSION}_linux_${ARCH}.zip
sudo mv nomad /usr/local/bin/
rm nomad_${NOMAD_VERSION}_linux_${ARCH}.zip

# Install Consul
wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${ARCH}.zip
unzip consul_${CONSUL_VERSION}_linux_${ARCH}.zip
sudo mv consul /usr/local/bin/
rm consul_${CONSUL_VERSION}_linux_${ARCH}.zip

# Nomad config
cat <<EOF | sudo tee /etc/nomad.d/nomad.hcl
bind_addr = "0.0.0.0"
data_dir = "/opt/nomad"

advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}

server {
  enabled = true
  bootstrap_expect = 1
  raft_multiplier = 2
}

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

plugin "docker" {
  config {
    allow_privileged = true
    volumes_enabled = true
  }
}

consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  client_auto_join = true
}
EOF

# Consul config
cat <<EOF | sudo tee /etc/consul.d/consul.hcl
server = true
bootstrap_expect = 1
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
ui_config {
  enabled = true
}
connect {
  enabled = true
}
recursors = ["8.8.8.8"]
EOF

# Consul systemd unit
cat <<EOF | sudo tee /etc/systemd/system/consul.service
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Nomad systemd unit
cat <<EOF | sudo tee /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Start and enable services
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl enable nomad
sudo systemctl start consul
sleep 3
sudo systemctl start nomad

echo "\nNomad and Consul are installed and running."
echo "Nomad UI:    http://<RPI-IP>:4646"
echo "Consul UI:   http://<RPI-IP>:8500"
