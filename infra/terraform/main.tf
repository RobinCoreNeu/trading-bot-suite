provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "robin-core-main"
  public_key = var.ssh_public_key
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
  name        = "robin-core-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image       = "ubuntu-24.04"
  server_type = "cx21"
  location    = "fsn1"

  ssh_keys    = [hcloud_ssh_key.default.id]
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
