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

data "exoscale_compute_template" "template-one" {
  zone = local.default_zone
  name = local.default_template
}

resource "exoscale_compute_instance" "instance-one" {
  zone = local.default_zone
  name = "instance-one"

  template_id = data.exoscale_compute_template.template-one.id
  type        = local.default_type
  disk_size   = 10
  ipv6        = false
}
