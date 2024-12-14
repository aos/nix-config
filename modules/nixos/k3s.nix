{ config, inputs, lib, ... }:

let
  cfg = config.floofs.k3s;
  defaultTokenFile = "/var/lib/floofs/k3s_token";
in
{
  imports = [
    ./sops.nix
  ];

  options.floofs.k3s = {
    enable = lib.mkEnableOption "Enable k3s";
    clusterInit = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    serverAddr = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = defaultTokenFile;
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets.k3s_token = {
        path = defaultTokenFile;
        sopsFile = ../../sops/k3s/secrets.enc.yaml;
        format = "yaml";
      };
    };

    services.k3s = {
      enable = cfg.enable;
      role = "server";
      clusterInit = cfg.clusterInit;
      serverAddr = cfg.serverAddr;
      tokenFile = cfg.tokenFile;
      extraFlags = [
        "--disable=traefik"
        "--disable=servicelb"
        "--write-kubeconfig-mode=0644"
      ];
    };
  };
}
