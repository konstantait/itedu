locals {
  name = var.name == "" ? "${var.project}-${formatdate("YYYYMMDDhhmmss", timestamp())}" : "${var.project}-${var.name}"
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