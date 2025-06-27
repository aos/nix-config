{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/nixos/sops.nix
  ];

  sops = {
    defaultSopsFile = ../../../sops/pylon/secrets.enc.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.cf_floofs_api_token = { };
    secrets.ingress_lb_ip = { };

    templates.caddy_env.content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cf_floofs_api_token}
      INGRESS_LOADBALANCER_IP=${config.sops.placeholder.ingress_lb_ip}
    '';
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.1"
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb"
      ];
      hash = "sha256-u1vthRVXRbsD8FnlzfX39Yn/uzHzvYfipu4NNp7uJLE=";
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
}
