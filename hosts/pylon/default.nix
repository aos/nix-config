{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/sops.nix

    ./nixos/configuration.nix
  ];

  sops = {
    defaultSopsFile = ../../sops/pylon/secrets.enc.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.cf_floofs_api_token = { };
    secrets.ingress_lb_ip = { };

    templates.caddy_env.content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cf_floofs_api_token}
      INGRESS_LOADBALANCER_IP=${config.sops.placeholder.ingress_lb_ip}
    '';
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb"
      ];
      hash = "sha256-H4dbfBlBZDBOUuFzh3DRB/Pw2j+j1kHw1gIO4PK7Qfg=";
    };
    globalConfig = ''
      servers {
        trusted_proxies cloudflare {
          interval 24h
          timeout 15s
        }
      }
    '';
    virtualHosts."*.floofs.club".extraConfig = ''
      tls {
        dns cloudflare {env.CF_DNS_API_TOKEN}
      }

      reverse_proxy http://{$INGRESS_LOADBALANCER_IP} {
        header_up X-Forwarded-Proto https
      }
    '';
    environmentFile = config.sops.templates.caddy_env.path;
  };

  clan.core.networking.buildHost = "root@biggie";
  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
