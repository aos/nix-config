{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = lib.mkDefault "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S625NJ0R107819W";
        type = "disk";
        # Set the following in flake.nix for each maschine:
        # device = <uuid>;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 1;
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                # format = "btrfs";
                # format = "bcachefs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
