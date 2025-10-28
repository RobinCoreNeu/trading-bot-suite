output "server_ip" {
  value = hcloud_floating_ip.robin_core.ip_address
}

output "server_id" {
  value = hcloud_server.robin_core.id
}
