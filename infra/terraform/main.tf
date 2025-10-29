terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "random" {}

resource "random_id" "suffix" {
  byte_length = 8
}

# Verwende den existierenden SSH Key von Hetzner
data "hcloud_ssh_key" "existing_key" {
  name = "robin-core-prod"
}

resource "hcloud_firewall" "robin_core" {
  name = "rc-firewall-${random_id.suffix.hex}"

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
  name        = "rc-server-${random_id.suffix.hex}"
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

output "server_ip" {
  value = hcloud_floating_ip.robin_core.ip_address
}

output "server_id" {
  value = hcloud_server.robin_core.id
}

output "firewall_name" {
  value = hcloud_firewall.robin_core.name
}

output "random_suffix" {
  value = random_id.suffix.hex
}
