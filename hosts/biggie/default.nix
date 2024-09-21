{ inputs, config, ... }:

{
  imports = [
    inputs.srvos.nixosModules.desktop

    ../../modules/nixos/network.nix

    ../../modules/nixos/virt.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix

    ../../modules/nixos/ml.nix

    ./nixos/configuration.nix
  ];

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
