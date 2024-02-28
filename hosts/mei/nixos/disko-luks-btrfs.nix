{ disks, luksKeyName ? "cryptkey", ... }:

{
  disk = {
    vda = {
      type = "disk";
      device = builtins.head disks;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };
          luksKey = {
            size = "32M";
            type = "8300";
            content = {
              type = "luks";
              name = "${luksKeyName}";
              extraFormatArgs = [ "--type luks1" ];
              postCreateHook = ''
                dd if=/dev/urandom of=/dev/mapper/${luksKeyName} count=32 bs=1024 status=progress
              '';
            };
          };
          swap = {
            size = "1G";
            type = "8300";
            content = {
              type = "luks";
              name = "cryptswap";
              extraFormatArgs = [ "--type luks1" ];
              settings = {
                keyFile = "/dev/mapper/${luksKeyName}";
                keyFileSize = 8192;
              };
              content = {
                type = "swap";
              };
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [ "--allow-discards" ];
              extraFormatArgs = [ "--type luks1" ];
              settings = {
                keyFile = "/dev/mapper/${luksKeyName}";
                keyFileSize = 8192;
              };
              postCreateHook = ''
                cryptsetup luksAddKey --type luks1 \
                                      --key-file ''${settings[keyFile]} \
                                      --keyfile-size ''${settings[keyFileSize]} \
                                      ''$device /tmp/disk.key
              '';
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
