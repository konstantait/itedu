variable "cloud_token" {
  default = ""
  sensitive = true
}

variable "dns_token" {
  default = ""
  sensitive = true
}

variable "project" {
  default = ""
}

variable "domain" {
  default = ""
}

variable "server_type" {
  type = string
  default = ""
}

variable "image" {
  type = string
  default = ""
}

variable "location" {
  type = string
  default = ""
}

variable "datacenter" {
  type = string
  default = ""
}

