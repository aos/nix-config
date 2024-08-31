{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix

    ../../modules/nixos/nix.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix

    ./nixos/configuration.nix
  ];

  clan.core.networking.targetHost = "aos@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
