{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/monitoring.nix

    ./nixos/configuration.nix
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  users.users.automation = {
    group = "automation";
    isSystemUser = true;
  };
  users.groups.automation = {};

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    ensureUsers = [
      {
        name = "automation";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "automation" ];
    # Trust with password, all databases
    authentication = ''
      #type database DBuser auth-method
      host  all      all    192.168.10.1/24 md5
      host  all      all    100.64.0.0/10   md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 8080 ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";
      containers = {
        homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:2025.6";
          autoStart = true;
          environment.TZ = "America/New_York";
          volumes = [
            "/etc/home-assistant:/config"
            "/var/lib/home-assistant-media:/media"
            # "/run/dbus:/run/dbus:ro" # for bluetooth
          ];
          extraOptions = [
            "--network=host"
          ];
        };
        zigbee2mqtt = {
          image = "ghcr.io/koenkk/zigbee2mqtt:2.5.1";
          autoStart = true;
          environment.TZ = "America/New_York";
          volumes = [
            "/etc/zigbee2mqtt/data:/app/data"
            "/run/udev:/run/udev:ro"
          ];
          extraOptions = [
            "--network=host"
            "--group-add=keep-groups"
            "--device=/dev/ttyACM0:/dev/ttyACM0"
          ];
        };
      };
    };
  };
}
