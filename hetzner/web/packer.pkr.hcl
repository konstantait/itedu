packer {
  required_plugins {
    hcloud = {
      source = "github.com/hetznercloud/hcloud"
      version = ">= 1.2.0"
    }
  }
}

variable "token" { default = env("CLOUD_TOKEN") }
variable "project" { default = env("CLOUD_PROJECT") }
variable "image" { default = env("CLOUD_IMAGE") }
variable "location" { default = env("CLOUD_LOCATION") }
variable "server_type" { default = env("CLOUD_SERVER_TYPE") }
variable "ssh_username" { default = env("CLOUD_SSH_USERNAME") }

locals {
  
  snapshot_name = "${var.project}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  
  root = "./files/root"
  
  files = [
    // "/etc/resolv.conf",
    // "/etc/apparmor.d/usr.sbin.named",
    // "/usr/share/dns/root.hints",
  ]
  
  folders = [
    "/etc/apache2",
  ]
  
  mkdir = setunion(
    [ for file in local.files : dirname(file) ],
    [ for folder in local.folders : folder ]
  )

  delete = [
    // "*.key",
    // "*.keys",
  ]

  commands = [
    "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections",
    "apt-get update",
    "apt-get install -y ntpdate ntp mc",
    "apt-get install -y apache2 apache2-doc apache2-utils",
  ]
}

source "hcloud" "base" {
  token = var.token
  image = var.image
  location = var.location
  server_type = var.server_type
  ssh_keys = []
  user_data = ""
  ssh_username = var.ssh_username
  snapshot_name = local.snapshot_name
  snapshot_labels = {
    project = var.project
  }
}

build {
  
  sources = ["source.hcloud.base"]
  
  provisioner "shell-local" { 
    inline = [ "rm -rf ${local.root}" ] 
  }

  dynamic "provisioner" {
    for_each = local.mkdir
    labels = ["shell-local"]
    iterator = item
    content { 
      inline = [ "mkdir -p ${local.root}${item.value}" ] 
    }
  }

  provisioner "shell" { 
    inline = local.commands 
  }

  dynamic "provisioner" {
    for_each = local.files
    labels = ["file"]
    iterator = item
    content {
      direction = "download"
      source = "${item.value}"
      destination = "${local.root}${item.value}"
    }
  }

  dynamic "provisioner" {
    for_each = local.folders
    labels = ["file"]
    iterator = item
    content {
      direction = "download"
      source = "${item.value}/"
      destination = "${local.root}${dirname(item.value)}"
    }
  }
  
  dynamic "provisioner" {
    for_each = local.delete
    labels = ["shell-local"]
    iterator = item
    content { 
      inline = [ "find ${local.root} -name '${item.value}' -type f -delete", ] 
    }
  }

  post-processor "manifest" {
    output = ".manifest.json"
  }

}
