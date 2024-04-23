resource "random_id" "random" {
    byte_length = 4
}

locals {
  full_name = "${var.name}-${var.id}"
  random_name = "${var.name}-${random_id.random.hex}"
  name = var.id == "" ? local.random_name : local.full_name
}

resource "hcloud_firewall" "this" {
  name   = local.name
  labels = var.labels

  dynamic "rule" {
    for_each = var.rules

    content {
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      source_ips      = rule.value.source_ips
      destination_ips = rule.value.destination_ips
      port            = rule.value.port
      description     = rule.value.description
    }
  }

  dynamic "apply_to" {
    for_each = var.apply_to

    content {
      label_selector = apply_to.value.label_selector
      server         = apply_to.value.server
    }
  }
}
