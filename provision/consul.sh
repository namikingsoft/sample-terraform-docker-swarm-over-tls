set -e

# arguments
ID=$1
MASTER_IP=$2

# workdir
cd /tmp

# install consul
apt-get install -y curl zip
curl -LO https://releases.hashicorp.com/consul/0.6.1/consul_0.6.1_linux_amd64.zip
unzip consul_0.6.1_linux_amd64.zip
mv consul /usr/local/bin
curl -LO https://releases.hashicorp.com/consul/0.6.1/consul_0.6.1_web_ui.zip
unzip consul_0.6.1_web_ui.zip -d consul-webui

# start consul
if [ "$ID" = "0" ]; then
  nohup consul agent \
    -server -bootstrap-expect=1 \
    -node=consul${ID} \
    -data-dir=/tmp/consul \
    --ui-dir=/tmp/consul-webui \
    -bind=$(
      ip addr show eth1 \
      | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' \
      | head -n1
    ) \
    >> /var/log/consul.log &
else
  nohup consul agent \
    -join $MASTER_IP \
    -node=consul${ID} \
    -data-dir=/tmp/consul \
    -bind=$(
      ip addr show eth1 \
      | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' \
      | head -n1
    ) \
    >> /var/log/consul.log &
fi
