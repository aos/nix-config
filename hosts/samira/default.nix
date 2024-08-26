{ ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/network.nix

    ./nixos/configuration.nix
  ];

  clan.core.networking.targetHost = "root@samira";
  clan.core.deployment.requireExplicitUpdate = true;
}
