set -e

# arguments
ID=$1
IP=$2

# install docker
echo "Installing docker ..."
wget -qO- https://get.docker.com/ | sh

# setting docker
mv /tmp/ca.pem /etc/docker
mv /tmp/server-cert.pem /etc/docker
mv /tmp/server-key.pem /etc/docker
DOCKER_OPTS="--tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem -H=0.0.0.0:2376 --cluster-store=consul://localhost:8500 --cluster-advertise=eth0:2376"
sed -i "s;docker daemon;docker daemon ${DOCKER_OPTS};" \
  /lib/systemd/system/docker.service
systemctl daemon-reload
service docker restart

# swarm manager
if [ "$ID" = "0" ]; then
  docker run -d --name swarm-agent-master -v /etc/docker:/etc/docker --net host \
    swarm manage --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem -H tcp://0.0.0.0:3376 --strategy spread --advertise ${IP}:2376 consul://localhost:8500
fi

# swarm agent
docker run -d --name swarm-agent --net host \
  swarm join --advertise ${IP}:2376 consul://localhost:8500
