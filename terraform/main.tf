terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

provider "sops" {}

data "sops_file" "token" {
  source_file = "${path.module}/../sops/pylon/secrets.enc.yaml"
}

provider "digitalocean" {
  token = data.sops_file.token.data["do_token"]
}

data "digitalocean_image" "nixos" {
  name = "nixos-20231228"
}

resource "digitalocean_ssh_key" "yk" {
  name       = "YK SSH"
  public_key = file("${path.module}/../sops/general/ssh_id_rsa_yk.pub")
}

resource "digitalocean_droplet" "devserver" {
  name     = "devserver"
  image    = "50901536" # "ubuntu-18-04-x64" - slug no longer available
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
}

resource "digitalocean_droplet" "pylon" {
  image    = data.digitalocean_image.nixos.id
  name     = "pylon"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.yk.fingerprint]
}
