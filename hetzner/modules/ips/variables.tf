variable "project" {
  type = string
  default = "ip"
}

variable "name" {
  type = string
  default = ""
}

variable "datacenter" {
  type = string
  default = "hel1-dc2"
}

variable "type" {
  type = string
  default = "ipv4"
}

variable "assignee_type" {
  type = string
  default = "server"
}

variable "auto_delete" {
  type = bool
  default = false
}
