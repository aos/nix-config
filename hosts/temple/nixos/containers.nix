{ config, ... }:

{
  imports = [
    ../../../modules/nixos/sops.nix
  ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../../../sops/temple/secrets.enc.yaml;

    secrets.bingbong_db_url = { };
    secrets.bingbong_key = { };
    secrets.mqtt_client_password = { };
    secrets.registry_username = {
      sopsFile = ../../../sops/general/secrets.enc.yaml;
    };
    secrets.registry_password = {
      sopsFile = ../../../sops/general/secrets.enc.yaml;
    };

    templates.bingbong_env.content = ''
      DATABASE_URL=${config.sops.placeholder.bingbong_db_url}
      MQTT_CLIENT_PASSWORD=${config.sops.placeholder.mqtt_client_password}
      SECRET_KEY_BASE=${config.sops.placeholder.bingbong_key}
    '';
  };

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
        bingbong = {
          login = {
            registry = "https://registry.floofs.club";
            username = "mei";
            passwordFile = config.sops.secrets.registry_password.path;
          };
          image = "registry.floofs.club/floofs/bingbong:latest";
          environmentFiles = [
            config.sops.templates.bingbong_env.path
          ];
          extraOptions = [
            "--pull=newer"
            "--network=host"
          ];
        };
      };
    };
  };
}
