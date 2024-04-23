resource "random_id" "random" {
    byte_length = 4
}

locals {
  full_name = "${var.name}-${var.id}"
  random_name = "${var.name}-${random_id.random.hex}"
  name = var.id == "" ? local.random_name : local.full_name
}

resource "tls_private_key" "generic" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private" {
  filename = pathexpand("~/.ssh/${local.name }.key")
  file_permission = "600"
  directory_permission = "700"
  content = tls_private_key.generic.private_key_openssh
}

resource "local_file" "public" {
  filename = pathexpand("~/.ssh/${local.name}.pub")
  file_permission = "600"
  directory_permission = "700"
  content = tls_private_key.generic.public_key_openssh
}

resource "hcloud_ssh_key" "this" {
  name = local.name
  public_key = tls_private_key.generic.public_key_openssh
}