{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix

    ./nixos/configuration.nix
  ];

  services.tailscale.enable = true;

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
