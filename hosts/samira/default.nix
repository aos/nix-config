{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix

    ./nixos/configuration.nix
  ];

  clan.core.deployment.requireExplicitUpdate = true;
}
