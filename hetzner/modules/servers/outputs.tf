output "public_ip" {
  value = hcloud_server.this.ipv4_address
}