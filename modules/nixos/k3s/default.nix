{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.floofs.k3s;
  vipControlplane = "192.168.10.2";
  loadbalancerCidr = "192.168.10.4/30"; # 4-7
in
{
  imports = [
    ../sops.nix
  ];

  options.floofs.k3s = {
    enable = lib.mkEnableOption "floofs-k3s";
    masterNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    serverAddr = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = lib.mkForce false;

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets.k3s_token = {
        sopsFile = ../../../sops/k3s/secrets.enc.yaml;
      };
    };

    services.tailscale = lib.mkIf config.services.tailscale.enable {
      useRoutingFeatures = "server";
      # use subnet router to advertise the kube-vip control plane
      # and Service LoadBalancer via kube-vip cloud controller
      extraSetFlags = [
        "--advertise-routes=${vipControlplane}/32,${loadbalancerCidr}"
      ];
    };

    services.k3s = {
      enable = cfg.enable;
      role = "server";
      clusterInit = cfg.masterNode;
      serverAddr = lib.mkIf (!cfg.masterNode) "https://${vipControlplane}:6443";
      tokenFile = config.sops.secrets.k3s_token.path;
      extraFlags = [
        "--disable=traefik"
        "--disable=servicelb"
        "--write-kubeconfig-mode=0644"
        "--tls-san=${vipControlplane}"
      ];
      manifests = {
        kube-vip.source = pkgs.substitute {
          src = ./rbac-daemonset.yaml;
          substitutions = [
            "--replace-fail"
            "@VIP_CONTROLPLANE@"
            vipControlplane
          ];
        };
        kube-vip-cloud-controller.source = ./kube-vip-cloud-controller.yaml;
        kube-vip-cloud-controller-cm.content = {
          apiVersion = "v1";
          kind = "ConfigMap";
          metadata = {
            name = "kubevip";
            namespace = "kube-system";
          };
          data = {
            cidr-global = loadbalancerCidr;
          };
        };
      };
    };
  };
}
