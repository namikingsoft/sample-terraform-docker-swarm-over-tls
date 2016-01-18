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

License
------------------------------
[MIT](./LICENSE)
