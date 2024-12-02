{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix
    # ../../modules/nixos/calibre.nix

    ../../modules/nixos/nfs.nix
    ../../modules/nixos/rke2.nix

    ./nixos/configuration.nix
  ];

  floofs.nfs = {
    enable = true;
    folderName = "k8s_storage";
    mountpoint = "/mnt/nas";
  };

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
