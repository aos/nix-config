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
    secrets.registry_password_hashed = {};
    secrets.registry_endpoint = {};
    secrets.registry_username = {
      sopsFile = ../../../sops/general/secrets.enc.yaml;
    };

    templates.caddy_env.content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cf_floofs_api_token}
      INGRESS_LOADBALANCER_IP=${config.sops.placeholder.ingress_lb_ip}
      DOCKER_REGISTRY_ENDPOINT=${config.sops.placeholder.registry_endpoint}
      DOCKER_REGISTRY_USERNAME=${config.sops.placeholder.registry_username}
      DOCKER_REGISTRY_PASSWORD=${config.sops.placeholder.registry_password_hashed}
    '';
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.1"
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb"
      ];
      hash = "sha256-mhf03AOA3cW5QE9pi4Fqn9k7P2UKekMdDCSQcMx+xJ4=";
    };
    globalConfig = ''
      servers {
        trusted_proxies cloudflare {
          interval 24h
          timeout 15s
        }
      }
    '';
    virtualHosts = {
      "registry.floofs.club".extraConfig = ''
        tls {
          dns cloudflare {env.CF_DNS_API_TOKEN}
        }

        basic_auth {
          {$DOCKER_REGISTRY_USERNAME} {$DOCKER_REGISTRY_PASSWORD}
        }

        request_body {
          max_size 10GB
        }

        reverse_proxy {$DOCKER_REGISTRY_ENDPOINT} {
          header_up X-Forwarded-Proto https

          transport http {
            read_timeout 600s
            write_timeout 600s
          }
        }
      '';

      "*.floofs.club".extraConfig = ''
        tls {
          dns cloudflare {env.CF_DNS_API_TOKEN}
        }

        reverse_proxy http://{$INGRESS_LOADBALANCER_IP} {
          header_up X-Forwarded-Proto https
        }
      '';
    };
    environmentFile = config.sops.templates.caddy_env.path;
  };
}
