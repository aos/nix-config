{
  inputs,
  config,
  lib,
  ...
}:

{
  imports = [
    inputs.srvos.nixosModules.desktop
    ../../modules/nixos/monitoring.nix

    ../../modules/nixos/network.nix

    ../../modules/nixos/virt.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/bluetooth.nix

    ../../modules/nixos/weechat.nix

    ../../modules/nixos/ml.nix

    ./nixos/configuration.nix
    ./nixos/postgres.nix
    ./nixos/transmission.nix
  ];

  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = lib.mkForce false;
  systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = lib.mkForce false;

  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.8.0/24"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  clan.core.networking.targetHost = "root@${config.networking.hostName}";
  clan.core.deployment.requireExplicitUpdate = true;
}
