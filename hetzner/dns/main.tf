provider "hcloud" {
  token = var.cloud_token
}

provider "hetznerdns" {
  apitoken = var.dns_token
}

locals {
  rules = [
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
  project = var.project
  name = "key"
}

module "ns1" {
  source = "../modules/ips"
  project = var.project
  name = "ns1"

  datacenter = var.datacenter
}

module "ns2" {
  source = "../modules/ips"
  project = var.project
  name = "ns2"

  datacenter = var.datacenter
}

resource "hetznerdns_zone" "domain" {
    name = var.domain
    ttl  = 60
}

resource "hetznerdns_record" "NS1" {
  zone_id = hetznerdns_zone.domain.id
  name = "@"
  value = "ns1.${var.domain}."
  type = "NS"
  ttl= 60
}

resource "hetznerdns_record" "NS2" {
  zone_id = hetznerdns_zone.domain.id
  name = "@"
  value = "ns2.${var.domain}."
  type = "NS"
  ttl= 60
}

resource "hetznerdns_record" "NS1A" {
  zone_id = hetznerdns_zone.domain.id
  name = "ns1"
  value = module.ns1.ip
  type = "A"
  ttl= 60
}

resource "hetznerdns_record" "NS2A" {
  zone_id = hetznerdns_zone.domain.id
  name = "ns2"
  value = module.ns2.ip
  type = "A"
  ttl= 60
}

module "default" {
  source = "../modules/firewalls"
  project = var.project
  name = "fw-default"
}

module "allow" {
  source = "../modules/firewalls"
  project = var.project
  name = "fw-allow-dns"
  
  rules = local.rules
}

module "master" {
  source = "../modules/servers"
  project = var.project
  name = "master"

  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow.id]
  ip = module.ns1.id

  image = var.image
  server_type = var.server_type
  location = var.location

  user_data = templatefile("./files/user_data.sh", {
    environment = "master"
    domain = var.domain
    master_ip = module.ns1.ip,
    slave_ip = module.ns2.ip,
  })
}

module "slave" {
  source = "../modules/servers"
  project= var.project
  name = "slave"
  
  ssh_keys = [module.key.name]
  firewall_ids = [module.default.id, module.allow.id]
  ip = module.ns2.id

  server_type = var.server_type
  location = var.location
  image = var.image
  
  user_data = templatefile("./files/user_data.sh", {
    environment = "slave"
    domain = var.domain
    master_ip = module.ns1.ip,
    slave_ip = module.ns2.ip,
  })
}
