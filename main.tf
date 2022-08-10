# The name of your instance must not contain '_'.
# Requirements for the name: up to 253 characters, must begin with a letter,
# end with a letter or a number, and contain only letters, digits and the `- .` chars.

provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

locals {
  default_zone     = "ch-gva-2"
  default_template = "Linux Ubuntu 22.04 LTS 64-bit"
  default_type     = "standard.micro"
}

data "exoscale_compute_template" "terraform-playground" {
  zone = local.default_zone
  name = local.default_template
}

resource "exoscale_compute_instance" "terraform-playground-instance" {
  zone = local.default_zone
  name = "terraform-playground-instance"

  template_id = data.exoscale_compute_template.terraform-playground.id
  type        = local.default_type
  disk_size   = 10

  ssh_key     = exoscale_ssh_key.terraform-playground-ssh-key.name

  security_group_ids = [
    exoscale_security_group.terraform-playground-ssh-security-group.id,
  ]


  provisioner "file" {
      source      = "scripts/docker"
      destination = "/tmp/docker"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/docker",
        "sudo /tmp/docker",
      ]
    }

    # Login to the ec2-user with the aws key.
    connection {
      type        = "ssh"
      user        = "ubuntu"
      password    = ""
      private_key = file("/Users/sig/.ssh/exoscale-playground")
      host        = exoscale_compute_instance.terraform-playground-instance.public_ip_address
    }
}

resource "exoscale_ssh_key" "terraform-playground-ssh-key" {
  name       = "terraform-playground-ssh-key"
  public_key = file("ssh_public_keys/exoscale-playground.pub")
}

# You may combine multiple rules in groups
# Which are assigned to instances

resource "exoscale_security_group" "terraform-playground-ssh-security-group" {
  name = "terraform-playground-ssh-security-group"
}

resource "exoscale_security_group_rule" "ssh_ipv4" {
  security_group_id = exoscale_security_group.terraform-playground-ssh-security-group.id
  description       = "SSH (IPv4)"
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 22
  end_port          = 22
  cidr              = "0.0.0.0/0"
}





output "ssh_connection" {
  value = format(
    "ssh -i ~/.ssh/exoscale-playground %s@%s",
    data.exoscale_compute_template.terraform-playground.username,
    exoscale_compute_instance.terraform-playground-instance.public_ip_address,
  )
}
