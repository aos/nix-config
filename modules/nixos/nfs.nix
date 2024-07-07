{ pkgs, ... }:

{
  boot.supportedFilesystems = [ "nfs" ];

  environment.systemPackages = [ pkgs.nfs-utils ];

  services.rpcbind.enable = true;

  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "nas.lan:/volume1/Stuff";
      where = "/mnt/nas";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt/nas";
    }
  ];
}
