{ config, pkgs, ... }:

let
  txHomeDir = "/data/transmission";
in
{
  imports = [
    ../../../modules/nixos/sops.nix
  ];

  sops = {
    defaultSopsFile = ../../../sops/biggie/secrets.enc.yaml;
    secrets.tx_rpc_username = { };
    secrets.tx_rpc_password = { };
    secrets.tx_whitelist = { };

    templates.tx_creds.content = ''
      {
        "rpc-username": "${config.sops.placeholder.tx_rpc_username}",
        "rpc-password": "${config.sops.placeholder.tx_rpc_password}",
        "rpc-whitelist": "${config.sops.placeholder.tx_whitelist}",
        "rpc-host-whitelist": "${config.sops.placeholder.tx_whitelist}"
      }
    '';
  };

  networking.firewall.allowedUDPPorts = [ 51413 ];

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    home = txHomeDir;
    openRPCPort = true;
    credentialsFile = config.sops.templates.tx_creds.path;
    settings = {
      rpc-bind-address = "0.0.0.0";
      peer-port = 51413;
      pex-enabled = false;
      dht-enabled = false;
    };
  };
}
