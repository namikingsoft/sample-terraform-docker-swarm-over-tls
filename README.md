Build docker swarm cluster using Terraform
==============================
This is sample build docker swarm cluster over TLS using Terraform on DigitalOcean.

Refs: [TLS認証なDocker Swarmクラスタを構築 (docker-machineなしで)](http://blog.namiking.net/post/2016/01/docker-swarm-build-using-tls/)

Get Started
------------------------------

#### setting
```sh
cp terraform.tfvars.sample terraform.tfvars
vi terraform.tfvars
```

#### plan and apply
```sh
terraform plan
terraform apply
```
it output tls keys to `keys` directory.

#### e.g.
```sh
docker --tlsverify \
  --tlscacert=keys/ca.pem \
  --tlscert=keys/cert.pem \
  --tlskey=keys/key.pem \
  -H=(ipv4_address of first host):3376 \
  info
```
or
```sh
export DOCKER_TLS_VERIFY="1"
export DOCKER_CERT_PATH="/path/to/keys"
export DOCKER_HOST="(ipv4_address of first host):3376"

docker info
```


License
------------------------------
[MIT](./LICENSE)
