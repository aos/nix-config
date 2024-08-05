terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

provider "sops" {}

data "sops_file" "tokens" {
  source_file = "${path.module}/../sops/pylon/secrets.enc.yaml"
}

provider "hcloud" {
  token = data.sops_file.tokens.data["hcloud_token"]
}

locals {
  tower_ssh_pub_key = file("${path.module}/../sops/keys/aos/ssh_tower_ed25519.pub")
  yk_ssh_pub_key = file("${path.module}/../sops/keys/aos/ssh_yubikey_rsa.pub")
}
