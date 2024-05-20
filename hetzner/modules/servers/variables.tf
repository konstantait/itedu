variable "project" {
  type = string
  default = "server"
}

variable "name" {
  type = string
  default = ""
}

variable "server_type" {
  type = string
  default = "cax11"
}

variable "image" {
  type = string
  default = "debian-11"
}

variable "location" {
  type = string
  default = "hel1"
}

variable "ip" {
  type = string
  default = ""
}

variable "ssh_keys" {
  type = list(string)
  default = []
}

variable "firewall_ids" {
  type = list(string)
  default = []
}

variable "labels" {
  type = map(string)
  default = {}
}

variable "user_data" {
  type = string
  default = ""
}