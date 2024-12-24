{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/server.nix

    ./nixos/configuration.nix
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy-with-plugins.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" ];
      hash = "sha256-Aqu2st8blQr/Ekia2KrH1AP/2BVZIN4jOJpdLc1Rr4g=";
    };
    virtualHosts."floofs.club".extraConfig = ''
      respond "Hello world!"
    '';
  };

  clan.core.networking.buildHost = "root@biggie";
  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
