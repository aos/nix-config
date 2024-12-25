resource "hcloud_ssh_key" "yk" {
  name       = "YK_SSH"
  public_key = local.yk_ssh_pub_key
  labels = {
    "Owner" : "A"
  }
}

resource "hcloud_ssh_key" "tower" {
  name       = "TOWER_SSH"
  public_key = local.tower_ssh_pub_key
  labels = {
    "Owner" : "A"
  }
}

resource "hcloud_firewall" "firewall" {
  name = "firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

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
    port      = "443"
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

  # All outbound traffic is allowed

  labels = {
    "Owner" : "A"
  }
}

resource "hcloud_primary_ip" "primary_ip_1" {
  name          = "pylon_ip"
  datacenter    = "ash-dc1"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels = {
    "Owner" : "A"
  }
}

resource "hcloud_server" "pylon" {
  name         = "pylon"
  image        = "ubuntu-22.04"
  datacenter   = "ash-dc1"
  server_type  = "cpx11"
  ssh_keys     = [
    hcloud_ssh_key.yk.id,
    hcloud_ssh_key.tower.id
  ]
  firewall_ids = [hcloud_firewall.firewall.id]

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.primary_ip_1.id
    ipv6_enabled = true
  }

  labels = {
    "Owner" : "A"
  }

  lifecycle {
    ignore_changes = [ssh_keys]
  }
}

output "pylon_ipv4_address" {
  value = hcloud_server.pylon.ipv4_address
}

output "pylon_ipv6_address" {
  value = hcloud_server.pylon.ipv6_address
}
