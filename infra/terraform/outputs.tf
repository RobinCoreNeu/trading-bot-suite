output "server_ip" {
  description = "The floating IP of the server"
  value       = hcloud_floating_ip.robin_core.ip_address
}

output "server_id" {
  description = "The ID of the server"
  value       = hcloud_server.robin_core.id
}
