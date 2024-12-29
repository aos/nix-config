{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.desktop

    ../../modules/nixos/network.nix

    ../../modules/nixos/virt.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/bluetooth.nix

    ../../modules/nixos/ml.nix

    ./nixos/configuration.nix
  ];

  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = lib.mkForce false;
  systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = lib.mkForce false;

  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    dataDir = "/data/postgresql/16";
    enableTCPIP = true;
    # Trust with password, all databases
    authentication = ''
    host  all all 192.168.10.1/24 md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 443 22 ];

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
