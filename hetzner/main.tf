provider "hcloud" {
  token = var.hcloud_token
}

locals {
  project = "itedu-web"
  
  rule = [
    {
      direction  = "in"
      protocol   = "tcp"
      port       = "80"
      source_ips = ["0.0.0.0/0"]
    }
  ]
}

module "key" {
  source = "./modules/keys"
  name = local.project
  id = "key"
}

module "default" {
  source = "./modules/firewalls"
  name = local.project
  id = "fw-default"
}

module "allow-http" {
  source = "./modules/firewalls"
  name = local.project
  id = "fw-allow-http"
  rules = local.rule

}

module "web" {
  source = "./modules/servers"
  name = local.project
  id = "apache"
  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow-http.id]
}

resource "local_file" "ansible" {
  content = templatefile("inventory.tpl", {
    master_ip = module.web.public_ip,
    master_name = module.web.name,
  })

  filename = "inventory.ini"
  
  # lifecycle {
  #   prevent_destroy = true
  # }
}