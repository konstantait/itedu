provider "hcloud" {
  token = var.hcloud_token
}

locals {
  project = "itedu"
  
  rule = [
    {
      direction  = "in"
      protocol   = "tcp"
      port       = "53"
      source_ips = ["0.0.0.0/0"]
    },
    {
      direction  = "in"
      protocol   = "udp"
      port       = "53"
      source_ips = ["0.0.0.0/0"]
    }
  ]
}

module "key" {
  source = "../modules/keys"
  name = local.project
  id = "key"
}

module "default" {
  source = "../modules/firewalls"
  name = local.project
  id = "fw-default"
}

module "allow" {
  source = "../modules/firewalls"
  name = local.project
  id = "fw-allow-dns"
  rules = local.rule
}

module "master" {
  source = "../modules/servers"
  name = local.project
  id = "master"
  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow.id]
}

module "slave" {
  source = "../modules/servers"
  name = local.project
  id = "slave"
  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow.id]
}

resource "local_file" "ansible" {
  content = templatefile("inventory-dns.tpl", {
    master_ip = module.master.public_ip,
    master_name = module.master.name,
    slave_ip = module.slave.public_ip,
    slave_name = module.slave.name,
  })

  filename = "inventory-dns.ini"
  
  # lifecycle {
  #   prevent_destroy = true
  # }
}