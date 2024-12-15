{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix

    ../../modules/nixos/nfs.nix
    ../../modules/nixos/k3s

    ./nixos/configuration.nix
  ];

  floofs.nfs = {
    enable = true;
    folderName = "k8s_storage";
    mountpoint = "/mnt/nas";
  };

  floofs.k3s = {
    enable = true;
  };

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
