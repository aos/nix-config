{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/monitoring.nix

    ./nixos/configuration.nix
    ./nixos/containers.nix
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };
}
