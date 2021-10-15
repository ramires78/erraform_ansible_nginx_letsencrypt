terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "1.22.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "digitalocean_ssh_key" "default" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = var.my_key
}

resource "digitalocean_tag" "erste_tag" {
  name = var.e-mail
}

resource "digitalocean_tag" "zweite_tag" {
  name = "devops"
}

resource "random_password" "my_passwords" {
  count   = length(var.dev)
  length  = 12
  lower   = true
  upper   = true
  number  = true
  special = true
}

### DO ###

resource "digitalocean_droplet" "lab-terr" {
  count              = length(var.dev)
  image              = "ubuntu-18-04-x64"
  name               = "${element(var.dev, count.index)}.devops.rebrain.srwx.net"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys           = [data.digitalocean_ssh_key.default.fingerprint, digitalocean_ssh_key.default.fingerprint]
  tags               = [digitalocean_tag.erste_tag.id, digitalocean_tag.zweite_tag.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update", "sudo apt install python3 -y", "echo Done!"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "/bin/echo -e \"${element(random_password.my_passwords.*.result, count.index)}\n${element(random_password.my_passwords.*.result, count.index)}\" | /usr/bin/passwd root"
    ]
  }
}

#### aws records ###

data "aws_route53_zone" "rebrain_zone" {
  name = "devops.rebrain.srwx.net"
}

resource "aws_route53_record" "a_records" {
  count   = length(var.dev)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "${element(var.dev, count.index)}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"
  records = [digitalocean_droplet.lab-terr.*.ipv4_address[count.index]]
  ttl     = "300"
}

resource "aws_route53_record" "www_a_records" {
  count   = length(var.dev)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "www.${element(var.dev, count.index)}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"

  alias {
    name                   = aws_route53_record.a_records.*.fqdn[count.index]
    zone_id                = data.aws_route53_zone.rebrain_zone.zone_id
    evaluate_target_health = true
  }
}

#### ansible ####

resource "local_file" "inventory" {
  filename        = "${path.module}/ansible/inventories/webservers/hosts.yml"
  file_permission = "0644"
  count           = length(var.dev)
  content = templatefile("${path.module}/templates/inventory.tpl", {
    index    = "${var.dev}"
    ip_addrs = digitalocean_droplet.lab-terr.*.ipv4_address
    names    = ["${element(var.dev, count.index)}"]
  })

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=${path.module}/ansible/ansible.cfg ansible-playbook ${path.module}/ansible/nginx.yml"
  }
}

### outputs resoults ip records pass ###

data "template_file" "templatefile_results" {
  template = file("${path.module}/templates/my_result.tpl")
  count    = length(var.dev)
  vars = {
    num           = count.index
    my_dns_name   = "${element(var.dev, count.index)}.${data.aws_route53_zone.rebrain_zone.name}"
    my_ip_address = "${element(digitalocean_droplet.lab-terr.*.ipv4_address, count.index)}"
    my_pass       = random_password.my_passwords.*.result[count.index]
  }
}

resource "local_file" "results" {
  content         = "NN;FQDN;IP-address;Password\n${replace(join(",", data.template_file.templatefile_results.*.rendered), ",", "")}"
  filename        = "${path.module}/outputs_result.csv"
  file_permission = "0660"
}

data "template_file" "templatefile_results_hosts" {
  template = file("${path.module}/templates/results.tpl")
  count    = length(var.dev)
  vars = {
    results_dns_name   = "${element(var.dev, count.index)}.${data.aws_route53_zone.rebrain_zone.name}"
    results_ip_address = "${element(digitalocean_droplet.lab-terr.*.ipv4_address, count.index)}"
  }
}
