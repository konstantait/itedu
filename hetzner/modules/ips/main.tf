locals {
  name = var.name == "" ? "${var.project}-${formatdate("YYYYMMDDhhmmss", timestamp())}" : "${var.project}-${var.name}"
}

resource "hcloud_primary_ip" "this" {
  name = local.name
  datacenter = var.datacenter
  type = var.type
  assignee_type = var.assignee_type
  auto_delete = var.auto_delete
}
