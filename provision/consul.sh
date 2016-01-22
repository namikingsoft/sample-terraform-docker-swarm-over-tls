#!/bin/bash -e

# arguments
ID=$1
MASTER_IP=$2
MY_PRIVATE_IP=$(
  ip addr show eth1 \
  | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' \
  | head -n1
)

# package
apt-get install -y curl zip

# install
cd /tmp
curl -LO https://releases.hashicorp.com/consul/0.6.1/consul_0.6.1_linux_amd64.zip
unzip consul_0.6.1_linux_amd64.zip -d /usr/local/bin
curl -LO https://releases.hashicorp.com/consul/0.6.1/consul_0.6.1_web_ui.zip
mkdir -p /var/local/consul
unzip consul_0.6.1_web_ui.zip -d /var/local/consul/webui

# service
cat << EOS > /lib/systemd/system/consul.service
[Unit]
Description=consul agent
After=network-online.target

[Service]
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
Type=simple
Restart=always

[Install]
WantedBy=multi-user.target
EOS

# setting
mkdir -p /etc/consul.d
if [ "$ID" = "0" ]; then
cat << EOS > /etc/consul.d/config.json
{
  "server": true,
  "bootstrap": true,
  "bind_addr": "$MY_PRIVATE_IP",
  "node_name": "swarm-node$ID",
  "datacenter": "swarm0",
  "ui_dir": "/var/local/consul/webui",
  "data_dir": "/var/local/consul/data",
  "log_level": "INFO",
  "enable_syslog": true
}
EOS
else
cat << EOS > /etc/consul.d/config.json
{
  "server": false,
  "start_join": ["$MASTER_IP"],
  "bind_addr": "$MY_PRIVATE_IP",
  "node_name": "swarm-node$ID",
  "datacenter": "swarm0",
  "ui_dir": "/var/local/consul/webui",
  "data_dir": "/var/local/consul/data",
  "log_level": "INFO",
  "enable_syslog": true
}
EOS
fi

# start
systemctl enable consul
systemctl start consul
