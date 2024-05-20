
variable "project" {
  type        = string
  default     = "firewall"
}

variable "name" {
  type = string
  default = ""
}

variable "labels" {
  type        = map(string)
  default     = {}
}

variable "rules" {
  type = list(object({
    direction = string
    protocol = string
    source_ips = optional(list(string))
    destination_ips = optional(list(string))
    port = optional(string)
    description = optional(string)
  }))

  default = [
    {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  },
  {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  ]

  validation {
    condition     = contains(["in", "out"], var.rules[0].direction)
    error_message = "Direction could only be 'in' or 'out'."
  }

  validation {
    condition     = contains(["tcp", "udp", "icmp", "udp", "gre", "esp"], var.rules[0].protocol)
    error_message = "Only one of this list of protocols could be used ['tcp', 'icmp', 'udp', 'gre', 'esp']."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : false if(rule.direction == "out" && rule.destination_ips == null)
    ])
    error_message = "When 'direction' is set to 'out', 'destination_ips' list with at least one CIDR must be added."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : false if(rule.direction == "in" && rule.source_ips == null)
    ])
    error_message = "When 'direction' is set to 'in', 'source_ips' list with at least one CIDR must be added."
  }

  validation {
    condition     = contains(["tcp", "udp"], var.rules[0].protocol) ? var.rules[0].port != null : true
    error_message = "If 'protocol' is set to either 'tcp' or 'udp', 'port' must be set."
  }
}

variable "apply_to" {
  type = list(object({
    label_selector = optional(string)
    server         = optional(number)
  }))
  default = []
}