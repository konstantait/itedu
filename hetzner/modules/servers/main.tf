resource "random_id" "random" {
    byte_length = 4
}

locals {
  full_name = "${var.name}-${var.id}"
  random_name = "${var.name}-${random_id.random.hex}"
  name = var.id == "" ? local.random_name : local.full_name
}

resource "hcloud_server" "this" {
  name = local.name
  server_type = var.server_type
  image = var.image
  location = var.location
  ssh_keys = var.ssh_keys
  firewall_ids = var.firewall_ids
  labels = var.labels
}