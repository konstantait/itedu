provider "hcloud" {
  token = var.cloud_token
}

locals {
  rules = [
    {
      direction  = "in"
      protocol   = "tcp"
      port       = "80"
      source_ips = ["0.0.0.0/0"]
    },
  ]
}

module "key" {
  source = "../modules/keys"
  project = var.project
  name = "key"
}

module "ip" {
  source = "../modules/ips"
  project = var.project
  name = "ip"

  datacenter = var.datacenter
}

module "default" {
  source = "../modules/firewalls"
  project = var.project
  name = "fw-default"
}

module "allow" {
  source = "../modules/firewalls"
  project = var.project
  name = "fw-allow-http"
  
  rules = local.rules
}

module "web" {
  source = "../modules/servers"
  project = var.project
  name = "web"

  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow.id]
  ip = module.ip.id

  image = var.image
  server_type = var.server_type
  location = var.location

  # user_data = templatefile("./files/user_data.sh", {
  #   environment = "master"
  #   domain = var.domain
  #   master_ip = module.ns1.ip,
  #   slave_ip = module.ns2.ip,
  # })
}