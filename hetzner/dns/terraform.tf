terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">=1.36.0"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = ">=2.1.0"
    }
  }
}