{ config, ... }:

{
  imports = [
    ../../modules/nixos/server.nix

    ./nixos/configuration.nix
  ];

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
