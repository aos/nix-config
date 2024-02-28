{ disks, ... }: {
  disk = {
    v = {
      type = "disk";
      device = builtins.head disks;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "64M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luksKey = {
            size = "32M";
            type = "8300";
            content = {
              type = "luks";
              name = "cryptkey";
              askPassword = true;
              extraFormatArgs = ["--type luks1"];
              content = {
                type = "filesystem";
                format = "ext4";
              };
            };
          };
          swap = {
            size = "1G";
            type = "8300";
            content = {
              type = "luks";
              name = "cryptswap";
              extraFormatArgs = ["--type luks1"];
              settings = {
                keyFile = "/dev/mapper/cryptkey";
                keyFileSize = 8192;
              };
              content = {
                type = "swap";
              };
            };
          };
          root = {
            size = "100%";
            type = "8300";
            content = {
              type = "luks";
              name = "cryptroot";
              askPassword = true;
              extraOpenArgs = ["--allow-discards"];
              settings = {
                keyFile = "/dev/mapper/cryptkey";
                keyFileSize = 8192;
                fallbackToPassword = true;
              };
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      options = {
        autotrim = "on";
      };
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
      };

      datasets = {
        "local" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            compression = "on";
          };
        };
        "system" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            compression = "on";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "user" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            compression = "on";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "reserved" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            compression = "on";
            reservation = "1G";
            quota = "1G";
          };
        };
        "system/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "/";
        };
        "system/var" = {
          type = "zfs_fs";
          mountpoint = "/var";
          options.xattr = "sa";
          options.acltype = "posixacl";
        };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        "user/home" = {
          type = "zfs_fs";
        };
        "user/home/aos" = {
          type = "zfs_fs";
          mountpoint = "/home/aos";
        };
      };
    };
  };
}
