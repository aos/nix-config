#!/usr/bin/env bash

# This script will run all the required steps to bring in our dotfiles!

set -eu pipefail

# Install docker
install_docker () {
  if command -v docker &> /dev/null && docker --version &> /dev/null; then
    echo "[x] Docker installed"
    return 0
  fi

  sudo apt update
  sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  # Add GPG key
  curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  # Add stable repository
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install
  sudo apt update
  sudo apt install docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
}

# Install nix
install_nix () {
  if command -v nix-shell &> /dev/null && \
    nix-shell -p nix-info --run "nix-info -m" &> /dev/null; then
    echo "[x] Nix installed"
    return 0
  fi

  echo "INFO: installing Nix..."
  # We need to automate this
  sh <(curl -L https://nixos.org/nix/install) --daemon

  # Enable flakes
  mkdir -p ~/.config/nix/
  cp "$(realpath config/nix.conf)" ~/.config/nix/nix.conf

  echo "Nix has been installed. Open a new shell and re-run the script to continue."
  exit 0
}

# Install home manager
install_home_manager () {
  # We are going to assume that nix is installed if we made it this far
  if nix-env -q 'home-manager.*'; then
    echo "[x] home-manager installed"
    return 0
  fi

  echo "INFO: Installing home-manager..."

  # Add Home Manager channel (Nixpkgs master or unstable)
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
  nix-channel --update

  # Need this if we're not on NixOS
  if ! grep 'NAME="NixOS"' /etc/os-release; then
    export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
  fi

  # install Home Manager
  nix-shell '<home-manager>' -A install
}

# Symlink repo
symlink_repo () {
  local link_path=~/.config/home-manager
  local current_dir="$(realpath .)"
  if [ "$(readlink -- "${link_path}")" = "${current_dir}" ]; then
    echo "[x] Symlinked to ${link_path}"
    return 0
  fi

  echo "INFO: Symlinking repository to $link_path"

  rm -rfv "${link_path}"
  ln -fs "$(realpath .)" "${link_path}"
}

hm_switch () {
  read -e -p "Have you filled out 'secrets.nix' file? [Y/n]: " -i 'Y' secrets_file
  if [ "${secrets_file}" == 'Y' ]
    echo "INFO: Running 'home-manager switch'. Original files will be suffixed with .bak"

    home-manager -b bak switch
  fi
}

main () {
  install_docker
  install_nix
  install_home_manager
  symlink_repo
  hm_switch
}

main
