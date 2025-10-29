terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Verwende den existierenden SSH Key von Hetzner
data "hcloud_ssh_key" "existing_key" {
  name = "robin-core-prod"
}

# Firewall für den BESTEHENDEN Server
resource "hcloud_firewall" "robin_core" {
  name = "robin-core-firewall-existing"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "3000"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9090"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9100"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

# Data source für den BESTEHENDEN Server
data "hcloud_server" "existing" {
  name = "existing-server" # Ändere dies zum Namen deines bestehenden Servers
}

# Firewall an bestehenden Server anhängen
resource "hcloud_firewall_attachment" "robin_core" {
  firewall_id = hcloud_firewall.robin_core.id
  server_ids  = [data.hcloud_server.existing.id]
}

output "server_ip" {
  value = data.hcloud_server.existing.ipv4_address
}

output "firewall_status" {
  value = "Firewall configured for existing server: ${data.hcloud_server.existing.name}"
}
