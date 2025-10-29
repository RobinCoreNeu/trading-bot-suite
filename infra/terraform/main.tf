provider "hcloud" {
  token = var.hcloud_token
}

# Verwende den existierenden SSH Key von Hetzner - NAME ANPASSEN!
data "hcloud_ssh_key" "existing_key" {
  name = "robin-core-prod"  # ÄNDERE DIESEN NAMEN zum exakten Namen aus Hetzner
}

resource "hcloud_firewall" "robin_core" {
  name = "robin-core-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "3000"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9090"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9100"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}

resource "hcloud_server" "robin_core" {
  name        = "robin-core-server"
  image       = "ubuntu-24.04"
  server_type = "cx21"
  location    = "fsn1"

  # Verwende den existierenden SSH Key von Hetzner
  ssh_keys    = [data.hcloud_ssh_key.existing_key.id]
  firewall_ids = [hcloud_firewall.robin_core.id]

  user_data = file("${path.module}/cloud-init.yml")

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "hcloud_floating_ip" "robin_core" {
  type      = "ipv4"
  server_id = hcloud_server.robin_core.id
}

# Debug: Zeige verfügbare SSH Keys
data "hcloud_ssh_keys" "all_keys" {}

output "available_ssh_keys" {
  value = data.hcloud_ssh_keys.all_keys.keys[*].name
}

output "server_ip" {
  value = hcloud_floating_ip.robin_core.ip_address
}
