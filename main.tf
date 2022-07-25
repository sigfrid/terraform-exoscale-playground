provider "exoscale" {
  key    = var.exoscale_api_key
  secret = var.exoscale_api_secret
}

locals {
  default_zone     = "ch-gva-2"
  default_template = "Linux Ubuntu 22.04 LTS 64-bit"
  default_type     = "standard.micro"
}

data "exoscale_compute_template" "template_one" {
  zone = local.default_zone
  name = local.default_template
}

resource "exoscale_compute_instance" "instance_one" {
  zone = local.default_zone
  name = "instance_one"

  template_id = data.exoscale_compute_template.template_one.id
  type        = local.default_type
  disk_size   = 10
  ipv6        = false
}
