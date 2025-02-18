{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.floofs.systemd-pushover;
  hostname = config.networking.hostName;
in
{
  options.floofs.systemd-pushover = {
    enable = lib.mkEnableOption "systemd-pushover";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = ../../sops/general/secrets.enc.yaml;
      secrets.pushover_app_backups_key = { };
      secrets.pushover_user_key = { };
      templates.pushover_env.content = ''
        PUSHOVER_TOKEN=${config.sops.placeholder.pushover_app_backups_key}
        PUSHOVER_USER_KEY=${config.sops.placeholder.pushover_user_key}
      '';
    };

    systemd.services."pushover@" = {
      description = "Send a notification through pushover";
      script = builtins.concatStringsSep " " [
        "${lib.getExe pkgs.curl} -s"
        ''--form-string token="$PUSHOVER_TOKEN"''
        ''--form-string user="$PUSHOVER_USER_KEY"''
        ''--form-string title="$1 failed (${hostname})"''
        ''--form-string message="$(${pkgs.systemd}/bin/systemctl status --full $1)"''
        "https://api.pushover.net/1/messages.json"
      ];
      scriptArgs = "%i";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.templates.pushover_env.path;
      };
    };
  };
}
