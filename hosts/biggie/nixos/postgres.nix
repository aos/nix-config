{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/nixos/sops.nix
  ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../../../sops/general/secrets.enc.yaml;
    secrets.b2_floofs_repository = { };
    secrets.b2_floofs_password = { };
    secrets.b2_floofs_key_id = { };
    secrets.b2_floofs_key = { };

    templates.restic_floofs_env.content = ''
      B2_ACCOUNT_ID=${config.sops.placeholder.b2_floofs_key_id}
      B2_ACCOUNT_KEY=${config.sops.placeholder.b2_floofs_key}
    '';
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    dataDir = "/data/postgresql/16";
    enableTCPIP = true;
    # Trust with password, all databases
    authentication = ''
    host  all all 192.168.10.1/24 md5
    host  all all 100.64.0.0/10   md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
    # We trigger this through restic
    startAt = [ ];
  };

  services.restic.backups.b2 = {
    environmentFile = config.sops.templates.restic_floofs_env.path;
    repositoryFile = config.sops.secrets.b2_floofs_repository.path;
    passwordFile = config.sops.secrets.b2_floofs_password.path;

    paths = [ "/var/backup/postgresql" ];
    initialize = true;
    pruneOpts = [ "--keep-daily 7" "--keep-weekly 3" "--keep-monthly 3" ];
    timerConfig = {
      OnCalendar = "04:45";
      Persistent = true;
    };
  };
  systemd.services.restic-backups-b2.wants = [ "postgresqlBackup.service" ];
}
