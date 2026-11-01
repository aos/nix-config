{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/monitoring.nix

    ./nixos/configuration.nix
    ./nixos/caddy.nix
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  deployment.buildOnTarget = false;
}
