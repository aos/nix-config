{ inputs, config, ... }:

{
  imports = [
    inputs.srvos.nixosModules.desktop

    ../../modules/nixos/network.nix

    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix

    ./nixos/configuration.nix
  ];

  clan.core.networking.targetHost = "root@${config.networking.hostName}.local";
  clan.core.deployment.requireExplicitUpdate = true;
}
