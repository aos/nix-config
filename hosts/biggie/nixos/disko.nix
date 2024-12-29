{ lib, ... }:

{
  disko.devices = {
    disk = {
      linux_disk = {
        device = "/dev/disk/by-uuid/e5d48d1a-643e-4bfd-9aa9-1eb3057b275d";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              start = "2M";
              size = "537M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "-10G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
      data = {
        device = "/dev/disk/by-id/wwn-0x5002538f3190ca37";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/data";
                mountOptions = [ "defaults" "pquota" ];
              };
            };
          };
        };
      }
    };
  };
}
