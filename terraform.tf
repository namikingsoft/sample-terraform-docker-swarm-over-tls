variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "template_file" "dummy" {
  template = "dummy"

  provisioner "local-exec" {
    command = "provision/tlsgen-base.sh"
  }
}

resource "digitalocean_droplet" "node" {
  image = "ubuntu-15-10-x64"
  name = "swarm-node${count.index}"
  region = "sgp1"
  size = "512mb"
  count = 2
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  connection {
    user = "root"
    type = "ssh"
    key_file = "${var.pvt_key}"
    timeout = "2m"
  }
  provisioner "local-exec" {
    command = "echo ${template_file.dummy.rendered} > /dev/null"
  }
  provisioner "local-exec" {
    command = "provision/tlsgen-node.sh ${self.ipv4_address}"
  }
  provisioner "file" {
    source = "provision/consul.sh"
    destination = "/tmp/consul.sh"
  }
  provisioner "file" {
    source = "provision/docker.sh"
    destination = "/tmp/docker.sh"
  }
  provisioner "file" {
    source = "keys/ca.pem"
    destination = "/tmp/ca.pem"
  }
  provisioner "file" {
    source = "keys/${self.ipv4_address}/server-cert.pem"
    destination = "/tmp/server-cert.pem"
  }
  provisioner "file" {
    source = "keys/${self.ipv4_address}/server-key.pem"
    destination = "/tmp/server-key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/consul.sh",
      "/tmp/consul.sh ${count.index } ${digitalocean_droplet.node.0.ipv4_address_private}",
      "chmod +x /tmp/docker.sh",
      "/tmp/docker.sh ${count.index} ${self.ipv4_address}"
    ]
  }
}
