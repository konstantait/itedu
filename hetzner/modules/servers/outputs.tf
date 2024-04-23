output "id" {
  value = hcloud_server.this.id
}

output "name" {
  value = hcloud_server.this.name
}

output "public_ip" {
  value = hcloud_server.this.ipv4_address
}