#!/usr/bin/env bash

# This script will run all the required steps to bring in our dotfiles!

set -eu pipefail

# Install nix (lix)
install_nix () {
  if command -v nix-shell &> /dev/null && \
    nix-shell -p nix-info --run "nix-info -m" &> /dev/null; then
    echo "[x] Lix installed"
    return 0
  fi

  echo "INFO: installing Nix (Lix)..."
  # We need to automate this
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install

  # Enable flakes
  # mkdir -p ~/.config/nix/
  # cp "$(realpath config/nix.conf)" ~/.config/nix/nix.conf

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
  # nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
  nix-channel --update

  # install Home Manager
  nix-shell '<home-manager>' -A install
}

main () {
  install_nix
  install_home_manager
}

main
