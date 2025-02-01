{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.floofs.nfs;
  defaultLocation = "nas.lan";
  defaultFolder = "Stuff";
  defaultMountpoint = "/mnt/nas";
in
{
  options.floofs.nfs = {
    enable = lib.mkEnableOption "floofs-nfs";
    nfsLocation = lib.mkOption {
      type = lib.types.str;
      default = defaultLocation;
    };
    folderName = lib.mkOption {
      type = lib.types.str;
      default = defaultFolder;
    };
    mountpoint = lib.mkOption {
      type = lib.types.str;
      default = defaultMountpoint;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs" ];
    environment.systemPackages = [ pkgs.nfs-utils ];
    services.rpcbind.enable = true;

    systemd.mounts = [
      {
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
        what = "${cfg.nfsLocation}:/volume1/${cfg.folderName}";
        where = cfg.mountpoint;
      }
    ];

    systemd.automounts = [
      {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = cfg.mountpoint;
      }
    ];
  };
}
