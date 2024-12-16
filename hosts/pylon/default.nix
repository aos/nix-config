{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix

    ./nixos/configuration.nix
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
