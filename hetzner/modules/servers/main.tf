locals {
  name = var.name == "" ? "${var.project}-${formatdate("YYYYMMDDhhmmss", timestamp())}" : "${var.project}-${var.name}"
}

resource "hcloud_server" "this" {
  name = local.name
  server_type = var.server_type
  image = var.image
  location = var.location
  ssh_keys = var.ssh_keys
  firewall_ids = var.firewall_ids
  labels = var.labels
  user_data = var.user_data
  
  public_net {
    ipv4_enabled = true
    ipv4 = var.ip
    ipv6_enabled = false
  }
}