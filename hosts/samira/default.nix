{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/nfs.nix
    ../../modules/nixos/calibre.nix

    ./nixos/configuration.nix
  ];

  clan.core.deployment.requireExplicitUpdate = true;
}
